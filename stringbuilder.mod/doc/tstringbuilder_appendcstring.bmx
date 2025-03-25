SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder()

Local b:Byte Ptr = "Hello World".ToCString()

sb.AppendCString(b)

MemFree(b)

Print sb.ToString()
