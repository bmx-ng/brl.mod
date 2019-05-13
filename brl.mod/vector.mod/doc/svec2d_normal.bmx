SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(10, 0)

Local b:SVec2D = a.Normal()

Print b.ToString() ' 1, 0
