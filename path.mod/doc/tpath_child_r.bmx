SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("src")
Local q:TPath = p.Child("main.bmx")

Print q.ToString() ' src/main.bmx
