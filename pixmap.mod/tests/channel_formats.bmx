SuperStrict
Framework BRL.StandardIO
Import BRL.Pixmap

Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function
Function Expected:Int(argb:Int,format:Int)
	Local intensity:Int=((argb Shr 16 & 255)+(argb Shr 8 & 255)+(argb & 255))/3
	Select format
	Case PF_R8
		Return $ff000000 | (argb & $ff0000)
	Case PF_RG88
		Return $ff000000 | (argb & $ffff00)
	Default
		Return (argb & $ff000000) | (intensity Shl 16) | (intensity Shl 8) | intensity
	End Select
End Function
Try
	For Local format:Int=PF_R8 To PF_AI88
		Local info:TPixelFormatInfo=GetPixelFormatInfo(format)
		Check(Not info.packed And info.byteOrder=PIXEL_ORDER_BYTES,"Channel arrays have fixed byte order")
		Check(BytesPerPixel[format]=info.bytesPerPixel And AlphaBitsPerPixel[format]=info.alphaBits,"Storage metadata")
		Local count:Int=65536
		If format=PF_R8 Then count=256
		Local p:TPixmap=CreatePixmap(count,1,format,1)
		For Local value:Int=0 Until count
			Local pixel:Byte Ptr=p.PixelPtr(value,0)
			pixel[0]=value
			If info.bytesPerPixel=2 Then pixel[1]=value Shr 8
		Next
		Local expanded:TPixmap=p.Convert(PF_RGBA8888)
		Local restored:TPixmap=expanded.Convert(format)
		For Local value:Int=0 Until count
			Local expected:Int
			Local low:Int=value&255
			Local high:Int=value Shr 8
			Select format
			Case PF_R8
				expected=$ff000000 | (low Shl 16)
			Case PF_RG88
				expected=$ff000000 | (low Shl 16) | (high Shl 8)
			Case PF_IA88
				expected=(high Shl 24) | (low Shl 16) | (low Shl 8) | low
			Case PF_AI88
				expected=(low Shl 24) | (high Shl 16) | (high Shl 8) | high
			End Select
			Check(p.ReadPixel(value,0)=expected And expanded.ReadPixel(value,0)=expected,"Independent channel interpretation")
			For Local offset:Int=0 Until info.bytesPerPixel
				Check(p.pixels[value*info.bytesPerPixel+offset]=restored.pixels[value*info.bytesPerPixel+offset],"Every stored value survives conversion")
			Next
		Next
		Local guard:Byte[64]
		For Local i:Int=0 Until guard.Length
			guard[i]=$cd
		Next
		Local small:TPixmap=TPixmap.CreateStatic(Varptr guard[1],3,2,13,format)
		Local color:Int=$7f204060
		Local expectedColor:Int=Expected(color,format)
		small.ClearPixels(color)
		small.WritePixel(0,0,color)
		small.WritePixel(1,0,New SColor8(color))
		Check(small.ReadPixel(0,0)=expectedColor And small.ReadPixel(1,0)=expectedColor And small.ReadPixel(2,1)=expectedColor,"Clear and both write overloads")
		For Local y:Int=0 Until 2
			For Local x:Int=3*info.bytesPerPixel Until 13
				Check(guard[1+y*13+x]=$cd,"Padding remains untouched")
			Next
		Next
		Check(guard[0]=$cd And guard[27]=$cd,"Outer guards")
		Check(small.Copy().ReadPixel(2,1)=expectedColor,"Copy")
		Check(XFlipPixmap(small).ReadPixel(0,1)=expectedColor,"Flip")
		Check(ResizePixmap(small,6,4).ReadPixel(3,2)=expectedColor,"Uniform resize")
		Local rgba:TPixmap=CreatePixmap(1,1,PF_RGBA8888)
		rgba.WritePixel(0,0,$ab123456)
		small.Paste(rgba,2,1)
		Check(small.ReadPixel(2,1)=Expected($ab123456,format),"Cross-format paste")
		small.Window(1,0,1,2).ClearPixels(0)
		Check(small.ReadPixel(1,1)=Expected(0,format) And small.ReadPixel(0,1)=expectedColor,"Subwindow clear")
	Next
	' PF_RED's historical conversion remains distinct from the new opaque PF_R8.
	Local legacy:TPixmap=CreatePixmap(1,1,PF_RED)
	legacy.pixels[0]=123
	Check(legacy.Convert(PF_RGBA8888).ReadPixel(0,0)=$017b0000,"Legacy PF_RED unchanged")
	Print "Channel pixel formats passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
