SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = New TClipboard.Create()

' try to set a new text
If clipboard.SetText("TEST") Then
	Print clipboard.Text()
EndIf

'output:
'TEST