SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("one two three four five six seven")

Print sb.FindLast("w") ' 5
Print sb.FindLast("z") ' -1
Print sb.FindLast("w", 30) ' -1 

