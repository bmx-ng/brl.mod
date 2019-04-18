SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(3, 2)
Local b:SVec2D = New SVec2D(-2, 1)

Local c:SVec2D = a + b

Print c.ToString() ' 1, 3
