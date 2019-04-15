SuperStrict

Framework brl.standardio
Import brl.geometry

Local a:SVec2 = New SVec2(5, 0)
Local b:SVec2 = New SVec2(0, 10)

Local c:SVec2 = a.Reflect(b)

Print c.ToString() ' -5, 0
