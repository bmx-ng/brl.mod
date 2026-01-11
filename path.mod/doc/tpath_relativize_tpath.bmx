SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("/a/b")
Local q:TPath = New TPath("/a/b/c/d")

Local r:TPath = p.Relativize(q)

Print r.ToString() ' c/d
