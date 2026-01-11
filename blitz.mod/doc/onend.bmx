' onend.bmx

SuperStrict

Framework BRL.StandardIO


Function cleanup()
	Print "cleaning up"
End Function

OnEnd cleanup
Print "program running"
End	'the cleanup function will be called at this time
