SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Print
Print PeekDouble(myBank,0)
Print PeekDouble(myBank,1)
Print PeekDouble(myBank,8)

End
