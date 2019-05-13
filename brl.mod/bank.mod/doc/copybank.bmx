SuperStrict

Local bank:TBank = CreateBank(100)

For Local i:Int = 0 Until 100
	PokeByte bank, i ,i
Next

Print "Original Bank Values..."
For Local i:Int = 0 To 10
	Print PeekByte(bank , 50 + i)
Next

Local copiedbank:TBank = CreateBank(100)
CopyBank(bank, 50, copiedBank, 0, 10+1) 
Print "Copied Bank Values..."
For Local i:Int = 0 To 10
	Print PeekByte(CopiedBank , i)
Next
