SuperStrict

Framework brl.standardio
Import BRL.Path

Local src:TPath = New TPath("src")
Local main:TPath = New TPath("main.bmx")
Local q:TPath = src.Child(main)

Print q.ToString() ' src/main.bmx
