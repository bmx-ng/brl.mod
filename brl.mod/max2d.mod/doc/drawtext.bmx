' drawtext.bmx

' scrolls a large text string across the screen by decrementing the tickerx variable

SuperStrict

Graphics 640,480

Local tickerx:Int = 640

Local Text:String = "Yo to all the Apple, Windows and Linux BlitzMax programmers in the house! "
Text:+"Game development is the most fun, most advanced and definitely most cool "
Text:+"software programming there is!"

While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawText "Scrolling Text Demo",0,0
	DrawText Text,tickerx#,400
	tickerx=tickerx-1
	If tickerx<-TextWidth(Text) tickerx=640
	Flip	
Wend

End