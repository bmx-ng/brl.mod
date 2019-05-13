SuperStrict

Local myBank:TBank=CreateBank(16)

PokeShort myBank,0,256
PokeShort myBank,14,32768+1

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
