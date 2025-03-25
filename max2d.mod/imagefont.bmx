
SuperStrict

Import BRL.Font

Import "image.bmx"

Incbin "blitzfont.bin"

Type TImageGlyph

	Field _image:TImage
	Field _advance:Float,_x:Int,_y:Int,_w:Int,_h:Int
	
	Method Pixels:TImage()
		Return _image
	End Method

	Method Advance:Float()
		Return _advance
	End Method
	
	Method GetRect( x:Int Var,y:Int Var,w:Int Var,h:Int Var )
		x=_x
		y=_y
		w=_w
		h=_h
	End Method

End Type

Type TImageFont

	Field _src_font:TFont
	Field _glyphs:TImageGlyph[]
	Field _imageFlags:Int
	Field _style:Int

	Method Style:Int()
		If _src_font Return _src_font.Style()
		Return 0
	End Method

	Method Height:Int()
		If _src_font Return _src_font.Height()
		Return 16
	End Method
	
	Method CountGlyphs:Int()
		Return _glyphs.length
	End Method
	
	Method CharToGlyph:Int( char:Int )
		If _src_font Return _src_font.CharToGlyph( char )
		If char>=32 And char<128 Return char-32
		Return -1
	End Method
	
	Method LoadGlyph:TImageGlyph( index:Int )

		Assert index>=0 And index<_glyphs.length

		Local glyph:TImageGlyph=_glyphs[index]
		If glyph Return glyph
		
		glyph:TImageGlyph=New TImageGlyph
		_glyphs[index]=glyph
		
		Local src_glyph:TGlyph=_src_font.LoadGlyph( index )
		
		glyph._advance=src_glyph.Advance()
		src_glyph.GetRect glyph._x,glyph._y,glyph._w,glyph._h
			
		Local pixmap:TPixmap=TPixmap( src_glyph.Pixels() )
		If Not pixmap Return glyph
			
		glyph._image=TImage.Load( pixmap.Copy(),_imageFlags,0,0,0 )
		
		Return glyph
		
	End Method

	Method LoadGlyphs:TImageGlyph[]( text:String )

		Local src_glyph:TGlyph[]=_src_font.LoadGlyphs( text )

		Local glyphs:TImageGlyph[]=New TImageGlyph[text.length]

		For Local i:Int=0 Until text.length
			Local src:TGlyph=src_glyph[i]

			Local glyph:TImageGlyph=New TImageGlyph
			glyphs[i]=glyph

			If src Then
				Local index:Int = src.Index()
				Local cachedGlyph:TImageGlyph = _glyphs[index]

				If cachedGlyph Then
					glyph._image = cachedGlyph._image
				End If
		
				glyph._advance=src.Advance()
				src.GetRect glyph._x,glyph._y,glyph._w,glyph._h
				If Not glyph._image
					Local pixmap:TPixmap=TPixmap( src.Pixels() )
					If pixmap Then
						glyph._image=TImage.Load( pixmap.Copy(),_imageFlags,0,0,0 )
					End If
				End If
			End If
		Next

		Return glyphs
	End Method
	
	Method Draw( text:String,x:Float,y:Float,ix:Float,iy:Float,jx:Float,jy:Float )

		If Not (_style & KERNFONT) Then
			For Local i:Int=0 Until text.length
			
				Local n:Int=CharToGlyph( text[i] )
				If n<0 Continue
				
				Local glyph:TImageGlyph=LoadGlyph(n)
				Local image:TImage=glyph._image
				
				If image
					Local frame:TImageFrame=image.Frame(0)
					If frame
						Local tx:Float=glyph._x*ix+glyph._y*iy
						Local ty:Float=glyph._x*jx+glyph._y*jy			
						frame.Draw 0,0,image.width,image.height,x+tx,y+ty,0,0,image.width,image.height
					EndIf
				EndIf
				
				x:+glyph._advance*ix
				y:+glyph._advance*jx
			Next
		Else
			Local glyphs:TImageGlyph[] = LoadGlyphs( text )

			For Local i:Int=0 Until glyphs.length
				Local glyph:TImageGlyph=glyphs[i]
				Local image:TImage=glyph._image
				If image
					Local frame:TImageFrame=image.Frame(0)
					If frame
						Local tx:Float=glyph._x*ix+glyph._y*iy
						Local ty:Float=glyph._x*jx+glyph._y*jy			
						frame.Draw 0,0,image.width,image.height,x+tx,y+ty,0,0,image.width,image.height
					EndIf
				EndIf
				x:+glyph._advance*ix
				y:+glyph._advance*jx
			Next
		End If
		
	End Method
	
	Function Load:TImageFont( url:Object,size:Int,style:Int )
	
		Local src:TFont=LoadFont( url,size,style )
		If Not src Return null
		
		Local font:TImageFont=New TImageFont
		font._src_font=src
		font._glyphs=New TImageGlyph[src.CountGlyphs()]
		font._style=style
		If style & SMOOTHFONT font._imageFlags=FILTEREDIMAGE|MIPMAPPEDIMAGE
		
		Return font
		
	End Function
	
	Function CreateDefault:TImageFont()

		Local font:TImageFont=New TImageFont
		font._glyphs=New TImageGlyph[96]
		
		Local pixmap:TPixmap=TPixmap.Create( 96*8,16,PF_RGBA8888 )
		
		Local p:Byte Ptr=IncbinPtr( "blitzfont.bin" )
	
		For Local y:Int=0 Until 16
			For Local x:Int=0 Until 96
				Local b:Int=p[x]
				For Local n:Int=0 Until 8
					If b & (1 Shl n) 
						pixmap.WritePixel x*8+n,y,~0
					Else
						pixmap.WritePixel x*8+n,y,0
					EndIf
				Next
			Next
			p:+96
		Next

		For Local n:Int=0 Until 96
			Local glyph:TImageGlyph=New TImageGlyph
			font._glyphs[n]=glyph
			glyph._advance=8
			glyph._w=8
			glyph._h=16
			glyph._image=TImage.Load( pixmap.Window(n*8,0,8,16).Copy(),0,0,0,0 )
		Next
	
		Return font
	End Function

End Type
