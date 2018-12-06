SuperStrict

For Local f:Float = - 0.4 Until 0.41 Step 0.2
	If IsInf(Log10(f) ) Then
	Print "Log10(" + f + ")=Infinity "+Log10(f)
	Else If IsNan(Log10(f) ) Then
		Print "Log10(" + f + ") is not a real number "+Log10(f)
	Else
		Print "Log10(" + f + ")=" + Log10(f) 
   End If
Next

' ===================
' Output
' Log10(-0.400000006) is not a real number -1.#IND000000000000
' Log10(-0.200000003) is not a real number -1.#IND000000000000
' Log10(0.000000000)=Infinity -1.#INF000000000000
' Log10(0.200000003)=-0.69896999786452674
' Log10(0.400000006)=-0.39794000220054560
