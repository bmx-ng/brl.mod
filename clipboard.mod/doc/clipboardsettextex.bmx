SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = CreateClipboard()


' clipboard mode can be:
' LCB_CLIPBOARD = The primary (global) clipboard [default mode]
' LCB_SELECTION = The (global) mouse selection clipboard.
Local clipboardMode:Int = LCB_CLIPBOARD
' variable to hold text length when fetching text with TextEx()
Local textLength:Int

' try to set a new text
If ClipboardSetTextEx(clipboard, "TEST", clipboardMode) Then
	Print ClipboardTextEx(clipboard, textLength, clipboardMode)
	Print "length of clipboard content: " + textLength
EndIf

'output:
'TEST
'length of clipboard content: 4