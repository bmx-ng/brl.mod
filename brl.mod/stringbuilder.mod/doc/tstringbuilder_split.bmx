SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("1,2,3,4,5,6,7,8,9,10")

For Local s:String = EachIn sb.Split(",")
	Print s
Next
