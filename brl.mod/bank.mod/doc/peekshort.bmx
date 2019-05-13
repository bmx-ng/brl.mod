SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Print
Print PeekShort(myBank,0)
Print PeekShort(myBank,1)
Print PeekShort(myBank,14)

End
