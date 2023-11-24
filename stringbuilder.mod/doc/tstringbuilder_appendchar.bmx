SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local chars:Int[] = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33]

For Local c:Int = EachIn chars
	sb.AppendChar(c)
Next

Print sb.ToString()
