Rem
IncBinLen returns the size in bytes of the specified embedded binary file.
End Rem

SuperStrict

Framework BRL.StandardIO


Incbin "incbinlen.bmx"

Local p:Byte Ptr = IncbinPtr("incbinlen.bmx")
Local bytes:Int = IncbinLen("incbinlen.bmx")

Local s:String=String.FromBytes(p,bytes)

Print "StringFromBytes(p,bytes)="+s
