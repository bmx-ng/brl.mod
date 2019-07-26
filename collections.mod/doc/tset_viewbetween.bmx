SuperStrict

Framework brl.collections
Import brl.standardio

Local data:Int[] = [3, 4, 5, 6, 8, 9]

Local numbers:TSet<Int> = New TSet<Int>(data)
Print "numbers.Count : " + numbers.Count()

For Local num:Int = EachIn numbers
	Print num
Next

Print "~nSubset(5, 8)"
Local subset:TSet<Int> = numbers.ViewBetween(5, 8)
Print "Count : " + subset.Count()

For Local num:Int = EachIn subset
	Print num
Next

Print "~nsubset.Add(7)"
subset.Add(7)

Print "~nSubset(5, 8)"
Print "Count : " + subset.Count()

For Local num:Int = EachIn subset
	Print num
Next

Print "~nnumbers.Count : " + numbers.Count()

Print "~nSub-Subset(6, 7)"
Local subsubSet:TSet<Int> = subset.ViewBetween(6, 7)
Print "Count : " + subsubSet.Count()

For Local num:Int = EachIn subsubSet
	Print num
Next

Print "~nsubsubSet.Remove(6)"
subsubSet.Remove(6)

Print "numbers.Count : " + numbers.Count()

For Local num:Int = EachIn numbers
	Print num
Next

Print "~nSubset(5, 8)"
Print "Count : " + subset.Count()

For Local num:Int = EachIn subset
	Print num
Next

Print "~nSub-Subset(6, 7)"
Print "Count : " + subsubSet.Count()

For Local num:Int = EachIn subsubSet
	Print num
Next
