Strict

Import "driver.bmx"
Import "image.bmx"


Type TRenderImage Extends TImage
	Field _valid:Int = 1

	'returns wether the content is still valid. Might be blanked
	'on "appsuspend" if no content persisting happened before
	Method Valid:Int()
		Return _valid
	End Method

	Method SetValid(bool:Int)
		_valid = bool
	End Method
	
	'ensure the GPU located render image would survive a "appsuspend"
	'by eg. reading it into a TPixmap
	Method Persist:Int()
		Return False
	End Method
	
	Method CreateRenderImage:TRenderImage(width:Int, height:Int) Abstract
	Method DestroyRenderImage() Abstract
	Method SetRenderImage() Abstract
	Method Clear(r:Int=0, g:Int=0, b:Int=0, a:Float=0.0) Abstract
	Method SetViewport(x:Int, y:Int, width:Int, height:Int) Abstract
End Type


Type TRenderImageContext
	Method Create:TRenderimageContext(gc:TGraphics, driver:TGraphicsDriver) Abstract
	Method Destroy() Abstract
	Method GraphicsContext:TGraphics() Abstract

	Method CreateRenderImage:TRenderImage(width:Int, height:Int, UseImageFiltering:Int) Abstract
	Method DestroyRenderImage(renderImage:TRenderImage) Abstract
	Method SetRenderImage(renderimage:TRenderImage) Abstract
	Method CreatePixmapFromRenderImage:TPixmap(renderImage:TRenderImage) Abstract
	Method CreateRenderImageFromPixmap:TRenderImage(pixmap:TPixmap, UseImageFiltering:Int) Abstract
End Type
