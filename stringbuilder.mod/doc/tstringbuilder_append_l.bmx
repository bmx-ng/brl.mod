SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local num:Long = 100000000:Long * 9876
sb.Append(num).AppendNewLine()
sb.Append(num * 99)

Print sb.ToString()
