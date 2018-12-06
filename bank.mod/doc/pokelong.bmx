SuperStrict

Local myBank:TBank=CreateBank(16)

PokeLong myBank,0,-10000001234567
PokeLong myBank,8,31415926000000

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
