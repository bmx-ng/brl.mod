SuperStrict
Framework BRL.TextureData
Import BRL.StandardIO
Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function
Try
	For Local format:Int=EachIn [PF_BC1_RGBA,PF_BC3_RGBA]
		Local info:TPixelFormatInfo=GetPixelFormatInfo(format)
		Local block:Int=8
		If format=PF_BC3_RGBA Then block=16
		Check(info.compressed And info.bytesPerPixel=0,"Compressed metadata")
		Check(info.blockWidth=4 And info.blockHeight=4 And info.bytesPerBlock=block,"Block layout")
		Check(info.RowPitch(5)=block*2 And info.StorageRows(7)=2,"Rounded block counts")
		Check(info.StorageSize(1,1)=block And info.StorageSize(7,5)=block*4,"Small mips occupy a full block")
		Check(info.StorageSize(0,5)=0 And info.StorageSize(5,0)=0,"Zero storage extent")
		Check(info.RowPitch(2147483647)=Long(536870912)*block,"Wide dimension arithmetic")
		Local pitch:Int=block*2+5
		Local bytes:Byte[]=New Byte[pitch*2]
		bytes[bytes.Length-1]=123
		Local data:TTextureData=TTextureData.Create([TTextureLevel.Create(7,5,format,bytes,pitch)])
		Check(data.ByteSize()=pitch*2,"Pitch counts block rows")
		bytes[bytes.Length-1]=0
		Check(data.Level().Data()[pitch*2-1]=123,"Padding survives independent snapshot")
		For Local invalid:Int=0 Until 4
			Local rejected:Int
			Try
				Select invalid
					Case 0
						TTextureLevel.Create(7,5,format,New Byte[block*4-1])
					Case 1
						TTextureLevel.Create(7,5,format,bytes,block)
					Case 2
						data.ToPixmap()
					Case 3
						CreatePixmap(4,4,format)
				End Select
			Catch error:Object
				rejected=True
			End Try
			Check(rejected,"Invalid compressed/pixmap operation rejected "+invalid)
		Next
	Next
	Local rgba:TPixelFormatInfo=GetPixelFormatInfo(PF_RGBA8888)
	Check(rgba.blockWidth=1 And rgba.blockHeight=1 And rgba.bytesPerBlock=4,"Uncompressed block metadata")
	Check(rgba.StorageSize(7,5)=140 And rgba.StorageRows(5)=5,"Uncompressed layout unchanged")
	Print "Compressed texture storage tests passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
