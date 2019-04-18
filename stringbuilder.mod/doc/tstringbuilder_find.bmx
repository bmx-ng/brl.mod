SuperStrict

Framework BRL.StringBuilder
Import brl.standardio

Local sb:TStringBuilder = New TStringBuilder("one two three four five six seven")

Print sb.Find("w") ' 5
Print sb.Find("z") ' -1
Print sb.Find("e", 4) ' 11
