
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
Global _currentBoundRenderImage:TImageFrame

Type TImageFrame

	Method Draw( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float,sx:Float,sy:Float,sw:Float,sh:Float ) Abstract
	
End Type

Type TMax2DDriver Extends TGraphicsDriver

	'Backend specific!
	'implement this function in each TMax2D-extending type (OpenGL, DX, ..)
	Method CreateRenderImageContext:Object(g:TGraphics)
		Throw "Feature ~qRender2Texture~q not yet implemented in this graphics driver (" + ToString() + ")." 
		Return Null
	End Method

	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags:Int ) Abstract
	Method CreateRenderImageFrame:TImageFrame(width:UInt, height:UInt, flags:Int) Abstract
	Method SetBackBuffer() Abstract
	Method SetRenderImageFrame(RenderImageFrame:TImageFrame) Abstract
	
	Method SetBlend( blend:Int ) Abstract
	Method SetAlpha( alpha:Float ) Abstract
	Method SetColor( red:Int,green:Int,blue:Int ) Abstract
	Method SetClsColor( red:Int, green:Int, blue:Int, alpha:Float ) Abstract
	Method SetViewport( x:Int,y:Int,width:Int,height:Int ) Abstract
	Method SetTransform( xx:Float,xy:Float,yx:Float,yy:Float ) Abstract
	Method SetLineWidth( width:Float ) Abstract

	'these methods rely on the abstract ones - no need to enable overriding
	'them, so marked as "final"
	Method SetColor( color:SColor8 ) Final
		SetColor(color.r, color.g, color.b)
	End Method
	Method SetClsColor( color:SColor8, alpha:Float) Final
		SetClsColor(color.r, color.g, color.b, alpha)
	End Method
	
	Method Cls() Abstract
	
	Method Plot( x:Float,y:Float ) Abstract
	Method DrawLine( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Abstract
	Method DrawRect( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Abstract
	Method DrawOval( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Abstract
	Method DrawPoly( xy:Float[],handlex:Float,handley:Float,originx:Float,originy:Float, indices:Int[] ) Abstract
		
	Method DrawPixmap( pixmap:TPixmap,x:Int,y:Int ) Abstract
	Method GrabPixmap:TPixmap( x:Int,y:Int,width:Int,height:Int ) Abstract
	
	Method SetResolution( width:Float,height:Float ) Abstract

End Type
