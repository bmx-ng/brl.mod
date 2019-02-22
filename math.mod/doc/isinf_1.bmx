SuperStrict

For Local f:Float = - 0.4 Until 0.4 Step 0.2
	If IsInf(Log(f) ) Then
		Print "Log(" + f + ")=Infinity "+Log(f)
	Else If IsNan(Log(f) ) Then
		Print "Log(" + f + ") is not a real number "+Log(f)
	Else
		Print "Log(" + f + ")=" + Log(f) 
   End If
Next

' ===================
' Output
' Log(-0.400000006) is not a real number -1.#IND000000000000
' Log(-0.200000003) is not a real number -1.#IND000000000000
' Log(0.000000000)=Infinity -1.#INF000000000000
' Log(0.200000003)=-1.6094378975329393
