SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder(", ")

Local values:String[] = ["one", "two", "three", "four", "five", "six"]

Local joined:TStringBuilder = sb.Join(values)

Print joined.ToString()
