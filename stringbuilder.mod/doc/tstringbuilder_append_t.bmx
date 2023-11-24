SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

Local s:Size_T = 32684

sb.Append(s).Append(" ^ 2 = ")
sb.Append(Size_T(s ^ 2))

Print sb.ToString()
