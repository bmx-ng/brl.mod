SuperStrict

Local myBank:TBank=CreateBank(16)

PokeInt myBank,0,-10000001
PokeInt myBank,12,31415926

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
