SuperStrict

Rem
bbdoc: Owned texture bytes and mip levels, with pixmap conversion helpers and no graphics-device dependency.
End Rem
Module BRL.TextureData
ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"

Import BRL.PixelFormat
Import BRL.Pixmap
Import "conversion.c"
Import "conversion.bmx"

Rem
bbdoc: One owned texture level, with explicit dimensions and row pitch.
about: Create copies the supplied bytes. Layout supports uncompressed pixels and compressed blocks described by BRL.PixelFormat. Pitch measures bytes per pixel row or compressed block row, including any padding. It performs no colour conversion. Stored bytes are opaque to this module.
End Rem
Type TTextureLevel
	Private
	Field _width:Int,_height:Int,_format:Int,_pitch:Int
	Field _bytes:Byte[]
	Public
	Function Create:TTextureLevel(width:Int,height:Int,format:Int,bytes:Byte[],pitch:Int=0)
		Local info:TPixelFormatInfo=GetPixelFormatInfo(format)
		If Not info Then Throw "TextureData: unknown format"
		If width<=0 Or height<=0 Then Throw "TextureData: dimensions must be positive"
		Local minimum:Long=info.RowPitch(width)
		If minimum>$7fffffff Then Throw "TextureData: row is too large"
		If pitch=0 Then pitch=Int(minimum)
		If pitch<minimum Then Throw "TextureData: row pitch is too small"
		Local size:Long=Long(pitch)*info.StorageRows(height)
		If size>$7fffffff Or size>bytes.Length Then Throw "TextureData: level storage is too short or too large"
		Local result:TTextureLevel=New TTextureLevel
		result._width=width
		result._height=height
		result._format=format
		result._pitch=pitch
		result._bytes=bytes[..Int(size)]
		Return result
	End Function
	Rem
	bbdoc: Snapshots a pixmap into a single texture level without converting its format.
	about: Copies active pixels row by row, including pixmap windows and padded source rows. Source padding is not retained.
	End Rem
	Function FromPixmap:TTextureLevel(pixmap:TPixmap)
		If Not pixmap Then Throw "TextureData: pixmap is null"
		Local info:TPixelFormatInfo=GetPixelFormatInfo(pixmap.format)
		If Not info Then Throw "TextureData: unknown pixmap format"
		If info.floatingPoint Or info.compressed Then Throw "TextureData: this storage format is not a pixmap"
		Local pitch:Long=info.RowPitch(pixmap.width)
		Local size:Long=info.StorageSize(pixmap.width,pixmap.height)
		If pixmap.width<=0 Or pixmap.height<=0 Or size>$7fffffff Then Throw "TextureData: invalid pixmap dimensions"
		If pixmap.pitch<pitch Then Throw "TextureData: invalid pixmap pitch"
		Local bytes:Byte[]=New Byte[Int(size)]
		For Local y:Int=0 Until pixmap.height
			MemCopy(Varptr bytes[Int(Long(y)*pitch)],pixmap.PixelPtr(0,y),Size_T(pitch))
		Next
		Local result:TTextureLevel=New TTextureLevel
		result._width=pixmap.width
		result._height=pixmap.height
		result._format=pixmap.format
		result._pitch=Int(pitch)
		result._bytes=bytes
		Return result
	End Function
	Method Width:Int()
		Return _width
	End Method
	Method Height:Int()
		Return _height
	End Method
	Method Format:Int()
		Return _format
	End Method
	Method Pitch:Int()
		Return _pitch
	End Method
	Method ByteSize:Int()
		Return _bytes.Length
	End Method
	Rem
	bbdoc: Returns an independent copy of this level's bytes, including row padding.
	End Rem
	Method CopyBytes:Byte[]()
		Return _bytes[..]
	End Method
	Rem
	bbdoc: Borrows the level's byte address for native upload or explicit byte editing.
	about: Keep this level alive for the entire use of the pointer. Do not free it or access beyond ByteSize. Images created by Max2D take their own snapshot, so editing this buffer does not update existing images.
	End Rem
	Method Data:Byte Ptr()
		Return _bytes
	End Method
	Method Copy:TTextureLevel()
		Return Create(_width,_height,_format,_bytes,_pitch)
	End Method
End Type

