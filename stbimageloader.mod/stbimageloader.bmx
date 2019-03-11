SuperStrict

Rem
bbdoc: Graphics/Stb Image loader
about:
The stb image loader module provides the ability to load different image format #pixmaps.
Supported formats include, BMP, PSD, TGA, GIF, HDR, PIC and PNM
End Rem
Module BRL.StbImageLoader

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Pub.StbImage
Import BRL.Pixmap

Import "glue.c"


Extern

	Function bmx_stbi_load_image:Byte Ptr(cb:Object, width:Int Ptr, height:Int Ptr, channels:Int Ptr)

End Extern


Type TPixmapLoaderSTB Extends TPixmapLoader

	Method LoadPixmap:TPixmap( stream:TStream ) Override
	
		Local pixmap:TPixmap
	
		Local cb:TStbioCallbacks = New TStbioCallbacks
		cb.stream = stream
		
		Local width:Int, height:Int, channels:Int
		
		Local imgPtr:Byte Ptr = bmx_stbi_load_image(cb, Varptr width, Varptr height, Varptr channels)
		
		If imgPtr Then
		
			Local pf:Int
		
			Select channels
				Case STBI_grey
					pf = PF_I8
				Case STBI_rgb
					pf = PF_RGB888
				Case STBI_rgb_alpha
					pf = PF_RGBA8888
				Case STBI_grey_alpha
					pixmap = CreatePixmap( width,height,PF_RGBA8888 )
					
					Local src:Byte Ptr = imgPtr
					Local dst:Byte Ptr = pixmap.pixels

					For Local y:Int = 0 Until height
						For Local x:Int = 0 Until width
							Local a:Int=src[0]
							Local i:Int=src[1]
							dst[0] = i
							dst[1] = i
							dst[2] = i
							dst[3] = a
							src:+2
							dst:+4
						Next
					Next
			End Select
			
			
			
			If pf
				pixmap = CreatePixmap( width, height, pf )

				MemCopy(pixmap.pixels, imgPtr, Size_T(width * height * BytesPerPixel[pf]))
			End If
			
			stbi_image_free(imgPtr)
		
		End If
	
		Return pixmap
		
	End Method

End Type


Type TStbioCallbacks

	Field stream:TStream
	
	Method Read:Int(buffer:Byte Ptr, size:Int)
		Return stream.Read(buffer, size)
	End Method
	
	Method Skip(n:Int)
		stream.Seek(SEEK_CUR_, n)
	End Method
	
	Method Eof:Int()
		Return stream.Eof()
	End Method

	Function _Read:Int(cb:TStbioCallbacks, buffer:Byte Ptr, size:Int) { nomangle }
		Return cb.Read(buffer, size)
	End Function

	Function _Skip(cb:TStbioCallbacks, n:Int) { nomangle }
		cb.Skip(n)
	End Function

	Function _Eof:Int(cb:TStbioCallbacks) { nomangle }
		Return cb.Eof()
	End Function
	
End Type

New TPixmapLoaderSTB
