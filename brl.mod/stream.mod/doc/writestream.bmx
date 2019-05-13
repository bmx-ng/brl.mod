' writestream.bmx

' opens a write stream to the file mygame.ini and
' outputs a simple text file using WriteLine

SuperStrict

Local out:TStream = WriteStream("mygame.ini")

If Not out RuntimeError "Failed to open a WriteStream to file mygame.ini"

WriteLine out,"[display]"
WriteLine out,"width=800"
WriteLine out,"height=600"
WriteLine out,"depth=32"
WriteLine out,""
WriteLine out,"[highscores]"
WriteLine out,"AXE=1000"
WriteLine out,"HAL=950"
WriteLine out,"MAK=920"

CloseStream out

Print "File mygame.ini created, bytes="+FileSize("mygame.ini")
