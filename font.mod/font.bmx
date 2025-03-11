
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

Const BOLDFONT:Int=  $001
Const ITALICFONT:Int=$002
Const SMOOTHFONT:Int=$004

Const SMALLCAPSFONT:Int=              $0000100
Const ALLSMALLCAPSFONT:Int=           $0000200
Const LIGATURESFONT:Int=              $0000400
Const DISCRETIONARYLIGATURESFONT:Int= $0000800
Const OLDSTYLEFIGURESFONT:Int=        $0001000
Const TABULARFIGURESFONT:Int=         $0002000
Const FRACTIONSFONT:Int=              $0004000
Const SUPERSCRIPTFONT:Int=            $0008000
Const SUBSCRIPTFONT:Int=              $0010000
Const SWASHESFONT:Int=                $0020000
Const STYLISTICALTERNATESFONT:Int=    $0040000
Const CONTEXTUALALTERNATESFONT:Int=   $0080000
Const HISTORICALFORMSFONT:Int=        $0100000
Const DENOMINATORSFONT:Int=           $0200000
Const NUMERATORFONT:Int=              $0400000
Const LININGFIGURESFONT:Int=          $0800000
Const SCIENTIFICINFERIORSFONT:Int=    $1000000
Const PROPORTIONALFIGURESFONT:Int=    $2000000
Const KERNFONT:Int=                   $4000000
Const ZEROFONT:Int=                   $8000000

Type TGlyph
	
	Method Pixels:Object() Abstract

	Method Advance:Float() Abstract
	Method GetRect( x:Int Var,y:Int Var,width:Int Var,height:Int Var ) Abstract
	Method Index:Int() Abstract

End Type

Type TFont

	Method Style:Int() Abstract
	Method Height:Int() Abstract
	Method CountGlyphs:Int() Abstract
	Method CharToGlyph:Int( char:Int ) Abstract
	Method LoadGlyph:TGlyph( index:Int ) Abstract
	Method LoadGlyphs:TGlyph[]( text:String ) Abstract

End Type

Type TFontLoader
	Field _succ:TFontLoader

	Method LoadFont:TFont( url:Object,size:Float,style:Int ) Abstract

End Type

Private

Global _loaders:TFontloader

Public

Function AddFontLoader( loader:TFontLoader )
	If loader._succ Return
	loader._succ=_loaders
	_loaders=loader
End Function

Function LoadFont:TFont( url:Object,size:Float,style:Int=SMOOTHFONT )

	Local loader:TFontLoader=_loaders
	
	While loader
		Local font:TFont=loader.LoadFont( url,size,style )
		If font Return font
		loader=loader._succ
	Wend

End Function
