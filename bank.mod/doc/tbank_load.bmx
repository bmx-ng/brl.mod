SuperStrict

Local myBank:TBank=CreateBank(8)

Print "Created Bank..."
For Local t:Int = 0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

myBank.Save("mybank.dat")

Local myNextBank:TBank=TBank.Load("mybank.dat")
Print "Loaded Bank..."
For Local t:Int = 0 Until BankSize(myNextBank)
	Print PeekByte(myNextBank,t)
Next
