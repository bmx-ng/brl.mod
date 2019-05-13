' Rand.bmx
' Toss a pair of dice. Result is in the range 1+1 to 6+6.
' Count how many times each result appears.

SuperStrict

Local count:Int[13]

For Local n:Int = 1 To 3600
    Local toss:Int = Rand(1,6) + Rand(1,6)
    count[toss] :+ 1
Next

For Local toss:Int = 2 To 12
    Print LSet(toss, 5)+count[toss]
Next
