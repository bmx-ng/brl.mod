SuperStrict

For Local f:Float=-0.4 Until 0.4 Step 0.2
    If IsNan(Sqr(f)) Then
       Print "Square Root of "+f+" is not a real number"
    Else
       Print "Square Root of  "+f+" = "+Sqr(f)
    EndIf
Next

' ===================
' Output
' Square Root of -0.400000006 is not a real number
' Square Root of -0.200000003 is not a real number
' Square Root of  0.000000000 = 0.00000000000000000
' Square Root of  0.200000003 = 0.44721359883195888
