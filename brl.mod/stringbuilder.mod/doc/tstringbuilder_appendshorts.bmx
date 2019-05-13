SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local shorts:Short[] = [65, 66, 67, 68, 69, 70]

sb.AppendShorts(shorts, shorts.length)

Print sb.ToString()
