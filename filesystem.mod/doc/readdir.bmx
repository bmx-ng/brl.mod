' readdir.bmx
SuperStrict

Local dir:Byte Ptr = ReadDir(CurrentDir())

If Not dir RuntimeError "failed to read current directory"

Repeat
	Local t:String = NextFile( dir )
	If t="" Exit
	If t="." Or t=".." Continue
	Print t	
Forever

CloseDir dir
