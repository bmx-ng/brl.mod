SuperStrict

'Iterate through every available audio driver on your system
For Local a:String = EachIn AudioDrivers()
	Print a + ":"+AudioDriverExists(a)
Next

Local a:String ="imaginary driver"
Print a+":"+AudioDriverExists(a)
