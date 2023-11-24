SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local x:Double = 35.7
Local y:Double = 40.1

sb.Append(x)
sb.Append(", ")
sb.Append(y)

Print sb.ToString()
