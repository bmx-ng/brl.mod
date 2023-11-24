SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local t:TMyType = New TMyType

sb.Append(t)

Print sb.ToString()

Type TMyType

	Method ToString:String()
		Return "Hello World!"
	End Method

End Type
