SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2 = New SVec2(0, 0)
Local b:SVec2 = New SVec2(10, 5)

Local v:SVec2 = New SVec2(11, -2)


Local c:SVec2 = v.Clamp(a, b)

Print c.ToString() ' 10, 0
