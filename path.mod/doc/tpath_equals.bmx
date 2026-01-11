SuperStrict

Framework brl.standardio
Import BRL.Path

Local a:TPath = New TPath("a/b/")
Local b:TPath = New TPath("a\b")

Print a.Equals(b) ' True
