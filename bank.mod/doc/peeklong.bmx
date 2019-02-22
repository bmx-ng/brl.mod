SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Print
Print PeekLong(myBank,0)
Print PeekLong(myBank,1)
Print PeekLong(myBank,8)
