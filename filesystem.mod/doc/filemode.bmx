' filemode.bmx
SuperStrict

' the following function converts the file mode to 
' the standard unix permission bits string

Function Permissions:String(mode:Int)
	Local testbit:Int, pos:Int
	Local p:String = "rwxrwxrwx"
	testbit = %100000000
	pos = 1
	Local res:String
	While (testbit)
		If mode & testbit 
			res :+ Mid(p, pos, 1)
		Else 
			res :+ "-"
		EndIf
		testbit = testbit Shr 1
		pos :+ 1
	Wend
	Return res
End Function

Print Permissions(FileMode("filemode.bmx"))
