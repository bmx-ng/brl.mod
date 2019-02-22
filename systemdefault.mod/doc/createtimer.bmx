Rem
The following BlitzMax program prints a new line to the console 5 times a second.
End Rem

' testtimer.bmx
SuperStrict

Local t:TTimer = CreateTimer(5)
Local frame:Int = 0

For Local i:Int = 1 To 10
	WaitTimer(t)
	Print frame
	frame:+1
Next
