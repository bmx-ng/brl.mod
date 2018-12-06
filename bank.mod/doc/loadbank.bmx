SuperStrict

Local myBank:TBank=CreateBank(16)

For Local t:Int=0 Until BankSize(myBank)
	PokeByte mybank,t,Int(Rnd(255))
	Print PeekByte(myBank,t)
Next

SaveBank myBank,"mybank.dat"

Local myNextBank:TBank=LoadBank("mybank.dat")

For Local t:Int = 0 Until BankSize(myNextBank)
	Print PeekByte(myNextBank,t)
Next
