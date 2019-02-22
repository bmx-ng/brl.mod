SuperStrict

Local myBank:TBank=CreateBank(8)

Print "Created Bank..."
For Local t:Int = 0 Until BankSize(MyBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Local bankStream:TStream=WriteStream("mybank.dat")
WriteBank(myBank,bankStream,0,BankSize(myBank))
CloseStream(bankStream)

Local myNextBank:TBank=TBank.Load("mybank.dat")
Print "Loaded Bank..."
For Local t:Int = 0 Until BankSize(MyNextBank)
	Print PeekByte(MyNextBank,t)
Next
