'
' Trim a string builder
'
SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder

sb.Append("  ~t~nHello World!~t~t~r ")

Print "'" + sb.Trim().ToString() + "'"





