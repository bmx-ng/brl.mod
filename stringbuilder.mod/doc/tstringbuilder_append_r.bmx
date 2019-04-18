SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

sb.Append("Hello")
sb.Append(" ")
sb.Append("World")

Print sb.ToString()
