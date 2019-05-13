SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("  Hello World!~t~t ")

sb.Trim()

Print sb.ToString()
