SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2 = New SVec2(3, 2)
Local b:SVec2 = New SVec2(-2, 1)

Local c:SVec2 = a + b

Print c.ToString() ' 1, 3
