Rem
Millisecs is useful for seeding the random number generator.
End Rem

SuperStrict

SeedRnd(MilliSecs())

For Local i:Int = 1 To 10
	Print Rnd()
Next
