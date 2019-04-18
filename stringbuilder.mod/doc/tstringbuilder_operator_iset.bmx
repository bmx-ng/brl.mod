SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("Hello World!")

sb[3] = Asc("p")
sb[4] = Asc(",")

Print sb.ToString()
