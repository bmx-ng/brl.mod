SuperStrict

Framework brl.standardio
Import BRL.StringBuilder
Import BRL.uuid

For Local i:Int = 0 Until 5
	Local bytes:Byte[] = uuidGenerateBytes()
	Local sb:TStringBuilder = New TStringBuilder
	For Local n:Int = 0 Until bytes.length
		If n Then
			sb.Append(",")
		End If
		sb.Append(bytes[n])
	Next
	Print sb.ToString()
Next
