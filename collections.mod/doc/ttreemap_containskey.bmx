SuperStrict

Framework brl.collections
Import brl.standardio

Local openWith:TTreeMap<String, String> = New TTreeMap<String, String>

openWith.Add("txt", "notepad.exe")
openWith.Add("bmp", "paint.exe")
openWith.Add("dib", "paint.exe")
openWith.Add("rtf", "wordpad.exe")

Print "Keys:"
For Local key:String = EachIn openWith.Keys()
	Print key
Next

Print "~nopenWith.ContainsKey(~qbmp~q) : " + openWith.ContainsKey("bmp")
Print "~nopenWith.ContainsKey(~qjpg~q) : " + openWith.ContainsKey("jpg")
