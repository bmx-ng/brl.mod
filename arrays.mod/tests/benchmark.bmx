SuperStrict

Framework BRL.StandardIO
Import BRL.Arrays
Import BRL.Sequence
Import BRL.System

Const VALUE_COUNT:Int = 200000
Const ITERATIONS:Int = 100

Function BenchmarkEven:Int(value:Int)
	Return (value & 1) = 0
End Function

Function BenchmarkTriple:Int(value:Int)
	Return value * 3
End Function

Function BenchmarkAdd:Long(total:Long, value:Int)
	Return total + value
End Function

Local values:Int[] = New Int[VALUE_COUNT]
For Local index:Int = 0 Until values.Length
	values[index] = index
Next

Local tripleClosure:Closure<Int(value:Int)> = Function:Int(value:Int)
	Return value * 3
End Function

' Warm generic specialization and allocation paths.
Map<Int, Int>(values, BenchmarkTriple)
Filter<Int>(values, BenchmarkEven)

Local directMapChecksum:Long
Local started:Int = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = New Int[values.Length]
	For Local index:Int = 0 Until values.Length
		result[index] = values[index] * 3
	Next
	directMapChecksum :+ result[result.Length - 1]
Next
Local directMapMilliseconds:Int = MilliSecs() - started

Local thinMapChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = Map<Int, Int>(values, BenchmarkTriple)
	thinMapChecksum :+ result[result.Length - 1]
Next
Local thinMapMilliseconds:Int = MilliSecs() - started

Local closureMapChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = Map<Int, Int>(values, tripleClosure)
	closureMapChecksum :+ result[result.Length - 1]
Next
Local closureMapMilliseconds:Int = MilliSecs() - started

Local directPipelineChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	For Local value:Int = EachIn values
		If (value & 1) = 0 Then directPipelineChecksum :+ Long(value * 3)
	Next
Next
Local directPipelineMilliseconds:Int = MilliSecs() - started

Local arraysPipelineChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local filtered:Int[] = Filter<Int>(values, BenchmarkEven)
	Local mapped:Int[] = Map<Int, Int>(filtered, BenchmarkTriple)
	arraysPipelineChecksum :+ Fold<Int, Long>(mapped, Long(0), BenchmarkAdd)
Next
Local arraysPipelineMilliseconds:Int = MilliSecs() - started

Local sequencePipelineChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	sequencePipelineChecksum :+ Sequence<Int>.FromArray(values).Filter(BenchmarkEven).Map<Int>(BenchmarkTriple).Fold<Long>(Long(0), BenchmarkAdd)
Next
Local sequencePipelineMilliseconds:Int = MilliSecs() - started

Print "BRL.Arrays benchmark: " + VALUE_COUNT + " values x " + ITERATIONS
Print "Map hand loop / thin / Closure: " + directMapMilliseconds + " / " + thinMapMilliseconds + " / " + closureMapMilliseconds + " ms"
Print "Filter+Map+Fold hand / eager Arrays / fused Sequence: " + directPipelineMilliseconds + " / " + arraysPipelineMilliseconds + " / " + sequencePipelineMilliseconds + " ms"

If directMapChecksum <> thinMapChecksum Or directMapChecksum <> closureMapChecksum Then Throw "Map checksum mismatch"
If directPipelineChecksum <> arraysPipelineChecksum Or directPipelineChecksum <> sequencePipelineChecksum Then Throw "pipeline checksum mismatch"
