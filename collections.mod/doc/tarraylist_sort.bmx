SuperStrict

Framework brl.collections
Import brl.standardio
Import brl.Random

SeedRnd(42)

Local numbers:TArrayList<Int> = New TArrayList<Int>

For Local i:Int = 0 Until 20
	numbers.Add(Rand(0, 100))
Next

Print "Unsorted:"
For Local num:String = EachIn numbers
	Print num
Next

numbers.Sort()

Print "~nSorted:"
For Local num:String = EachIn numbers
	Print num
Next

Local reverse:TReverseComparator<Int> = New TReverseComparator<Int>

numbers.Sort(reverse)

Print "~nReversed:"
For Local num:String = EachIn numbers
	Print num
Next

Type TReverseComparator<T> Implements IComparator<T>

	Method Compare:Int(a:T, b:T)
		Return DefaultComparator_Compare(b, a)
	End Method

End Type
