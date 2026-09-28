SuperStrict

Rem
bbdoc: Shared pixel-format identifiers and storage information, independent of graphics contexts.
End Rem
Module BRL.PixelFormat
ModuleInfo "Version: 1.02"
ModuleInfo "License: zlib/libpng"

Const PF_I8:Int=				1
Const PF_A8:Int=				2
Const PF_BGR888:Int=			3
Const PF_RGB888:Int=			4
Const PF_BGRA8888:Int=  		5
Const PF_RGBA8888:Int=  		6
Const PF_ARGB8888:Int=			13
Const PF_ABGR8888:Int=			14

Const PF_STDFORMAT:Int= 		PF_RGBA8888

'New pixel formats
'
'These are GL compatible - all are 8 bit versions.
'
'NOT FULLY IMPLEMENTED YET!!!!!
'
Const PF_RED:Int=				7
Const PF_GREEN:Int=				8
Const PF_BLUE:Int=				9
Const PF_ALPHA:Int=				10
Const PF_INTENSITY:Int=			11
Const PF_LUMINANCE:Int=			12
Const PF_RGB:Int=				PF_RGB888
Const PF_BGR:Int=				PF_BGR888
Const PF_RGBA:Int=				PF_RGBA8888
Const PF_BGRA:Int=				PF_BGRA8888
Const PF_ARGB:Int=				PF_ARGB8888
Const PF_ABGR:Int=				PF_ABGR8888

?BigEndian
Const PF_COLOR:Int=				PF_RGB
Const PF_COLORALPHA:Int=		PF_RGBA
?LittleEndian
Const PF_COLOR:Int=				PF_BGR
Const PF_COLORALPHA:Int=		PF_BGRA
?

Rem
bbdoc: RGB565 stored least-significant byte first, independent of host byte order.
End Rem
Const PF_RGB565_LE:Int=15
Rem
bbdoc: RGB565 stored most-significant byte first, independent of host byte order.
End Rem
Const PF_RGB565_BE:Int=16
Rem
bbdoc: BGR565 stored least-significant byte first, independent of host byte order.
End Rem
Const PF_BGR565_LE:Int=17
Rem
bbdoc: BGR565 stored most-significant byte first, independent of host byte order.
End Rem
Const PF_BGR565_BE:Int=18
?LittleEndian
Const PF_RGB565:Int=PF_RGB565_LE
Const PF_BGR565:Int=PF_BGR565_LE
?BigEndian
Const PF_RGB565:Int=PF_RGB565_BE
Const PF_BGR565:Int=PF_BGR565_BE
?

Rem
bbdoc: RGB332 packed colour, one byte per pixel.
End Rem
Const PF_RGB332:Int=19
Rem
bbdoc: RGBA4444 packed colour, low byte first.
End Rem
Const PF_RGBA4444_LE:Int=20
Rem
bbdoc: RGBA4444 packed colour, high byte first.
End Rem
Const PF_RGBA4444_BE:Int=21
Rem
bbdoc: BGRA4444 packed colour, low byte first.
End Rem
Const PF_BGRA4444_LE:Int=22
Rem
bbdoc: BGRA4444 packed colour, high byte first.
End Rem
Const PF_BGRA4444_BE:Int=23
Rem
bbdoc: ARGB4444 packed colour, low byte first.
End Rem
Const PF_ARGB4444_LE:Int=24
Rem
bbdoc: ARGB4444 packed colour, high byte first.
End Rem
Const PF_ARGB4444_BE:Int=25
Rem
bbdoc: ABGR4444 packed colour, low byte first.
End Rem
Const PF_ABGR4444_LE:Int=26
Rem
bbdoc: ABGR4444 packed colour, high byte first.
End Rem
Const PF_ABGR4444_BE:Int=27
Rem
bbdoc: RGBA5551 packed colour, low byte first.
End Rem
Const PF_RGBA5551_LE:Int=28
Rem
bbdoc: RGBA5551 packed colour, high byte first.
End Rem
Const PF_RGBA5551_BE:Int=29
Rem
bbdoc: BGRA5551 packed colour, low byte first.
End Rem
Const PF_BGRA5551_LE:Int=30
Rem
bbdoc: BGRA5551 packed colour, high byte first.
End Rem
Const PF_BGRA5551_BE:Int=31
Rem
bbdoc: ARGB1555 packed colour, low byte first.
End Rem
Const PF_ARGB1555_LE:Int=32
Rem
bbdoc: ARGB1555 packed colour, high byte first.
End Rem
Const PF_ARGB1555_BE:Int=33
Rem
bbdoc: ABGR1555 packed colour, low byte first.
End Rem
Const PF_ABGR1555_LE:Int=34
Rem
bbdoc: ABGR1555 packed colour, high byte first.
End Rem
Const PF_ABGR1555_BE:Int=35
?LittleEndian
Const PF_RGBA4444:Int=PF_RGBA4444_LE
Const PF_BGRA4444:Int=PF_BGRA4444_LE
Const PF_ARGB4444:Int=PF_ARGB4444_LE
Const PF_ABGR4444:Int=PF_ABGR4444_LE
Const PF_RGBA5551:Int=PF_RGBA5551_LE
Const PF_BGRA5551:Int=PF_BGRA5551_LE
Const PF_ARGB1555:Int=PF_ARGB1555_LE
Const PF_ABGR1555:Int=PF_ABGR1555_LE
?BigEndian
Const PF_RGBA4444:Int=PF_RGBA4444_BE
Const PF_BGRA4444:Int=PF_BGRA4444_BE
Const PF_ARGB4444:Int=PF_ARGB4444_BE
Const PF_ABGR4444:Int=PF_ABGR4444_BE
Const PF_RGBA5551:Int=PF_RGBA5551_BE
Const PF_BGRA5551:Int=PF_BGRA5551_BE
Const PF_ARGB1555:Int=PF_ARGB1555_BE
Const PF_ABGR1555:Int=PF_ABGR1555_BE
?

