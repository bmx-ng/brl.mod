SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2 = New SVec2(2, 3)
Local b:SVec2 = New SVec2(5, 6)

Local c:SVec2 = a * b

Print c.ToString() ' 10, 18
