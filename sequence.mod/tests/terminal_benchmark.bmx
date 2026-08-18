SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence
Import BRL.System

Const VALUE_COUNT:Int = 200000
Const ITERATIONS:Int = 100
Const RESULT_COUNT:Int = VALUE_COUNT / 4

Global VisitChecksum:Long

Function DirectEven:Int(value:Int)
	Return (value & 1) = 0
End Function

Function DirectTriple:Int(value:Int)
	Return value * 3
End Function

Function DirectVisit(value:Int)
	VisitChecksum :+ value
End Function

Local values:Int[] = New Int[VALUE_COUNT]
For Local index:Int = 0 Until values.Length
	values[index] = index
Next

Local query:Sequence<Int> = Sequence<Int>.FromArray(values).Filter(DirectEven).Map<Int>(DirectTriple).Take(RESULT_COUNT)
Local firstQuery:Sequence<Int> = Sequence<Int>.FromArray(values).Filter(DirectEven).Skip(RESULT_COUNT)

' Warm specialization and runtime paths before measuring.
query.FirstOrNone()
query.ForEach(DirectVisit)
query.ToArray()
VisitChecksum = 0

Local started:Int = MilliSecs()
Local eagerFirstChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local accepted:Int
	For Local value:Int = EachIn values
		If (value & 1) Then Continue
		If accepted = RESULT_COUNT Then eagerFirstChecksum :+ value; Exit
		accepted :+ 1
	Next
Next
Local eagerFirstMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local lazyFirstChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	lazyFirstChecksum :+ firstQuery.FirstOrNone().Value()
Next
Local lazyFirstMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local fusedFirstChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	fusedFirstChecksum :+ Sequence<Int>.FromArray(values).Filter(DirectEven).Skip(RESULT_COUNT).FirstOrNone().Value()
Next
Local fusedFirstMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local eagerLastChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local accepted:Int
	Local last:Int
	For Local value:Int = EachIn values
		If (value & 1) Then Continue
		last = value * 3
		accepted :+ 1
		If accepted = RESULT_COUNT Then Exit
	Next
	eagerLastChecksum :+ last
Next
Local eagerLastMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local lazyLastChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	lazyLastChecksum :+ query.LastOrNone().Value()
Next
Local lazyLastMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local fusedLastChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	fusedLastChecksum :+ Sequence<Int>.FromArray(values).Filter(DirectEven).Map<Int>(DirectTriple).Take(RESULT_COUNT).LastOrNone().Value()
Next
Local fusedLastMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local eagerForEachChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local accepted:Int
	For Local value:Int = EachIn values
		If (value & 1) Then Continue
		eagerForEachChecksum :+ value * 3
		accepted :+ 1
		If accepted = RESULT_COUNT Then Exit
	Next
Next
Local eagerForEachMilliseconds:Int = MilliSecs() - started

VisitChecksum = 0
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	query.ForEach(DirectVisit)
Next
Local lazyForEachMilliseconds:Int = MilliSecs() - started
Local lazyForEachChecksum:Long = VisitChecksum

VisitChecksum = 0
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Sequence<Int>.FromArray(values).Filter(DirectEven).Map<Int>(DirectTriple).Take(RESULT_COUNT).ForEach(DirectVisit)
Next
Local fusedForEachMilliseconds:Int = MilliSecs() - started
Local fusedForEachChecksum:Long = VisitChecksum

started = MilliSecs()
Local eagerArrayChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = New Int[RESULT_COUNT]
	Local accepted:Int
	For Local value:Int = EachIn values
		If (value & 1) Then Continue
		result[accepted] = value * 3
		accepted :+ 1
		If accepted = RESULT_COUNT Then Exit
	Next
	eagerArrayChecksum :+ result.Length + result[0] + result[result.Length - 1]
Next
Local eagerArrayMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local lazyArrayChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = query.ToArray()
	lazyArrayChecksum :+ result.Length + result[0] + result[result.Length - 1]
Next
Local lazyArrayMilliseconds:Int = MilliSecs() - started

started = MilliSecs()
Local fusedArrayChecksum:Long
For Local iteration:Int = 0 Until ITERATIONS
	Local result:Int[] = Sequence<Int>.FromArray(values).Filter(DirectEven).Map<Int>(DirectTriple).Take(RESULT_COUNT).ToArray()
	fusedArrayChecksum :+ result.Length + result[0] + result[result.Length - 1]
Next
Local fusedArrayMilliseconds:Int = MilliSecs() - started

Print "BRL.Sequence terminal benchmark: " + VALUE_COUNT + " source values x " + ITERATIONS
Print "FirstOrNone eager / stored / fused: " + eagerFirstMilliseconds + " / " + lazyFirstMilliseconds + " / " + fusedFirstMilliseconds + " ms"
Print "LastOrNone  eager / stored / fused: " + eagerLastMilliseconds + " / " + lazyLastMilliseconds + " / " + fusedLastMilliseconds + " ms"
Print "ForEach     eager / stored / fused: " + eagerForEachMilliseconds + " / " + lazyForEachMilliseconds + " / " + fusedForEachMilliseconds + " ms"
Print "ToArray     eager / stored / fused: " + eagerArrayMilliseconds + " / " + lazyArrayMilliseconds + " / " + fusedArrayMilliseconds + " ms"

If eagerFirstChecksum <> lazyFirstChecksum Or eagerFirstChecksum <> fusedFirstChecksum Then Throw "FirstOrNone checksum mismatch"
If eagerLastChecksum <> lazyLastChecksum Or eagerLastChecksum <> fusedLastChecksum Then Throw "LastOrNone checksum mismatch"
If eagerForEachChecksum <> lazyForEachChecksum Or eagerForEachChecksum <> fusedForEachChecksum Then Throw "ForEach checksum mismatch"
If eagerArrayChecksum <> lazyArrayChecksum Or eagerArrayChecksum <> fusedArrayChecksum Then Throw "ToArray checksum mismatch"
