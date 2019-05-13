SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local values:UInt[] = [2, 4, 6, 8, 10]

For Local value:UInt = EachIn values
	sb.Append(value).AppendNewLine()
Next

Print sb.ToString()
