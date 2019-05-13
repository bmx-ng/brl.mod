SuperStrict

Local bank:TBank = CreateBank(100)
PokeByte bank, 10, 255
 
Local bptr:Byte Ptr = bank.Buf()

Print PeekByte(bank , 10)
Print bptr[10]
