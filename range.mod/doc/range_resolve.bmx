SuperStrict

Framework BRL.StandardIO
Import BRL.Range

Local selected:Range = ^5..^2
Local coordinates:ResolvedRange = selected.Resolve(10)

Print coordinates.Start()        ' 5
Print coordinates.EndExclusive() ' 8
Print coordinates.Length()       ' 3
