SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath("/a/b")

Local p1:TPath = base.Resolve("c/d")
Local p2:TPath = base.Resolve("/x/y")

Print p1.ToString() ' /a/b/c/d
Print p2.ToString() ' /x/y
