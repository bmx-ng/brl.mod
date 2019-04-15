SuperStrict

Framework brl.standardio
Import brl.geometry

Local a:SVec2 = New SVec2(12, 2)
Local b:SVec2 = New SVec2(4, 5)

Local c:SVec2 = a - b

Print c.ToString() ' 8, -3
