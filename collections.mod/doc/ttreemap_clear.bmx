SuperStrict

Framework brl.collections
Import brl.standardio

Local openWith:TTreeMap<String, String> = New TTreeMap<String, String>

openWith.Add("txt", "notepad.exe")
openWith.Add("bmp", "paint.exe")
openWith.Add("dib", "paint.exe")
openWith.Add("rtf", "wordpad.exe")

Print "openWith.Count() : " + openWith.Count()

Print "~nopenWith.Clear()"
openWith.Clear()

Print "~nopenWith.Count() : " + openWith.Count()
