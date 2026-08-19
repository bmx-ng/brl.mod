SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence
Import BRL.System

Const VALUE_COUNT:Int = 200000
Const ITERATIONS:Int = 50

Function ExpandPair:Sequence<Int>(value:Int)
	Return Sequence<Int>.FromArray([value, value * 2])
End Function

Function BelowHalf:Int(value:Int)
	Return value < VALUE_COUNT / 2
End Function

Function Add:Long(total:Long, value:Int)
	Return total + value
End Function

Local values:Int[] = New Int[VALUE_COUNT]
For Local index:Int = 0 Until values.Length
	values[index] = index
Next

' Warm the relevant generic specializations before measuring.
Sequence<Int>.FromArray(values).FlatMap<Int>(ExpandPair).Take(2).Count()
Sequence<Int>.FromArray(values).TakeWhile(BelowHalf).Count()
Sequence<Int>.FromArray(values).SkipWhile(BelowHalf).Count()

Local eagerFlatChecksum:Long
Local started:Int = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	For Local value:Int = EachIn values
		eagerFlatChecksum :+ value
		eagerFlatChecksum :+ value * 2
	Next
Next
Local eagerFlatMilliseconds:Int = MilliSecs() - started

Local lazyFlatChecksum:Long
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	lazyFlatChecksum :+ Sequence<Int>.FromArray(values).FlatMap<Int>(ExpandPair).Fold<Long>(Long(0), Add)
Next
Local lazyFlatMilliseconds:Int = MilliSecs() - started

Local eagerPrefixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	For Local value:Int = EachIn values
		If Not BelowHalf(value) Then Exit
		eagerPrefixCount :+ 1
	Next
Next
Local eagerPrefixMilliseconds:Int = MilliSecs() - started

Local storedTakeWhile:Sequence<Int> = Sequence<Int>.FromArray(values).TakeWhile(BelowHalf)
Local storedPrefixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	storedPrefixCount :+ storedTakeWhile.Count()
Next
Local storedPrefixMilliseconds:Int = MilliSecs() - started

Local fusedPrefixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	fusedPrefixCount :+ Sequence<Int>.FromArray(values).TakeWhile(BelowHalf).Count()
Next
Local fusedPrefixMilliseconds:Int = MilliSecs() - started

Local eagerSuffixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	Local skipping:Int = True
	For Local value:Int = EachIn values
		If skipping And BelowHalf(value) Then Continue
		skipping = False
		eagerSuffixCount :+ 1
	Next
Next
Local eagerSuffixMilliseconds:Int = MilliSecs() - started

Local storedSkipWhile:Sequence<Int> = Sequence<Int>.FromArray(values).SkipWhile(BelowHalf)
Local storedSuffixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	storedSuffixCount :+ storedSkipWhile.Count()
Next
Local storedSuffixMilliseconds:Int = MilliSecs() - started

Local fusedSuffixCount:Int
started = MilliSecs()
For Local iteration:Int = 0 Until ITERATIONS
	fusedSuffixCount :+ Sequence<Int>.FromArray(values).SkipWhile(BelowHalf).Count()
Next
Local fusedSuffixMilliseconds:Int = MilliSecs() - started

Print "BRL.Sequence second-tier benchmark: " + VALUE_COUNT + " values x " + ITERATIONS
Print "FlatMap eager / lazy:       " + eagerFlatMilliseconds + " / " + lazyFlatMilliseconds + " ms"
Print "TakeWhile eager/stored/fused: " + eagerPrefixMilliseconds + " / " + storedPrefixMilliseconds + " / " + fusedPrefixMilliseconds + " ms"
Print "SkipWhile eager/stored/fused: " + eagerSuffixMilliseconds + " / " + storedSuffixMilliseconds + " / " + fusedSuffixMilliseconds + " ms"

If eagerFlatChecksum <> lazyFlatChecksum Then Throw "FlatMap checksum mismatch"
If eagerPrefixCount <> storedPrefixCount Or eagerPrefixCount <> fusedPrefixCount Then Throw "TakeWhile count mismatch"
If eagerSuffixCount <> storedSuffixCount Or eagerSuffixCount <> fusedSuffixCount Then Throw "SkipWhile count mismatch"
