Rem
Varptr returns the address of a variable in system memory.
End Rem

SuperStrict

Framework BRL.StandardIO


Local a:Int
Local p:Int Ptr

a=20
p=Varptr a
Print p[0]
