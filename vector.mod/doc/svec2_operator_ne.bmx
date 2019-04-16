SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2 = New SVec2(4, 5)
Local b:SVec2 = New SVec2(3, 6)
Local c:SVec2 = New SVec2(4, 5)

Print a <> b ' true
Print a <> c ' false
