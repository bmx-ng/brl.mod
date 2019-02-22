SuperStrict

Local bank:TBank = CreateBank(1)  'This bank will resize itself from stream
Local stream:TBankStream = TBankStream.Create(bank)
WriteString(stream, "Hello World")
CloseStream(stream)

For Local i:Int = 0 Until BankSize(bank)
	Print Chr(PeekByte(bank , i) )
Next
