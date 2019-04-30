SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = CreateClipboard()

' print out currently hold text
print "current: " + ClipboardText(clipboard)

' try to set a new text
If ClipboardSetText(clipboard, "TEST") Then
	print "set: " + ClipboardText(clipboard)
EndIf