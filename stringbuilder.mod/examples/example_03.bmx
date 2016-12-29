'
' Insert text into a string builder
'
SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

sb.Append("Hello World!")

sb.Insert(6, "New ")

Print sb.ToString()