Rem
bbdoc: One unsigned byte of red; missing green/blue are zero and alpha is opaque.
about: Unlike the legacy PF_RED conversion, this format expands with alpha 255.
End Rem
Const PF_R8:Int=36
Rem
bbdoc: Two unsigned bytes in red, green order; blue is zero and alpha is opaque.
End Rem
Const PF_RG88:Int=37
Rem
bbdoc: Two unsigned bytes in intensity, alpha order; intensity expands to RGB.
End Rem
Const PF_IA88:Int=38
Rem
bbdoc: Two unsigned bytes in alpha, intensity order; intensity expands to RGB.
End Rem
Const PF_AI88:Int=39

Rem
bbdoc: Four native-endian IEEE binary16 channels, stored as R, G, B, A (eight bytes per pixel).
about: Texture storage only; TPixmap colour operations do not support floating-point formats.
End Rem
Const PF_RGBA16F:Int=40
Rem
bbdoc: Four native-endian IEEE binary32 channels, stored as R, G, B, A (sixteen bytes per pixel).
about: Texture storage only; TPixmap colour operations do not support floating-point formats.
End Rem
Const PF_RGBA32F:Int=41

Rem
bbdoc: BC1 RGBA UNORM blocks (DXT1), with optional one-bit transparency.
about: Each 4x4 block occupies eight bytes in the standard little-endian BC encoding. Texture storage only; no implicit sRGB decoding or pixmap conversion.
End Rem
Const PF_BC1_RGBA:Int=42
Rem
bbdoc: BC3 RGBA UNORM blocks (DXT5), with interpolated alpha.
about: Each 4x4 block occupies sixteen bytes in the standard little-endian BC encoding. Uses straight alpha. Texture storage only; no implicit sRGB decoding or pixmap conversion.
End Rem
Const PF_BC3_RGBA:Int=43

Const PIXEL_ORDER_BYTES:Int=0
Const PIXEL_ORDER_LITTLE_ENDIAN:Int=1
Const PIXEL_ORDER_BIG_ENDIAN:Int=2

