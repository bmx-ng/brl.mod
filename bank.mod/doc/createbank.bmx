SuperStrict

Local myBank:TBank = CreateBank(16)

For Local t:Int = 0 Until BankSize(myBank)
	Print PeekByte(myBank,t)
Next
