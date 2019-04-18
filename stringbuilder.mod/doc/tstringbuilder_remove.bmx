SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("Hello World!")

sb.Remove(2, 9)

Print sb.ToString()
