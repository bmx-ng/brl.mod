SuperStrict

Framework BRL.StandardIO
Import BRL.Range

Local selected:Range = Range.FromUntil(-3, 20)
Local coordinates:ResolvedRange = selected.Clamp(10)

Print coordinates.Start()        ' 0
Print coordinates.EndExclusive() ' 10
