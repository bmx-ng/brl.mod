SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = New TClipboard.Create()

' clipboard mode can be:
' LCB_CLIPBOARD = The primary (global) clipboard [default mode]
' LCB_PRIMARY = The (global) mouse selection clipboard.
' LCB_SECONDARY = The largely unused (global) secondary selection clipboard.
Local clipboardMode:Int = LCB_CLIPBOARD
' variable to hold text length when fetching text with TextEx()
Local textLength:Int

' try to set a new text
If clipboard.SetTextEx("TEST", clipboardMode) Then
	Print clipboard.TextEx(textLength, clipboardMode)
	Print "length of clipboard content: " + textLength
EndIf

'output:
'TEST
'length of clipboard content: 4