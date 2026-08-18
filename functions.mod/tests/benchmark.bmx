SuperStrict

Framework BRL.StandardIO
Import BRL.Functions
Import BRL.System

Const ITERATIONS:Int = 4000000
Const ALLOCATION_SAMPLES:Int = 100000

Function IncrementBenchmark:Int(value:Int)
	Return value + 1
End Function

Function DoubleBenchmark:Int(value:Int)
	Return value * 2
End Function

Local composed:Closure<Int(value:Int)> = Compose<Int, Int, Int>(DoubleBenchmark, IncrementBenchmark)
If composed(20) <> 42 Then Throw "Functions benchmark warmup failed"

Local directChecksum:Long
Local started:Int = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	directChecksum :+ DoubleBenchmark(IncrementBenchmark(index))
Next
Local directMilliseconds:Int = MilliSecs() - started

Local pipeChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	pipeChecksum :+ Pipe<Int, Int>(Pipe<Int, Int>(index, IncrementBenchmark), DoubleBenchmark)
Next
Local pipeMilliseconds:Int = MilliSecs() - started

Local reusedChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	reusedChecksum :+ composed(index)
Next
Local reusedMilliseconds:Int = MilliSecs() - started

Local rebuiltChecksum:Long
started = MilliSecs()
For Local index:Int = 0 Until ITERATIONS
	rebuiltChecksum :+ Compose<Int, Int, Int>(DoubleBenchmark, IncrementBenchmark)(index)
Next
Local rebuiltMilliseconds:Int = MilliSecs() - started

' Measure retained managed storage separately from timing. A reused composition
' is created before the sample; rebuilding creates a fresh Closure environment.
GCCollect()
Local reusedBytesBefore:Size_T = GCMemAlloced()
GCSuspend()
For Local index:Int = 0 Until ALLOCATION_SAMPLES
	reusedChecksum :+ composed(index)
Next
Local reusedBytes:Size_T = GCMemAlloced() - reusedBytesBefore
GCResume()
GCCollect()

Local rebuiltBytesBefore:Size_T = GCMemAlloced()
GCSuspend()
For Local index:Int = 0 Until ALLOCATION_SAMPLES
	rebuiltChecksum :+ Compose<Int, Int, Int>(DoubleBenchmark, IncrementBenchmark)(index)
Next
Local rebuiltBytes:Size_T = GCMemAlloced() - rebuiltBytesBefore
GCResume()
GCCollect()

Local expected:Long = Long(ITERATIONS) * Long(ITERATIONS - 1) + Long(ITERATIONS) * 2
Local allocationExpected:Long = Long(ALLOCATION_SAMPLES) * Long(ALLOCATION_SAMPLES - 1) + Long(ALLOCATION_SAMPLES) * 2
If directChecksum <> expected Then Throw "direct checksum mismatch"
If pipeChecksum <> expected Then Throw "Pipe checksum mismatch"
If reusedChecksum <> expected + allocationExpected Then Throw "reused Compose checksum mismatch"
If rebuiltChecksum <> expected + allocationExpected Then Throw "rebuilt Compose checksum mismatch"

Print "BRL.Functions benchmark: " + ITERATIONS + " composed operations"
Print "direct nested calls:       " + directMilliseconds + " ms"
Print "nested Pipe calls:         " + pipeMilliseconds + " ms"
Print "reused Compose Closure:    " + reusedMilliseconds + " ms"
Print "rebuild Compose each call: " + rebuiltMilliseconds + " ms"
Print "managed bytes retained by " + ALLOCATION_SAMPLES + " calls: reused " + reusedBytes + ", rebuilt " + rebuiltBytes
