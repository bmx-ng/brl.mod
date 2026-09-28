SuperStrict
Framework BRL.TextureData
Import BRL.StandardIO
Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function
Try
	Local placeholder:TPixmap=CreatePixmap(1,1,0)
	Check(placeholder.format=0,"Legacy zero-format placeholder remains accepted")
	For Local format:Int=PF_RGBA16F To PF_RGBA32F
		Local info:TPixelFormatInfo=GetPixelFormatInfo(format)
		Check(info.floatingPoint And info.redBits=info.bytesPerPixel*2 And info.alphaBits=info.redBits,"Floating precision metadata")
		Check(info.RowPitch(3)=info.bytesPerPixel*3 And info.StorageSize(3,2)=info.bytesPerPixel*6,"Floating storage layout")
?LittleEndian
		Check(info.byteOrder=PIXEL_ORDER_LITTLE_ENDIAN,"Native float byte order")
?BigEndian
		Check(info.byteOrder=PIXEL_ORDER_BIG_ENDIAN,"Native float byte order")
?
		Local bytes:Byte[]=New Byte[info.bytesPerPixel]
		For Local i:Int=0 Until bytes.Length
			bytes[i]=i*13
		Next
		Local data:TTextureData=TTextureData.Create([TTextureLevel.Create(1,1,format,bytes)])
		Local copy:Byte[]=data.Copy().Level().CopyBytes()
		For Local i:Int=0 Until bytes.Length
			Check(copy[i]=bytes[i],"Opaque float bytes preserved")
		Next
		For Local invalid:Int=0 Until 6
			Local rejected:Int
			Try
				Select invalid
					Case 0
						CreatePixmap(1,1,format)
					Case 1
						CreateStaticPixmap(bytes,1,1,info.bytesPerPixel,format)
					Case 2
						data.ToPixmap()
					Case 3
						ConvertPixels(bytes,format,copy,PF_RGBA8888,1)
					Case 4
						ConvertPixels(bytes,PF_RGBA8888,copy,format,1)
					Case 5
						CopyPixels(bytes,copy,format,1)
				End Select
			Catch error:Object
				rejected=True
			End Try
			Check(rejected,"Pixmap rejects float operation "+invalid)
		Next
	Next
	Check(Not GetPixelFormatInfo(PF_RGBA8888).floatingPoint,"Existing formats unchanged")
	Print "Floating texture storage tests passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
