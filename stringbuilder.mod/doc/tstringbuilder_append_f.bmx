SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local x:Float = 35.7
Local y:Float = 40.1

sb.Append(x)
sb.Append(", ")
sb.Append(y)

Print sb.ToString()
