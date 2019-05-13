'
' Split a string buffer
'
SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

sb.Append("One Two Three Four Five Six Seven Eight Nine Ten")

Local split:TSplitBuffer = sb.Split(" ")

'Print split.Length()
For Local i:Int = 0 Until split.Length()
	Print split.Text(i)
Next


