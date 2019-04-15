SuperStrict

Framework brl.standardio
Import brl.geometry

Local a:SVec2 = New SVec2(10, 0)

Local b:SVec2= a.Normal()

Print b.ToString() ' 1, 0
