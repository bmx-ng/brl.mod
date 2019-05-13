SuperStrict

Local myBank:TBank=CreateBank(16)

PokeDouble myBank,0,123495543.12342345123:Double
PokeDouble myBank,8,121235567.89015678123:Double

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
