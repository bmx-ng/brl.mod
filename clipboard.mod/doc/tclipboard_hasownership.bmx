SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = new TClipboard.Create()

' clipboard mode can be:
' LCB_CLIPBOARD = The primary (global) clipboard [default mode]
' LCB_SELECTION = The (global) mouse selection clipboard.
Local clipboardMode:int = LCB_CLIPBOARD

If clipboard.HasOwnerShip(clipboardMode)
	print "clipboard content created by us"
Else
	print "clipboard content of another application"
EndIf
