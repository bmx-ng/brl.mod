
SuperStrict

Module BRL.FreeTypeFont

ModuleInfo "Version: 1.10"
ModuleInfo "Author: Simon Armstrong, Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.10"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Offset glyph rect to allow for smooth font border"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Fixed freetypelib being reopened per font"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added one pixel blank border around SMOOTHFONT glyphs for ultra smooth subpixel positioning."
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed memory (incbin::) fonts"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Improved unicode support"
ModuleInfo "History: Replaced stream hooks with New_Memory_Face"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added stream hooks"

Import BRL.Font
Import BRL.Pixmap
Import Pub.FreeType

Private

Function PadPixmap:TPixmap( p:TPixmap )
	Local t:TPixmap=TPixmap.Create( p.width+2,p.height+2,p.format )
	MemClear t.pixels,Size_T(t.capacity)
	t.Paste p,1,1
	Return t
End Function

Public

Type TFreeTypeGlyph Extends TGlyph

	Field _pixmap:TPixmap
	Field _advance#,_x:Int,_y:Int,_w:Int,_h:Int
	
	Method Pixels:TPixmap() Override
		If _pixmap Return _pixmap
		
		Return _pixmap
	End Method
	
	Method Advance#() Override
		Return _advance
	End Method
	
	Method GetRect( x:Int Var,y:Int Var,w:Int Var,h:Int Var ) Override
		x=_x
		y=_y
		w=_w
		h=_h
	End Method

End Type

Type TFreeTypeFont Extends BRL.Font.TFont

	'Field _face:FTFace
	Field _ft_face:Byte Ptr
	Field _style:Int,_height:Int
	Field _ascend:Int,_descend:Int
	Field _glyphs:TFreeTypeGlyph[]
	Field _buf:Byte Ptr,_buf_size:Int
	
	Method Delete()
		FT_Done_Face _ft_face
		MemFree _buf
	End Method

	Method Style:Int() Override
		Return _style
	End Method

	Method Height:Int() Override
		Return _height
	End Method
	
	Method CountGlyphs:Int() Override
		Return _glyphs.length
	End Method
	
	Method CharToGlyph:Int( char:Int ) Override
		Return FT_Get_Char_Index( _ft_face,char )-1
	End Method
	
	Method LoadGlyph:TFreeTypeGlyph( index:Int ) Override
	
		Local glyph:TFreeTypeGlyph=_glyphs[index]
		If glyph Return glyph

		glyph=New TFreeTypeGlyph
		_glyphs[index]=glyph
		
		If FT_Load_Glyph( _ft_face,index+1,FT_LOAD_RENDER ) Return glyph
			
		'Local slot:FTGlyph=New FTGlyph
		'MemCopy slot,bmx_freetype_Face_glyph(_ft_face),SizeOf slot
		Local _slot:Byte Ptr = bmx_freetype_Face_glyph(_ft_face)

		Local width:Int = bmx_freetype_Slot_bitmap_width(_slot)
		Local rows:Int = bmx_freetype_Slot_bitmap_rows(_slot)
		Local pitch:Int = bmx_freetype_Slot_bitmap_pitch(_slot)
		Local advancex:Int = bmx_freetype_Slot_advance_x(_slot)
		Local buffer:Byte Ptr = bmx_freetype_Slot_bitmap_buffer(_slot)
		
		glyph._x=bmx_freetype_Slot_bitmapleft(_slot)
		glyph._y=-bmx_freetype_Slot_bitmaptop(_slot)+_ascend
		glyph._w=width
		glyph._h=rows
		glyph._advance=advancex Sar 6
		
		If width=0 Return glyph
	
		Local pixmap:TPixmap
		
		If bmx_freetype_Slot_bitmap_numgreys(_slot)
			pixmap=TPixmap.CreateStatic( buffer,width,rows,pitch,PF_A8 ).Copy()
		Else
			pixmap=CreatePixmap( width,rows,PF_A8 )
			Local b:Int
			For Local y:Int=0 Until rows
				Local dst:Byte Ptr=pixmap.PixelPtr(0,y)
				Local src:Byte Ptr=buffer+y*pitch
				For Local x:Int=0 Until width
					If (x&7)=0 b=src[x/8]
					If b & $80 dst[x]=$ff Else dst[x]=0
					b:+b
				Next
			Next
		EndIf
		
		If _style & SMOOTHFONT
			glyph._x:-1
			glyph._y:-1
			glyph._w:+2
			glyph._h:+2
			pixmap=PadPixmap(pixmap)
		EndIf
		
		glyph._pixmap=pixmap
		
		Return glyph

	End Method
	
	Function Load:TFreeTypeFont( src$,size:Int,style:Int )

		Global ft_lib:Byte Ptr
		
		If Not ft_lib
			If FT_Init_FreeType( Varptr ft_lib ) Return Null
		EndIf

		Local buf:Byte Ptr,buf_size:Int
				
		Local ft_face:Byte Ptr

		If src.Find( "::" )>0
			Local tmp:Byte[]=LoadByteArray( src )
			buf_size=tmp.length
			If Not buf_size Return Null
			buf=MemAlloc( Size_T(buf_size) )
			MemCopy buf,tmp,Size_T(buf_size)
			If FT_New_Memory_Face( ft_lib,buf,buf_size,0,Varptr ft_face )
				MemFree buf
				Return Null
			EndIf
		Else
			If FT_New_Face( ft_lib,src$,0,Varptr ft_face ) Return Null
		EndIf
		
		While size
			If Not FT_Set_Pixel_Sizes( ft_face,0,size ) Exit
			size:-1
		Wend
		If Not size 
			FT_Done_Face ft_face
			Return Null
		EndIf
		
		'Local face:FTFace=New FTFace
		'MemCopy face,ft_face,SizeOf face
		
		Local ft_size:Byte Ptr = bmx_freetype_Face_size(ft_face)
		'Local metrics:FTMetrics=New FTMetrics
		'MemCopy metrics,face.metrics,SizeOf metrics
		
		Local font:TFreeTypeFont=New TFreeTypeFont
		'font._face=face
		font._ft_face=ft_face
		font._style=style
		font._height=bmx_freetype_Size_height(ft_size) Sar 6
		font._ascend=bmx_freetype_Size_ascend(ft_size) Sar 6
		font._descend=bmx_freetype_Size_descend(ft_size) Sar 6
		font._glyphs=New TFreeTypeGlyph[bmx_freetype_Face_numglyphs(ft_face)]
		font._buf=buf
		font._buf_size=buf_size
		
		Return font
	
	End Function

End Type

Type TFreeTypeFontLoader Extends TFontLoader

	Method LoadFont:TFreeTypeFont( url:Object,size:Int,style:Int ) Override
	
		Local src$=String( url )
		
		If src Return TFreeTypeFont.Load( src,size,style )
	
	End Method

End Type

AddFontLoader New TFreeTypeFontLoader
