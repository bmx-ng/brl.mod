SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local a:ULong = 900
Local b:ULong = 7400

sb.Append(a).Append(", ").Append(b)

Print sb.ToString()
