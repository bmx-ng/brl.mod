SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("Hello World!")

sb.Insert(6, "BlitzMax ")

Print sb.ToString()
