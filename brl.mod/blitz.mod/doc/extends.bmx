Rem
Extends is used in a BlitzMax Type declaration to derive the Type from a specified base class.
End Rem

SuperStrict

Type TShape
	Field xpos:Int,ypos:Int
	Method Draw() Abstract
End Type

Type TCircle Extends TShape
	Field radius:Int
	
	Function Create:TCircle(x:Int,y:Int,r:Int)
		Local c:TCircle=New TCircle
		c.xpos=x;c.ypos=y;c.radius=r
		Return c
	End Function
	
	Method Draw()
		DrawOval xpos,ypos,radius,radius
	End Method
End Type

Type TRect Extends TShape
	Field width:Int,height:Int
	
	Function Create:TRect(x:Int,y:Int,w:Int,h:Int)
		Local r:TRect=New TRect
		r.xpos=x;r.ypos=y;r.width=w;r.height=h
		Return r
	End Function
	
	Method Draw()
		DrawRect xpos,ypos,width,height
	End Method
End Type

Local shapelist:TShape[4]
Local shape:TShape

shapelist[0]=TCircle.Create(200,50,50)
shapelist[1]=TRect.Create(300,50,40,40)
shapelist[2]=TCircle.Create(400,50,50)
shapelist[3]=TRect.Create(200,180,250,20)

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	For shape=EachIn shapelist
		shape.draw
	Next
	Flip
Wend
End
