SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until 4
	PokeInt MyBank,t*4,Int(Rnd($12345678))
Next
