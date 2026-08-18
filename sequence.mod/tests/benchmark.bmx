SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence
Import BRL.System

Const VALUE_COUNT:Int = 200000
Const ITERATIONS:Int = 100

Function DirectEven:Int(value:Int)
	Return (value & 1) = 0
End Function

Function DirectTriple:Int(value:Int)
	Return value * 3
End Function

Function DirectAdd:Long(total:Long, value:Int)
	Return total + value
End Function

Local values:Int[] = New Int[VALUE_COUNT]
For Local index:Int = 0 Until values.Length
	values[index] = index
Next

Local even:Closure<Int(value:Int)> = Function:Int(value:Int)
	Return (value & 1) = 0
End Function
Local triple:Closure<Int(value:Int)> = Function:Int(value:Int)
	Return value * 3
End Function
Local add:Closure<Long(total:Long, value:Int)> = Function:Long(total:Long, value:Int)
	Return total + value
End Function
Local sequence:Sequence<Int> = Sequence<Int>.FromArray(values).Filter(even).Map<Int>(triple).Take(VALUE_COUNT / 4)
Local prefix:Sequence<Int> = Sequence<Int>.FromArray(values).Take(VALUE_COUNT / 4)
Local filtered:Sequence<Int> = Sequence<Int>.FromArray(values).Filter(even).Take(VALUE_COUNT / 4)
Local mapped:Sequence<Int> = Sequence<Int>.FromArray(values).Map<Int>(triple).Take(VALUE_COUNT / 4)

' Warm the runtime and specialization registration before measuring.
Local warmup:Long = sequence.Fold<Long>(Long(0), add)

Local eagerChecksum:Long
Local started:Int = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local accepted:Int
	For Local value:Int = EachIn values
		If (value & 1) Then Continue
		eagerChecksum :+ Long(value * 3)
		accepted :+ 1
		If accepted = VALUE_COUNT / 4 Then Exit
	Next
Next
Local eagerMilliseconds:Int = MilliSecs() - started

' These component measurements distinguish fixed iterator allocation from the
' per-element costs of interface dispatch and managed closure calls.
Local prefixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	prefixCount :+ prefix.Count()
Next
Local iteratorMilliseconds:Int = MilliSecs() - started

Local filteredCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	filteredCount :+ filtered.Count()
Next
Local filterMilliseconds:Int = MilliSecs() - started

Local mappedChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	mappedChecksum :+ mapped.Fold<Long>(Long(0), add)
Next
Local mapMilliseconds:Int = MilliSecs() - started

Local materializedChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local filteredValues:Int[] = New Int[VALUE_COUNT / 2]
	Local materializedCount:Int
	For Local value:Int = EachIn values
		If (value & 1) = 0 Then filteredValues[materializedCount] = value; materializedCount :+ 1
	Next
	Local mappedValues:Int[] = New Int[materializedCount]
	For Local index:Int = 0 Until materializedCount
		mappedValues[index] = filteredValues[index] * 3
	Next
	For Local index:Int = 0 Until VALUE_COUNT / 4
		materializedChecksum :+ mappedValues[index]
	Next
Next
Local materializedMilliseconds:Int = MilliSecs() - started

Local sequenceChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	sequenceChecksum :+ sequence.Fold<Long>(Long(0), add)
Next
Local sequenceMilliseconds:Int = MilliSecs() - started

Local fusedSequenceChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	fusedSequenceChecksum :+ Sequence<Int>.FromArray(values).Filter(even).Map<Int>(triple).Take(VALUE_COUNT / 4).Fold<Long>(Long(0), add)
Next
Local fusedSequenceMilliseconds:Int = MilliSecs() - started

Local directClosureChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	directClosureChecksum :+ Sequence<Int>.FromArray(values).Filter(DirectEven).Map<Int>(DirectTriple).Take(VALUE_COUNT / 4).Fold<Long>(Long(0), DirectAdd)
Next
Local directClosureMilliseconds:Int = MilliSecs() - started

Print "BRL.Sequence benchmark: " + VALUE_COUNT + " source values x " + ITERATIONS + " enumerations"
Print "fused eager loop:       " + eagerMilliseconds + " ms"
Print "eager intermediate arrays: " + materializedMilliseconds + " ms"
Print "array + Take + Count:   " + iteratorMilliseconds + " ms (iterator dispatch, no closures)"
Print "Filter + Take + Count:  " + filterMilliseconds + " ms (adds predicate closure)"
Print "Map + Take + Fold:      " + mapMilliseconds + " ms (mapper and folder closures)"
Print "lazy Sequence pipeline: " + sequenceMilliseconds + " ms"
Print "compiler-fused Sequence:" + fusedSequenceMilliseconds + " ms"
Print "fused direct functions:  " + directClosureMilliseconds + " ms"
Print "checksums: " + eagerChecksum + ", " + materializedChecksum + ", " + sequenceChecksum + ", " + fusedSequenceChecksum + ", " + directClosureChecksum + " (warmup " + warmup + ")"

If eagerChecksum <> materializedChecksum Or eagerChecksum <> sequenceChecksum Or eagerChecksum <> fusedSequenceChecksum Or eagerChecksum <> directClosureChecksum Then Throw "benchmark checksum mismatch"
If prefixCount <> (VALUE_COUNT / 4) * ITERATIONS Then Throw "prefix count mismatch"
If filteredCount <> (VALUE_COUNT / 4) * ITERATIONS Then Throw "filtered count mismatch"
If mappedChecksum <> Long(3749925000) * ITERATIONS Then Throw "mapped checksum mismatch"
