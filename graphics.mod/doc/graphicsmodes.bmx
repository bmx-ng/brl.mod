SuperStrict

Print "Available graphics modes:"

For Local Mode:TGraphicsMode=EachIn GraphicsModes()

	Print Mode.width+","+Mode.height+","+Mode.depth+","+Mode.hertz

Next
