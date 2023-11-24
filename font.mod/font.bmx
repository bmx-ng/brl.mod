
SuperStrict

Module BRL.Font

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Modified interface for improved unicode support"

Const BOLDFONT:Int=1
Const ITALICFONT:Int=2
Const SMOOTHFONT:Int=4

Type TGlyph
	
	Method Pixels:Object() Abstract

	Method Advance:Float() Abstract
	Method GetRect( x:Int Var,y:Int Var,width:Int Var,height:Int Var ) Abstract

End Type

Type TFont

	Method Style:Int() Abstract
	Method Height:Int() Abstract
	Method CountGlyphs:Int() Abstract
	Method CharToGlyph:Int( char:Int ) Abstract
	Method LoadGlyph:TGlyph( index:Int ) Abstract

End Type

Type TFontLoader
	Field _succ:TFontLoader

	Method LoadFont:TFont( url:Object,size:Int,style:Int ) Abstract

End Type

Private

Global _loaders:TFontloader

Public

Function AddFontLoader( loader:TFontLoader )
	If loader._succ Return
	loader._succ=_loaders
	_loaders=loader
End Function

Function LoadFont:TFont( url:Object,size:Int,style:Int=SMOOTHFONT )

	Local loader:TFontLoader=_loaders
	
	While loader
		Local font:TFont=loader.LoadFont( url,size,style )
		If font Return font
		loader=loader._succ
	Wend

End Function
