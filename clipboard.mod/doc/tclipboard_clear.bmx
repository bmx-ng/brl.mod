SuperStrict

Framework Brl.Clipboard
Import Brl.StandardIO

' create a clipboard manager to access the system wide clipboard
Local clipboard:TClipboard = new TClipboard.Create()

' empty the clipboard
clipboard.Clear()

print "content: ~q" + clipboard.Text() + "~q"

'output:
'content: ""
