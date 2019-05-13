' RndSeed.bmx and SeedRnd.bmx ( one example for both )
' Get/Set random number seed.

SuperStrict

SeedRnd MilliSecs()

local seed:int = RndSeed()

Print "Initial seed="+seed

For local k:int = 1 To 10
	Print Rand(10)
Next

Print "Restoring seed"

SeedRnd seed

For local k:int = 1 To 10
	Print Rand(10)
Next
