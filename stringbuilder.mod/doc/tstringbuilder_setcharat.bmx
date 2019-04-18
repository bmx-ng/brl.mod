SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("Hello World!")

sb.SetCharAt(3, Asc("p"))
sb.SetCharAt(4, Asc(","))

Print sb.ToString()
