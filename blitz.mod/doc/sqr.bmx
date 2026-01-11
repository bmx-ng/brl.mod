Rem
Square root of x
End Rem

SuperStrict

Framework BRL.StandardIO


Function Length:Double(x:Double,y:Double)
	Return Sqr(x*x+y*y)
End Function

Print "The length of the vector 25,3 is "+Length(25,3)
