SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = New TClipboard.Create()

' print out currently hold text
print "current: " + clipboard.Text()

' try to set a new text
If clipboard.SetText("TEST") Then
	print "set: " + clipboard.Text()
EndIf