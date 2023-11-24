SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local a:Int = 5
Local b:Int = 6

sb.Append(a).Append(" + ").Append(b)
sb.Append(" = ").Append(a + b)

Print sb.ToString()
