SuperStrict

Local bank:TBank = CreateBank(100)
PokeByte bank, 10, 255
 
Local bptr:Byte Ptr = BankBuf(bank)

Print PeekByte(bank , 10)
Print bptr[10]