Rem
bbdoc: A snapshot describing an uncompressed pixel format or compressed block layout.
about: For uncompressed formats, channel bit counts describe stored precision. Compressed formats report bytesPerPixel and channel bit counts as zero; use blockWidth, blockHeight and bytesPerBlock. RowPitch and StorageSize return byte counts as Long. Palette and planar storage are not described yet.
End Rem
Type TPixelFormatInfo
	Field format:Int
	Field bytesPerPixel:Int
	Field redBits:Int,greenBits:Int,blueBits:Int,alphaBits:Int
	Field intensityBits:Int,luminanceBits:Int
	Field compressed:Int
	Field blockWidth:Int=1,blockHeight:Int=1,bytesPerBlock:Int
	Field floatingPoint:Int
	Field packed:Int
	Field byteOrder:Int=PIXEL_ORDER_BYTES
	' Bit positions in the decoded word, meaningful when packed is True.
	Field redShift:Int,greenShift:Int,blueShift:Int,alphaShift:Int

	Rem
	bbdoc: Computes row pitch with positive byte alignment; dimensions must be nonnegative.
	End Rem
	Method RowPitch:Long(width:Int,alignment:Int=1)
		If width<0 Or alignment<=0 Then Throw "PixelFormat: invalid width or alignment"
		Local bytes:Long=Long(width)*bytesPerPixel
		If compressed Then bytes=((Long(width)+blockWidth-1)/blockWidth)*bytesPerBlock
		Return ((bytes+alignment-1)/alignment)*alignment
	End Method

	Rem
	bbdoc: Number of stored rows: pixel rows for uncompressed formats, block rows otherwise.
	End Rem
	Method StorageRows:Long(height:Int)
		If height<0 Then Throw "PixelFormat: invalid height"
		Return (Long(height)+blockHeight-1)/blockHeight
	End Method

	Rem
	bbdoc: Computes storage for an image, rejecting values beyond signed Long range.
	End Rem
	Method StorageSize:Long(width:Int,height:Int,alignment:Int=1)
		If height<0 Then Throw "PixelFormat: invalid height"
		Local pitch:Long=RowPitch(width,alignment)
		Local rows:Long=StorageRows(height)
		If rows>0 And pitch>9223372036854775807:Long/rows Then Throw "PixelFormat: storage size overflow"
		Return pitch*rows
	End Method
End Type

Rem
bbdoc: Returns independent format information, or Null for an unknown format.
about: Describes storage only, not graphics-device support or every operation a consumer implements. Does not consult the legacy mutable Pixmap lookup tables. Retain the result when making repeated queries.
End Rem
Function GetPixelFormatInfo:TPixelFormatInfo(format:Int)
	If format<PF_I8 Or format>PF_BC3_RGBA Then Return Null
	Local info:TPixelFormatInfo=New TPixelFormatInfo
	info.format=format
	Select format
	Case PF_BC1_RGBA,PF_BC3_RGBA
		info.compressed=True
		info.blockWidth=4
		info.blockHeight=4
		info.bytesPerBlock=8
		If format=PF_BC3_RGBA Then info.bytesPerBlock=16
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
	Case PF_RGBA16F,PF_RGBA32F
		Local bits:Int=16
		If format=PF_RGBA32F Then bits=32
		info.bytesPerPixel=bits/2
		info.redBits=bits
		info.greenBits=bits
		info.blueBits=bits
		info.alphaBits=bits
		info.floatingPoint=True
