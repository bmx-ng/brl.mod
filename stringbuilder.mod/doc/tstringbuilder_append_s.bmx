SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local x:Short = 100
Local y:Short = 55

sb.Append(x).Append(", ").Append(y)

Print sb.ToString()
