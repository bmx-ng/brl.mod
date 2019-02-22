' writefile.bmx
SuperStrict

Local file:TStream = WriteFile("test.txt")

If Not file Then RuntimeError "failed to open test.txt file" 

WriteLine file,"hello world"

CloseStream file
