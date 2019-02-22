SuperStrict

Local myBank:TBank=CreateBank(16)

PokeFloat myBank,0,0.123456
PokeFloat myBank,12,1234.5678

For Local t:Int = 0 ubtil BankSize(myBank)
	Print PeekByte(myBank,t)
Next
