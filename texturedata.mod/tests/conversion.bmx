SuperStrict
Framework BRL.TextureData
Import BRL.StandardIO

Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function

Function ComponentAt:Int(p:TPixmap,x:Int,y:Int,channel:Int)
	Return p.PixelPtr(x,y)[channel]
End Function

Function Near(p:TPixmap,x:Int,y:Int,channel:Int,expected:Int,message:String)
	Check(Abs(ComponentAt(p,x,y,channel)-expected)<=1,message)
End Function

Try
	Local bytes:Byte[]=New Byte[66]
	Local values:Float[]=[2.0,-0.5,0.25,0.5,0.0031308,0.5,1.0,1.0]
	MemCopy(bytes,values,32)
	' Deliberately unaligned second row verifies byte-pitch handling.
	MemCopy(Varptr bytes[33],values,32)
	Local data:TTextureData=TTextureData.Create([TTextureLevel.Create(2,2,PF_RGBA32F,bytes,33)])
	Local options:TTexturePixmapOptions=New TTexturePixmapOptions
	Local pixels:TPixmap=data.ConvertToPixmap(options)
	Check(pixels.format=PF_RGBA8888,"RGBA output")
	For Local y:Int=0 Until 2
		Near(pixels,0,y,0,255,"Clip bright red")
		Near(pixels,0,y,1,0,"Clip negative green")
		Near(pixels,0,y,2,64,"Preserve blue")
		Near(pixels,0,y,3,128,"Preserve alpha")
	Next
	options.exposureStops=-1
	pixels=data.ConvertToPixmap(options)
	Near(pixels,0,0,2,32,"Negative exposure")
	Near(pixels,0,0,3,128,"Exposure does not affect alpha")
	options.exposureStops=0
	options.toneMap=ETextureToneMap.Reinhard
	pixels=data.ConvertToPixmap(options)
	Near(pixels,0,0,0,170,"Reinhard retains highlight detail")
	Near(pixels,0,0,2,51,"Reinhard blue")
	options.toneMap=ETextureToneMap.Clamp
	options.outputEncoding=ETextureEncoding.SRGB
	pixels=data.ConvertToPixmap(options)
	Near(pixels,1,0,0,10,"sRGB low branch")
	Near(pixels,1,0,1,188,"sRGB power branch")
	options.sourceEncoding=ETextureEncoding.SRGB
	options.outputEncoding=ETextureEncoding.Linear
	pixels=data.ConvertToPixmap(options)
	Near(pixels,1,0,1,55,"sRGB decode")
	options.sourceEncoding=ETextureEncoding.Linear
	options.sourceAlpha=ETextureAlphaMode.Premultiplied
	pixels=data.ConvertToPixmap(options)
	Near(pixels,0,0,2,128,"Unassociate before conversion")

	Local half:Short[]=[Short($3c00),Short($3800),Short($3400),Short($3800)]
	Local halfBytes:Byte[]=New Byte[8]
	MemCopy(halfBytes,half,8)
	Local halfData:TTextureData=TTextureData.Create([TTextureLevel.Create(1,1,PF_RGBA16F,halfBytes)])
	options.sourceAlpha=ETextureAlphaMode.Straight
	pixels=halfData.ConvertToPixmap(options)
	Near(pixels,0,0,0,255,"Half 1")
	Near(pixels,0,0,1,128,"Half 0.5")
	Near(pixels,0,0,2,64,"Half 0.25")

	Local special:Int[]=[$7f800000,$ff800000,$7fc00000,0]
	Local specialBytes:Byte[]=New Byte[16]
	MemCopy(specialBytes,special,16)
	Local specialData:TTextureData=TTextureData.Create([TTextureLevel.Create(1,1,PF_RGBA32F,specialBytes)])
	For Local mode:Int=0 Until 2
		If mode Then options.toneMap=ETextureToneMap.Reinhard
		pixels=specialData.ConvertToPixmap(options)
		Check(ComponentAt(pixels,0,0,0)=255 And ComponentAt(pixels,0,0,1)=0 And ComponentAt(pixels,0,0,2)=0,"Deterministic nonfinite RGB mode="+mode+" pixel="+pixels.ReadPixel(0,0))
	Next
	options.sourceAlpha=ETextureAlphaMode.Premultiplied
	pixels=specialData.ConvertToPixmap(options)
	Check(pixels.ReadPixel(0,0)=0,"Zero alpha unassociation")

	Local ordinary:TPixmap=CreatePixmap(2,1,PF_RGBA8888)
	ordinary.WritePixel(0,0,$804080ff)
	ordinary.WritePixel(1,0,$00abcdef)
	Local ordinaryData:TTextureData=TTextureData.FromPixmap(ordinary)
	options=New TTexturePixmapOptions
	pixels=ordinaryData.ConvertToPixmap(options)
	Check(pixels.ReadPixel(0,0)=ordinary.ReadPixel(0,0) And pixels.ReadPixel(1,0)=ordinary.ReadPixel(1,0),"Byte identity including transparent RGB")
	options.sourceEncoding=ETextureEncoding.SRGB
	options.outputEncoding=ETextureEncoding.SRGB
	pixels=ordinaryData.ConvertToPixmap(options)
	Check(pixels.ReadPixel(0,0)=ordinary.ReadPixel(0,0),"sRGB round trip")
	Check(data.Level().CopyBytes()[0]=bytes[0],"Source remains unchanged")
	For Local invalid:Int=0 Until 6
		Local rejected:Int
		Try
			Select invalid
				Case 0
					data.ConvertToPixmap(Null)
				Case 1
					options.exposureStops=65
					data.ConvertToPixmap(options)
				Case 2
					options.exposureStops=0
					data.ConvertToPixmap(options,2)
				Case 3
					data.ToPixmap()
				Case 4
					Local nanBits:Long=$7ff8000000000000:Long
					MemCopy(Varptr options.exposureStops,Varptr nanBits,8)
					data.ConvertToPixmap(options)
				Case 5
					options.exposureStops=0
					TTextureData.FromPixmap(CreatePixmap(1,1,PF_RGB565)).ConvertToPixmap(options)
			End Select
		Catch error:Object
			rejected=True
		End Try
		Check(rejected,"Invalid conversion rejected "+invalid)
	Next
	Print "Texture conversion tests passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
