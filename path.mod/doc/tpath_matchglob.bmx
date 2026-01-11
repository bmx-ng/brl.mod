SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("/path/to/sub/file.txt")

Print p.MatchGlob("*.txt")       ' True (pattern matches only the name segment)
Print p.MatchGlob("sub/*.txt")   ' True (matches trailing segments)
Print p.MatchGlob("sub/*.bmx")   ' False
