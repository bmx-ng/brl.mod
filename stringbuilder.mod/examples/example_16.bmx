'
' Append an array of shorts to a string builder
'
SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

sb.Append("Shorts!... ")

Local shorts:Short[10]
' characters A to J
For Local i:Int = 0 Until shorts.length
	shorts[i] = 65 + i
Next

sb.AppendShorts(shorts, shorts.length)

Print sb.ToString()




