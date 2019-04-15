SuperStrict

Framework brl.standardio
Import brl.geometry

Local a:SVec2 = New SVec2(-6, 8)
Local b:SVec2 = New SVec2(5, 12)

Print a.Lerp(b, 0).ToString() ' -6, 8
Print a.Lerp(b, 1).ToString() ' 5, 12
Print a.Lerp(b, 0.5).ToString() ' -0.5, 10
