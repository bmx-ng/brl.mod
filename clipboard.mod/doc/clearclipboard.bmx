SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = CreateClipboard()

' empty the clipboard
ClearClipboard(clipboard)

print "content: ~q" + ClipboardText(clipboard) + "~q"

'output:
'content: ""
