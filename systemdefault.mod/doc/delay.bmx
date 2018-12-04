Rem
The following BlitzMax program prints a new line to the console 10 times a second.
End Rem

' testtimer.bmx

SuperStrict

For i:Int = 1 To 10
	Print i
	i:+1
	Delay 100
Next
