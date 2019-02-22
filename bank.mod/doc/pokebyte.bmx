SuperStrict

Local myBank:TBank=CreateBank(16)

PokeByte myBank,0,123
PokeByte myBank,15,234

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
