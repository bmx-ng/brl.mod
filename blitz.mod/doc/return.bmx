Rem
Return exits a BlitzMax function or method with an optional value.
The type of return value is dictated by the type of the function.
End Rem

SuperStrict

Function CrossProduct:Float(x0:Float,y0:Float,z0:Float,x1:Float,y1:Float,z1:Float)
	Return x0*x1+y0*y1+z0*z1
End Function

Print "(0,1,2)x(2,3,4)="+CrossProduct(0,1,2,2,3,4)

Function LongRand:Long()
	Return (Rand($80000000,$7fffffff) Shl 32)|(Rand($80000000,$7fffffff))
End Function

Print "LongRand()="+LongRand()
Print "LongRand()="+LongRand()
