SuperStrict

'Maximum allowable Timer is 16
Global timers:TTimer[500]

For Local n:Int = 0 Until 18
	timers[n] = CreateTimer(1)
	If timers[n] = Null
		Print "Cannot create timer "+n
	Else
		Print "Successfully created timer "+n
	EndIf
Next
