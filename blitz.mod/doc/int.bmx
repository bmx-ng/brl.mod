Rem
Int is a signed 32 bit integer BlitzMax primitive type.
End Rem

SuperStrict

Framework BRL.StandardIO


Local a:Int

' the following values all print 0 as BlitzMax "rounds to zero"
' when converting from floating point to integer

a=0.1;Print a
a=0.9;Print a
a=-0.1;Print a
a=-0.9;Print a
