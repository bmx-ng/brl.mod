Rem
Assert generates a BlitzMax runtime error if the specified condition is false.
End Rem

SuperStrict

Local a:TImage = LoadImage("nonexistant image file")
Assert a,"Image Failed to Load"
