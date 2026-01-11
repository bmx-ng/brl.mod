SuperStrict

Framework brl.standardio
Import BRL.Path

Local a:TPath = New TPath("a/b")
Local b:TPath = New TPath("a/c")

Print a.Compare(b) ' negative value
Print b.Compare(a) ' positive value
Print a.Compare(a) ' 0
