SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Print
Print PeekFloat(myBank,0)
Print PeekFloat(myBank,1)
Print PeekFloat(myBank,12)

End
