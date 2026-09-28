SuperStrict
Framework BRL.StandardIO
Import BRL.Pixmap

Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function

Try
	Check(PF_RGBA8888=6 And PF_ABGR8888=14,"Existing identifiers preserved")
	Check(GetPixelFormatInfo(0)=Null And GetPixelFormatInfo(999)=Null,"Unknown format")
	Local info:TPixelFormatInfo=GetPixelFormatInfo(PF_RGB565_BE)
	Check(info.bytesPerPixel=2 And info.redBits=5 And info.greenBits=6 And info.blueBits=5 And info.alphaBits=0,"565 metadata")
	Check(info.RowPitch(3,4)=8 And info.StorageSize(3,2,4)=16,"Padded size")
	Local rejected:Int
	Try
		GetPixelFormatInfo(PF_RGBA8888).StorageSize(2147483647,2147483647)
	Catch error:Object
		rejected=True
	End Try
	Check(rejected,"Storage overflow rejected")
	For Local format:Int=PF_RGB565_LE To PF_BGR565_BE
		Local packed:TPixmap=CreatePixmap(65536,1,format,1)
		Local big:Int=format=PF_RGB565_BE Or format=PF_BGR565_BE
		For Local value:Int=0 Until 65536
			Local p:Byte Ptr=packed.PixelPtr(value,0)
			If big Then
				p[0]=value Shr 8
				p[1]=value
			Else
				p[0]=value
				p[1]=value Shr 8
			End If
		Next
		Check(packed.ReadPixel($07e0,0)=$ff00ff00,"Known green bit pattern")
		Check(packed.ReadPixel(0,0)=$ff000000 And packed.ReadPixel($ffff,0)=$ffffffff,"Known black and white patterns")
		Local expanded:TPixmap=packed.Convert(PF_RGBA8888)
		Local restored:TPixmap=expanded.Convert(format)
		For Local value:Int=0 Until 65536
			Local p:Byte Ptr=packed.PixelPtr(value,0),q:Byte Ptr=restored.PixelPtr(value,0)
			Check(p[0]=q[0] And p[1]=q[1],"Every packed value survives expansion and requantisation")
			Check(packed.ReadPixel(value,0)=expanded.ReadPixel(value,0),"Read agrees with conversion")
		Next
		Local small:TPixmap=CreatePixmap(3,2,format)
		small.ClearPixels($ffff0000)
		Check(small.ReadPixel(2,1)=$ffff0000,"Padded clear")
		Local expected:Int=$f800
		If format=PF_BGR565_LE Or format=PF_BGR565_BE Then expected=$001f
		If big Then
			Check(small.pixels[0]=expected Shr 8 And small.pixels[1]=(expected&255),"Big endian red bytes")
		Else
			Check(small.pixels[1]=expected Shr 8 And small.pixels[0]=(expected&255),"Little endian red bytes")
		End If
		small.WritePixel(1,0,New SColor8(0,255,0,3))
		small.WritePixel(2,1,$ff0000ff)
		Check(small.ReadPixel(1,0)=$ff00ff00,"Colour write discards alpha")
		Check(small.ReadPixel(2,1)=$ff0000ff,"Integer write")
		Local copy:TPixmap=small.Copy()
		Local flipped:TPixmap=XFlipPixmap(copy)
		Check(flipped.ReadPixel(0,1)=$ff0000ff,"Copy and horizontal flip")
		Check(YFlipPixmap(copy).ReadPixel(2,0)=$ff0000ff,"Vertical flip")
		Check(ResizePixmap(copy,6,4).format=format,"Resize retains format")
		Local window:TPixmap=small.Window(1,0,1,2)
		window.ClearPixels($ffffffff)
		Check(small.ReadPixel(1,1)=$ffffffff And small.ReadPixel(0,1)=$ffff0000,"Window clear respects parent pitch")
		small.Paste(expanded.Window(0,0,3,1),0,0)
		Check(small.ReadPixel(0,0)=expanded.ReadPixel(0,0),"Cross-format paste")
		Local unaligned:Byte[9]
		Local external:TPixmap=TPixmap.CreateStatic(Varptr unaligned[1],2,2,4,format)
		external.WritePixel(1,1,$ffffffff)
		Check(external.ReadPixel(1,1)=$ffffffff,"Unaligned external storage")
	Next
	' Legacy four-channel access and clear must agree, including padding guards.
	For Local format:Int=1 To 14
		If format>PF_RGBA8888 And format<PF_ARGB8888 Then Continue
		Local storage:Byte[128]
		For Local i:Int=0 Until storage.Length
			storage[i]=$cd
		Next
		Local p:TPixmap=TPixmap.CreateStatic(storage,3,2,20,format)
		p.ClearPixels($a1234567)
		Local expected:TPixmap=CreatePixmap(1,1,PF_RGBA8888)
		expected.WritePixel(0,0,$a1234567)
		expected=expected.Convert(format)
		For Local y:Int=0 Until 2
			For Local x:Int=0 Until 3
				Check(p.ReadPixel(x,y)=expected.ReadPixel(0,0),"Legacy clear format "+format)
			Next
			For Local x:Int=3*BytesPerPixel[format] Until 20
				Check(storage[y*20+x]=$cd,"Clear preserves padding")
			Next
		Next
		For Local i:Int=40 Until storage.Length
			Check(storage[i]=$cd,"Clear stays inside storage")
		Next
		p.WritePixel(0,0,$a1234567)
		Check(p.ReadPixel(0,0)=expected.ReadPixel(0,0),"Legacy integer write")
	Next
	Print "Packed pixel formats passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
