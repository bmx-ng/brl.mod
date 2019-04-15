SuperStrict

Framework brl.standardio
Import brl.geometry

Local a:SVec2 = New SVec2(12, 8)
Local b:SVec2 = New SVec2(10, 16)


Local c:SVec2 = a.Min(b)

Print c.ToString() ' 10, 8
