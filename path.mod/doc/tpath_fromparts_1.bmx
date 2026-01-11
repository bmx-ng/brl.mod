SuperStrict

Framework brl.standardio
Import BRL.Path

Local a:TPath = New TPath("src")
Local p:TPath = TPath.FromParts([a, Object("core"), Object("main.bmx")])

Print p.ToString() ' src/core/main.bmx
