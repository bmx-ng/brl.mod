SuperStrict
Framework BRL.TextureData
Import BRL.StandardIO
Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function
Try
	Local bytes:Byte[]=New Byte[69]
	For Local i:Int=0 Until bytes.Length
		bytes[i]=i
	Next
	Local level:TTextureLevel=TTextureLevel.Create(5,3,PF_RGBA8888,bytes,23)
	bytes[0]=255
	Check(level.Data()[0]=0 And level.ByteSize()=69,"Level owns its padded bytes")
	Local data:TTextureData=TTextureData.Create([level])
	level.Data()[0]=254
	Check(data.Level().Data()[0]=0,"Data snapshots supplied levels")
	Local pixmap:TPixmap=data.ToPixmap()
	Check(pixmap.PixelPtr(0,1)[0]=23,"Odd pitch rows converted correctly")
	pixmap.WritePixel(0,0,$ffffffff)
	Check(data.Level().Data()[0]=0,"Pixmap conversion is independent")
	Local parent:TPixmap=CreatePixmap(7,3,PF_RGB565)
	parent.ClearPixels($ff00ff00)
	Local fromWindow:TTextureData=TTextureData.FromPixmap(parent.Window(1,1,2,2))
	parent.ClearPixels(0)
	Check(fromWindow.Format()=PF_RGB565 And fromWindow.Level().Pitch()=4,"Pixmap windows preserve format with compact rows")
	Check(fromWindow.ToPixmap().ReadPixel(1,1)=$ff00ff00,"Window snapshot retains pixels")
	Local chain:TTextureData=TTextureData.Create([..
		TTextureLevel.Create(7,5,PF_RGBA8888,New Byte[140]),..
		TTextureLevel.Create(3,2,PF_RGBA8888,New Byte[24]),..
		TTextureLevel.Create(1,1,PF_RGBA8888,New Byte[4])])
	Check(chain.CompleteMipChain() And chain.ByteSize()=168,"Odd-size mip chain dimensions and storage")
	Check(chain.ToPixmap(1).width=3,"Select mip for pixmap conversion")
	Local copy:TTextureData=chain.Copy()
	chain.Level(1).Data()[0]=99
	Check(copy.Level(1).Data()[0]=0,"Deep mip-chain copy")
	For Local invalid:Int=0 Until 11
		Local rejected:Int
		Try
			Select invalid
				Case 0
					TTextureLevel.Create(5,3,PF_RGBA8888,New Byte[68],23)
				Case 1
					TTextureLevel.Create(5,3,PF_RGBA8888,New Byte[60],19)
				Case 2
					TTextureLevel.Create(0,1,PF_A8,New Byte[1])
				Case 3
					TTextureLevel.Create(1,1,999,New Byte[4])
				Case 4
					TTextureLevel.Create($7fffffff,2,PF_RGBA8888,New Byte[0])
				Case 5
					TTextureData.Create(New TTextureLevel[0])
				Case 6
					TTextureData.Create([chain.Level(0),chain.Level(2)])
				Case 7
					TTextureData.Create([chain.Level(2),chain.Level(2)])
				Case 8
					TTextureData.Create([chain.Level(0),TTextureLevel.Create(3,2,PF_A8,New Byte[6])])
				Case 9
					TTextureData.Create(New TTextureLevel[1])
				Case 10
					chain.Level(-1)
			End Select
		Catch error:Object
			rejected=True
		End Try
		Check(rejected,"Reject invalid texture layout "+invalid)
	Next
	Print "Texture data tests passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
