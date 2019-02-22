SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
Next

Print PeekByte(myBank,0)
Print PeekByte(myBank,1)

End
