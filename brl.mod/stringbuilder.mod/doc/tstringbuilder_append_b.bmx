SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local bytes:Byte[] = [0, 1, 2, 3, 4, 5]

For Local b:Byte = EachIn bytes
	sb.Append(b).Append(",")
Next

Print sb.ToString()
