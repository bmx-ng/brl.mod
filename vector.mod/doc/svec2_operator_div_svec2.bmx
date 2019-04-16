SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2 = New SVec2(10, 18)
Local b:SVec2 = New SVec2(5, 6)

Local c:SVec2 = a / b

Print c.ToString() ' 2, 3