Rem
bbdoc: A validated sequence of owned mip levels in one format.
about: Create snapshots its input levels. Level zero defines dimensions; subsequent dimensions halve, rounded down and clamped to one. Partial chains are allowed, but extra levels beyond 1x1 are rejected. This container does not imply that a renderer accepts the format or supplied mip levels.
End Rem
Type TTextureData
	Private
	Field _levels:TTextureLevel[]
	Public
	Function Create:TTextureData(levels:TTextureLevel[])
		If Not levels.Length Then Throw "TextureData: at least one level is required"
		Local result:TTextureData=New TTextureData
		result._levels=New TTextureLevel[levels.Length]
		For Local index:Int=0 Until levels.Length
			Local level:TTextureLevel=levels[index]
			If Not level Then Throw "TextureData: null level"
			If index Then
				Local previous:TTextureLevel=levels[index-1]
				If previous.Width()=1 And previous.Height()=1 Then Throw "TextureData: extra mip level"
				If level.Format()<>levels[0].Format() Then Throw "TextureData: mip formats differ"
				If level.Width()<>Max(1,previous.Width()/2) Or level.Height()<>Max(1,previous.Height()/2) Then Throw "TextureData: invalid mip dimensions"
			End If
			result._levels[index]=level.Copy()
		Next
		Return result
	End Function
	Rem
	bbdoc: Snapshots a pixmap into a single level without converting its format.
	End Rem
	Function FromPixmap:TTextureData(pixmap:TPixmap)
		Local result:TTextureData=New TTextureData
		result._levels=[TTextureLevel.FromPixmap(pixmap)]
		Return result
	End Function
	Rem
	bbdoc: Copies one selected mip level to an independently owned pixmap in the same format.
	about: No conversion or mip-level merging is performed. The default selects level zero. Compressed levels require an explicit decoder. Floating-point levels are rejected: converting their range and precision requires an explicit policy.
	End Rem
	Method ToPixmap:TPixmap(index:Int=0)
		Local level:TTextureLevel=Level(index)
		Local info:TPixelFormatInfo=GetPixelFormatInfo(level.Format())
		If info.compressed Then Throw "TextureData: compressed data requires an explicit decoder"
		If info.floatingPoint Then Throw "TextureData: floating-point conversion requires explicit range and precision handling"
		If info.StorageSize(level.Width(),level.Height(),4)>$7fffffff Then Throw "TextureData: aligned pixmap is too large"
		Local pixels:TPixmap=CreatePixmap(level.Width(),level.Height(),level.Format())
		Local size:Int=Int(info.RowPitch(level.Width()))
		For Local y:Int=0 Until level.Height()
			MemCopy(pixels.PixelPtr(0,y),level.Data()+Size_T(y)*level.Pitch(),Size_T(size))
		Next
		Return pixels
	End Method
	Rem
	bbdoc: Converts a selected level to RGBA8888 using an explicit colour and range policy.
	about: Accepts RGBA8888, RGBA16F and RGBA32F. Decodes source transfer encoding, applies exposure and tone mapping, then encodes output RGB. Alpha is clamped independently. options is required; ToPixmap keeps its existing lossless-copy behavior. This CPU operation allocates a new pixmap and does not change the source.
	End Rem
	Method ConvertToPixmap:TPixmap(options:TTexturePixmapOptions,index:Int=0)
		If Not options Then Throw "TextureData: conversion options are required"
		If Not bmx_texture_valid_exposure(options.exposureStops) Then Throw "TextureData: exposure must be finite and between -64 and 64 stops"
		If options.sourceEncoding<>ETextureEncoding.Linear And options.sourceEncoding<>ETextureEncoding.SRGB Then Throw "TextureData: invalid source encoding"
		If options.outputEncoding<>ETextureEncoding.Linear And options.outputEncoding<>ETextureEncoding.SRGB Then Throw "TextureData: invalid output encoding"
		If options.sourceAlpha<>ETextureAlphaMode.Straight And options.sourceAlpha<>ETextureAlphaMode.Premultiplied Then Throw "TextureData: invalid alpha mode"
		If options.toneMap<>ETextureToneMap.Clamp And options.toneMap<>ETextureToneMap.Reinhard Then Throw "TextureData: invalid tone map"
		Local level:TTextureLevel=Level(index)
		Local bits:Int
		Select level.Format()
			Case PF_RGBA8888
				bits=8
			Case PF_RGBA16F
				bits=16
			Case PF_RGBA32F
				bits=32
			Default
				Throw "TextureData: conversion requires RGBA8888, RGBA16F or RGBA32F"
		End Select
		If GetPixelFormatInfo(PF_RGBA8888).StorageSize(level.Width(),level.Height(),4)>$7fffffff Then Throw "TextureData: converted pixmap is too large"
		Local pixmap:TPixmap=CreatePixmap(level.Width(),level.Height(),PF_RGBA8888)
		bmx_texture_convert(level.Data(),level.Pitch(),pixmap.pixels,pixmap.pitch,level.Width(),level.Height(),bits,Int(options.sourceEncoding),Int(options.outputEncoding),Int(options.sourceAlpha),Int(options.toneMap),options.exposureStops)
		Return pixmap
	End Method
	Method Width:Int()
		Return _levels[0].Width()
	End Method
	Method Height:Int()
		Return _levels[0].Height()
	End Method
	Method Format:Int()
		Return _levels[0].Format()
	End Method
	Method LevelCount:Int()
		Return _levels.Length
	End Method
	Method Level:TTextureLevel(index:Int=0)
		If index<0 Or index>=_levels.Length Then Throw "TextureData: mip level out of range"
		Return _levels[index]
	End Method
	Method ByteSize:Long()
		Local size:Long
		For Local level:TTextureLevel=EachIn _levels
			size:+level.ByteSize()
		Next
		Return size
	End Method
	Method CompleteMipChain:Int()
		Local last:TTextureLevel=_levels[_levels.Length-1]
		Return last.Width()=1 And last.Height()=1
	End Method
	Method Copy:TTextureData()
		Return Create(_levels)
	End Method
