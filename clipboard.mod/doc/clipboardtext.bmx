SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = CreateClipboard()

' try to set a new text
If ClipboardSetText(clipboard, "TEST") Then
	Print ClipboardText(clipboard)
EndIf

'output:
'TEST