?LittleEndian
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
?BigEndian
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
?
	Case PF_I8
		info.bytesPerPixel=1
		info.intensityBits=8
	Case PF_A8,PF_ALPHA
		info.bytesPerPixel=1
		info.alphaBits=8
	Case PF_RGB888,PF_BGR888
		info.bytesPerPixel=3
		info.redBits=8
		info.greenBits=8
		info.blueBits=8
	Case PF_RGBA8888,PF_BGRA8888,PF_ARGB8888,PF_ABGR8888
		info.bytesPerPixel=4
		info.redBits=8
		info.greenBits=8
		info.blueBits=8
		info.alphaBits=8
	Case PF_RED
		info.bytesPerPixel=1
		info.redBits=8
	Case PF_GREEN
		info.bytesPerPixel=1
		info.greenBits=8
	Case PF_BLUE
		info.bytesPerPixel=1
		info.blueBits=8
	Case PF_INTENSITY
		info.bytesPerPixel=1
		info.intensityBits=8
	Case PF_LUMINANCE
		info.bytesPerPixel=1
		info.luminanceBits=8
	Case PF_RGB565_LE,PF_RGB565_BE,PF_BGR565_LE,PF_BGR565_BE
		info.bytesPerPixel=2
		info.redBits=5
		info.greenBits=6
		info.blueBits=5
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.redShift=11
		info.greenShift=5
		If format=PF_BGR565_LE Or format=PF_BGR565_BE Then
			info.redShift=0
			info.blueShift=11
		End If
		If format=PF_RGB565_BE Or format=PF_BGR565_BE Then info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
	Case PF_RGB332
		info.bytesPerPixel=1
		info.packed=True
		info.redBits=3
		info.redShift=5
		info.greenBits=3
		info.greenShift=2
		info.blueBits=2
		info.blueShift=0
	Case PF_RGBA4444_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.redBits=4
		info.redShift=12
		info.greenBits=4
		info.greenShift=8
		info.blueBits=4
		info.blueShift=4
		info.alphaBits=4
		info.alphaShift=0
	Case PF_RGBA4444_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.redBits=4
		info.redShift=12
		info.greenBits=4
		info.greenShift=8
		info.blueBits=4
		info.blueShift=4
		info.alphaBits=4
		info.alphaShift=0
	Case PF_BGRA4444_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.blueBits=4
		info.blueShift=12
		info.greenBits=4
		info.greenShift=8
		info.redBits=4
		info.redShift=4
		info.alphaBits=4
		info.alphaShift=0
	Case PF_BGRA4444_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.blueBits=4
		info.blueShift=12
		info.greenBits=4
		info.greenShift=8
		info.redBits=4
		info.redShift=4
		info.alphaBits=4
		info.alphaShift=0
	Case PF_ARGB4444_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.alphaBits=4
		info.alphaShift=12
		info.redBits=4
		info.redShift=8
		info.greenBits=4
		info.greenShift=4
		info.blueBits=4
		info.blueShift=0
	Case PF_ARGB4444_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.alphaBits=4
		info.alphaShift=12
		info.redBits=4
		info.redShift=8
		info.greenBits=4
		info.greenShift=4
		info.blueBits=4
		info.blueShift=0
	Case PF_ABGR4444_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.alphaBits=4
		info.alphaShift=12
		info.blueBits=4
		info.blueShift=8
		info.greenBits=4
		info.greenShift=4
		info.redBits=4
		info.redShift=0
	Case PF_ABGR4444_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.alphaBits=4
		info.alphaShift=12
		info.blueBits=4
		info.blueShift=8
		info.greenBits=4
		info.greenShift=4
		info.redBits=4
		info.redShift=0
	Case PF_RGBA5551_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.redBits=5
		info.redShift=11
		info.greenBits=5
		info.greenShift=6
		info.blueBits=5
		info.blueShift=1
		info.alphaBits=1
		info.alphaShift=0
	Case PF_RGBA5551_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.redBits=5
		info.redShift=11
		info.greenBits=5
		info.greenShift=6
		info.blueBits=5
		info.blueShift=1
		info.alphaBits=1
		info.alphaShift=0
	Case PF_BGRA5551_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.blueBits=5
		info.blueShift=11
		info.greenBits=5
		info.greenShift=6
		info.redBits=5
		info.redShift=1
		info.alphaBits=1
		info.alphaShift=0
	Case PF_BGRA5551_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.blueBits=5
		info.blueShift=11
		info.greenBits=5
		info.greenShift=6
		info.redBits=5
		info.redShift=1
		info.alphaBits=1
		info.alphaShift=0
	Case PF_ARGB1555_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.alphaBits=1
		info.alphaShift=15
		info.redBits=5
		info.redShift=10
		info.greenBits=5
		info.greenShift=5
		info.blueBits=5
		info.blueShift=0
	Case PF_ARGB1555_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.alphaBits=1
		info.alphaShift=15
		info.redBits=5
		info.redShift=10
		info.greenBits=5
		info.greenShift=5
		info.blueBits=5
		info.blueShift=0
	Case PF_ABGR1555_LE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN
		info.alphaBits=1
		info.alphaShift=15
		info.blueBits=5
		info.blueShift=10
		info.greenBits=5
		info.greenShift=5
		info.redBits=5
		info.redShift=0
	Case PF_ABGR1555_BE
		info.bytesPerPixel=2
		info.packed=True
		info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
		info.alphaBits=1
		info.alphaShift=15
		info.blueBits=5
		info.blueShift=10
		info.greenBits=5
		info.greenShift=5
		info.redBits=5
		info.redShift=0
	Case PF_R8
		info.bytesPerPixel=1
		info.redBits=8
	Case PF_RG88
		info.bytesPerPixel=2
		info.redBits=8
		info.greenBits=8
	Case PF_IA88,PF_AI88
		info.bytesPerPixel=2
		info.intensityBits=8
		info.alphaBits=8
	End Select
	If Not info.compressed Then info.bytesPerBlock=info.bytesPerPixel
	Return info
End Function
