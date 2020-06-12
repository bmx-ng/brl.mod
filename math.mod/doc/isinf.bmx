SuperStrict

For Local f:Float=-0.4 Until 0.4 Step 0.2
    If IsInf(1.0 / f) Then
       Print "Divide by Zero"
    Else
       Print "inverse of "+f+" = "+String(1.0/f)
    EndIf
Next

' ===================
' Output
' inverse of -0.400000006 = -2.50000000
' inverse of -0.200000003 = -5.00000000
' Divide by Zero
' inverse of 0.200000003 = 5.00000000
