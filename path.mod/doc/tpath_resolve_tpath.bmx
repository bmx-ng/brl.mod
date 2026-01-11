SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath("/a/b")

Local rel:TPath = New TPath("c/d")
Local rooted:TPath = New TPath("/x/y")

Print base.Resolve(rel).ToString()    ' /a/b/c/d
Print base.Resolve(rooted).ToString() ' /x/y
