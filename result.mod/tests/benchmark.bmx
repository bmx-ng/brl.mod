SuperStrict

Framework BRL.StandardIO
Import BRL.Result
Import BRL.System

Const ITERATIONS:Int = 4000000
Const ALLOCATION_SAMPLES:Int = 100000

Type TIntStringResultBox
	Field isOk:Int
	Field value:Int
	Field error:String
End Type

Function IncrementResultValue:Int(value:Int)
	Return value + 1
End Function

' Warm generic registration and generated code before measuring.
Local warmup:Result<Int, String> = Result<Int, String>.Ok(1).Map<Int>(IncrementResultValue)
If warmup.Value() <> 2 Then Throw "Result benchmark warmup failed"

Local directChecksum:Long
Local started:Int = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	Local state:EResultState = EResultState.Ok
	Local value:Int = index
	If state = EResultState.Ok Then directChecksum :+ value
Next
Local directMilliseconds:Int = MilliSecs() - started

Local structChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	Local result:Result<Int, String> = Result<Int, String>.Ok(index)
	structChecksum :+ result.Value()
Next
Local structMilliseconds:Int = MilliSecs() - started

Local mapChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	Local result:Result<Int, String> = Result<Int, String>.Ok(index).Map<Int>(IncrementResultValue)
	mapChecksum :+ result.Value()
Next
Local mapMilliseconds:Int = MilliSecs() - started

Local heapChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	Local result:TIntStringResultBox = New TIntStringResultBox
	result.isOk = True
	result.value = index
	heapChecksum :+ result.value
Next
Local heapMilliseconds:Int = MilliSecs() - started

' Retain otherwise-dead managed allocations by suspending collection. This is
' deliberately separate from the timings above and uses a smaller sample.
GCCollect()
Local structBytesBefore:Size_T = GCMemAlloced()
GCSuspend()
For Local index:Int = 0 Until ALLOCATION_SAMPLES
	Local result:Result<Int, String> = Result<Int, String>.Ok(index)
	structChecksum :+ result.Value()
Next
Local structBytes:Size_T = GCMemAlloced() - structBytesBefore
GCResume()
GCCollect()

Local heapBytesBefore:Size_T = GCMemAlloced()
GCSuspend()
For Local index:Int = 0 Until ALLOCATION_SAMPLES
	Local result:TIntStringResultBox = New TIntStringResultBox
	result.isOk = True
	result.value = index
	heapChecksum :+ result.value
Next
Local heapBytes:Size_T = GCMemAlloced() - heapBytesBefore
GCResume()
GCCollect()

Local expected:Long = Long(ITERATIONS) * Long(ITERATIONS - 1) / 2
Local allocationExpected:Long = Long(ALLOCATION_SAMPLES) * Long(ALLOCATION_SAMPLES - 1) / 2
If directChecksum <> expected Then Throw "direct checksum mismatch"
If structChecksum <> expected + allocationExpected Then Throw "Struct checksum mismatch"
If mapChecksum <> expected + ITERATIONS Then Throw "Map checksum mismatch"
If heapChecksum <> expected + allocationExpected Then Throw "Type checksum mismatch"

Print "BRL.Result benchmark: " + ITERATIONS + " Ok values"
Print "direct tagged locals: " + directMilliseconds + " ms"
Print "Result Struct:       " + structMilliseconds + " ms"
Print "Result Struct + Map: " + mapMilliseconds + " ms"
Print "heap Type baseline:  " + heapMilliseconds + " ms"
Print "managed bytes retained by " + ALLOCATION_SAMPLES + " samples: Struct " + structBytes + ", Type " + heapBytes
