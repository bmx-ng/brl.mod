SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("/a/b/c")
Local q:TPath = New TPath("/a/d/e")

Local r:TPath = p.Relativize(q)

Print r.ToString() ' ../../d/e
