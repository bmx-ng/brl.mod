SuperStrict
Framework BRL.StandardIO
Import BRL.Pixmap

Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function

Try
	' Independently specified channel-placement examples: packed word -> ARGB.
	Local formats:Int[]=[PF_RGB332,PF_RGBA4444_LE,PF_BGRA4444_LE,PF_ARGB4444_LE,PF_ABGR4444_LE,PF_RGBA5551_LE,PF_BGRA5551_LE,PF_ARGB1555_LE,PF_ABGR1555_LE]
	Local words:Int[] =[$e0,$1234,$1234,$1234,$1234,$f801,$f801,$fc00,$fc00]
	Local colors:Int[]=[$ffff0000,$44112233,$44332211,$11223344,$11443322,$ffff0000,$ff0000ff,$ffff0000,$ff0000ff]
	For Local index:Int=0 Until formats.Length
		Local base:Int=formats[index]
		Local variants:Int=2
		If base=PF_RGB332 Then variants=1
		For Local variant:Int=0 Until variants
			Local format:Int=base+variant
			Local info:TPixelFormatInfo=GetPixelFormatInfo(format)
			Local bytes:Int=info.bytesPerPixel
			Local big:Int=info.byteOrder=PIXEL_ORDER_BIG_ENDIAN
			Check(info.packed,"Packed descriptor")
			Check(AlphaBitsPerPixel[format]=info.alphaBits,"Alpha metadata")
			Local count:Int=65536
			If bytes=1 Then count=256
			Local packed:TPixmap=CreatePixmap(count,1,format,1)
			For Local value:Int=0 Until count
				Local p:Byte Ptr=packed.PixelPtr(value,0)
				If bytes=1 Then
					p[0]=value
				Else If big Then
					p[0]=value Shr 8
					p[1]=value
				Else
					p[0]=value
					p[1]=value Shr 8
				End If
			Next
			Check(packed.ReadPixel(words[index],0)=colors[index],"Known channel placement: "+format)
			Local expanded:TPixmap=packed.Convert(PF_RGBA8888)
			Local restored:TPixmap=expanded.Convert(format)
			For Local value:Int=0 Until count
				For Local offset:Int=0 Until bytes
					Check(packed.pixels[value*bytes+offset]=restored.pixels[value*bytes+offset],"Exact packed round trip: "+format)
				Next
			Next
			Local buffer:Byte[48]
			For Local i:Int=0 Until buffer.Length
				buffer[i]=$cd
			Next
			Local small:TPixmap=TPixmap.CreateStatic(Varptr buffer[1],3,2,11,format)
			small.ClearPixels(colors[index])
			Check(small.ReadPixel(2,1)=colors[index],"Clear handles pitch and unaligned buffer")
			For Local y:Int=0 Until 2
				For Local x:Int=3*bytes Until 11
					Check(buffer[1+y*11+x]=$cd,"Row guard")
				Next
			Next
			Check(buffer[0]=$cd And buffer[23]=$cd,"Outer guards")
			small.WritePixel(0,0,New SColor8(colors[index]))
			Check(small.ReadPixel(0,0)=colors[index],"Colour overload")
			small.WritePixel(0,0,colors[index])
			Check(small.ReadPixel(0,0)=colors[index],"Integer overload")
			Check(small.Copy().ReadPixel(0,0)=colors[index],"Copy")
			Check(XFlipPixmap(small).ReadPixel(0,1)=colors[index],"Flip")
			Check(ResizePixmap(small,6,4).ReadPixel(2,2)=colors[index],"Resize")
			small.Window(1,0,1,2).ClearPixels(0)
			Local empty:Int=0
			If info.alphaBits=0 Then empty=$ff000000
			Check(small.ReadPixel(1,1)=empty And small.ReadPixel(0,1)=colors[index],"Window clear")
			If info.alphaBits=1 Then
				small.WritePixel(0,0,$7fffffff)
				Check(small.ReadPixel(0,0)=$00ffffff,"One-bit alpha rejects 127")
				small.WritePixel(0,0,$80ffffff)
				Check(small.ReadPixel(0,0)=$ffffffff,"One-bit alpha accepts 128")
			End If
		Next
	Next
	Print "Compact pixel formats passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
