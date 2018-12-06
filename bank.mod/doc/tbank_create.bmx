SuperStrict

Local bank:TBank=TBank.Create(100)

For Local i:Int = 0 Until 100
	PokeByte bank , i , i
Next

Print "Original Bank Values..."
For Local i:Int = 0 Until 10
	Print PeekByte(Bank , 50 + i)
Next
