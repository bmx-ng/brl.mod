' RndSeed.bmx and SeedRnd.bmx ( one example for both )
' Get/Set random number seed.

SuperStrict

SeedRnd MilliSecs()

Local seed:Int = RndSeed()

Print "Initial seed="+seed

For Local k:Int = 1 To 10
Print Rand(10)
Next

Print "Restoring seed"

SeedRnd seed

For Local k:Int = 1 To 10
Print Rand(10)
Next
