
SuperStrict

Import BRL.Pixmap
Import BRL.Graphics

'modes for SetBlend
Const MASKBLEND:Int=1
Const SOLIDBLEND:Int=2
Const ALPHABLEND:Int=3
Const LIGHTBLEND:Int=4
Const SHADEBLEND:Int=5

'flags for frames/images
Const MASKEDIMAGE:Int=		$1
Const FILTEREDIMAGE:Int=	$2
Const MIPMAPPEDIMAGE:Int=	$4
Const DYNAMICIMAGE:Int=		$8

'current driver
Global _max2dDriver:TMax2DDriver

Type TImageFrame

	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# ) Abstract
	
End Type

Type TMax2DDriver Extends TGraphicsDriver

	'Backend specific!
	'implement this function in each TMax2D-extending type (OpenGL, DX, ..)
	Method CreateRenderImageContext:Object(g:TGraphics)
		Throw "Feature ~qRender2Texture~q not yet implemented in this graphics driver (" + ToString() + ")." 
		Return Null
	End Method

	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags:Int ) Abstract
	
	Method SetBlend( blend:Int ) Abstract
	Method SetAlpha( alpha# ) Abstract
	Method SetColor( red:Int,green:Int,blue:Int ) Abstract
	Method SetClsColor( red:Int,green:Int,blue:Int ) Abstract
	Method SetViewport( x:Int,y:Int,width:Int,height:Int ) Abstract
	Method SetTransform( xx#,xy#,yx#,yy# ) Abstract
	Method SetLineWidth( width# ) Abstract

	Method SetColor( color:SColor8 )
		SetColor(color.r, color.g, color.b)
	End Method
	Method SetClsColor( color:SColor8)
		SetClsColor(color.r, color.g, color.b)
	End Method
	
	Method Cls() Abstract
	Method Plot( x#,y# ) Abstract
	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawPoly( xy#[],handlex#,handley#,originx#,originy# ) Abstract
		
	Method DrawPixmap( pixmap:TPixmap,x:Int,y:Int ) Abstract
	Method GrabPixmap:TPixmap( x:Int,y:Int,width:Int,height:Int ) Abstract
	
	Method SetResolution( width#,height# ) Abstract

End Type
