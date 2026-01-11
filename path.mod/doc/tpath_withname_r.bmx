SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("src/main.bmx")

Local q:TPath = p.WithName("app.bmx")

Print p.ToString() ' src/main.bmx
Print q.ToString() ' src/app.bmx
