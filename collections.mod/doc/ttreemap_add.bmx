SuperStrict

Framework brl.collections
Import brl.standardio

Local openWith:TTreeMap<String, String> = New TTreeMap<String, String>

openWith.Add("txt", "notepad.exe")
openWith.Add("bmp", "paint.exe")
openWith.Add("dib", "paint.exe")
openWith.Add("rtf", "wordpad.exe")

Try
	openWith.Add("txt", "winword.exe")
Catch e:TArgumentException
	Print "An element with Key txt' already exists."
End Try
