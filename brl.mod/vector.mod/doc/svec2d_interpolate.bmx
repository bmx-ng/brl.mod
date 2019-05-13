SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(-6, 8)
Local b:SVec2D = New SVec2D(5, 12)

Print a.Interpolate(b, 0).ToString() ' -6, 8
Print a.Interpolate(b, 1).ToString() ' 5, 12
Print a.Interpolate(b, 0.5).ToString() ' -0.5, 10