End Type

Private
Global _textureDataLoaders:TTextureDataLoader
Public

Rem
bbdoc: Base class for optional texture-container loaders, registered when constructed.
about: Return Null for an unrecognised stream. Once a format is recognised, throw an informative error for invalid or unsupported content. Do not close the supplied stream. The dispatcher resets its position before each loader.
End Rem
Type TTextureDataLoader
	Field _next:TTextureDataLoader
	Method New()
		_next=_textureDataLoaders
		_textureDataLoaders=Self
	End Method
	Method LoadTextureData:TTextureData(stream:TStream) Abstract
End Type

Rem
bbdoc: Whether any optional texture-container loader has been imported.
End Rem
Function HasTextureDataLoaders:Int()
	Return _textureDataLoaders<>Null
End Function

Rem
bbdoc: Loads owned texture data from a filename, stream URL or seekable TStream.
about: Uses import-registered loaders. Returns Null if no loader recognises the data or the URL cannot be opened. Recognised invalid or unsupported containers throw an error. Unknown data leaves a caller-owned stream at its starting position; successful loads advance past the texture. Caller-owned streams remain open. Generic probing requires seeking; use a format-specific loader for forward-only streams.
End Rem
Function LoadTextureData:TTextureData(url:Object)
	If Not _textureDataLoaders Then Return Null
	Local stream:TStream=ReadStream(url)
	If Not stream Then Return Null
	Local result:TTextureData
	Try
		Local position:Long=stream.Pos()
		If position<0 Or stream.Seek(position)<>position Then Throw "TextureData: loader probing requires a seekable stream"
		Local loader:TTextureDataLoader=_textureDataLoaders
		While loader
			If stream.Seek(position)<>position Then Throw "TextureData: cannot restore stream position"
			result=loader.LoadTextureData(stream)
			If result Then Exit
			loader=loader._next
		Wend
		If Not result And stream.Seek(position)<>position Then Throw "TextureData: cannot restore stream position"
	Catch error:Object
		stream.Close()
		Throw error
	End Try
	stream.Close()
	Return result
End Function

Private
Extern "C"
	Function bmx_texture_valid_exposure:Int(exposure:Double)
	Function bmx_texture_convert(pixels:Byte Ptr,pitch:Int,output:Byte Ptr,outputPitch:Int,width:Int,height:Int,bits:Int,sourceEncoding:Int,outputEncoding:Int,premultiplied:Int,toneMap:Int,exposure:Double)
End Extern
Public
