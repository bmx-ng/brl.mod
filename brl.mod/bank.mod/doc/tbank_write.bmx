SuperStrict

Local myBank:TBank=CreateBank(8)

Print "Created Bank..."
For Local t:Int = 0 Until BankSize(MyBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

Local bankStream:TStream=WriteStream("mybank.dat")
myBank.write(bankStream,0,BankSize(MyBank))
CloseStream(bankStream)

Local myNextBank:TBank=TBank.Load("mybank.dat")
Print "Loaded Bank..."
For Local t:Int = 0 Until BankSize(myNextBank)
	Print PeekByte(myNextBank,t)
Next
