Rem
bbdoc: RGB transfer encoding; alpha is always linear coverage.
End Rem
Enum ETextureEncoding
	Linear = 0
	SRGB = 1
End Enum

Rem
bbdoc: Maps exposed linear RGB to the output range.
about: Clamp clips to 0–1. Reinhard maps each nonnegative channel x to x/(1+x); this simple operator can change saturation.
End Rem
Enum ETextureToneMap
	Clamp = 0
	Reinhard = 1
End Enum

Rem
bbdoc: Describes how source RGB relates to alpha.
End Rem
Enum ETextureAlphaMode
	Straight = 0
	Premultiplied = 1
End Enum

Rem
bbdoc: Explicit policy for converting texture data to an RGBA8888 pixmap.
about: Defaults preserve linear values with zero exposure adjustment and clipping. Source encoding and alpha mode describe the supplied bytes, not metadata inferred from their format. Output always uses straight alpha. Exposure is in stops, from -64 to 64. No dithering is performed.
End Rem
Type TTexturePixmapOptions
	Field sourceEncoding:ETextureEncoding=ETextureEncoding.Linear
	Field outputEncoding:ETextureEncoding=ETextureEncoding.Linear
	Field sourceAlpha:ETextureAlphaMode=ETextureAlphaMode.Straight
	Field toneMap:ETextureToneMap=ETextureToneMap.Clamp
	Field exposureStops:Double
End Type
