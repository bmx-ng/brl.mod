'
' Join a string array to a string builder
'
SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder


Local strings:String[] = ["one", "two", "three", "four", "five"]

sb.Append(" ")

Local sb2:TStringBuilder = sb.Join(strings)


Print sb2.ToString()


