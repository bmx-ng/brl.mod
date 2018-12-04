' Rnd.bmx
' Use Rnd() to estimate area inside the unit circle x^2 + y^2 = 1.

SuperStrict

Local totalpoints:Int = 1000000
Local inpoints:Int

For Local n:Int = 1 To totalpoints
    Local x:Double = Rnd( -1.0, 1.0 )               ' Generate random point in 2 by 2 square.
    Local y:Double = Rnd( -1.0, 1.0 )

    If x*x + y*y < 1.0 Then inpoints :+ 1     ' point is inside the circle
Next

' Note: Ratio of areas circle/square is exactly Pi/4.

Print "Estimated area = " + ( 4.0 * Double(inpoints)/Double(totalpoints) )
Print
Print "    Exact area = " + Pi     '  4 * Pi/4, compare with estimate

