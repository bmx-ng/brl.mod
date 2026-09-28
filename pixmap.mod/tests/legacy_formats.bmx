SuperStrict
Framework BRL.StandardIO
Import BRL.Pixmap

Function Check(ok:Int,message:String)
	If Not ok Then Throw message
End Function
Function Stored:Int(argb:Int,format:Int)
	Select format
	Case PF_A8
		Return (argb&$ff000000)|$ffffff
	Case PF_I8
		Local intensity:Int=((argb Shr 16 & 255)+(argb Shr 8 & 255)+(argb&255))/3
		Return $ff000000|(intensity Shl 16)|(intensity Shl 8)|intensity
	Case PF_RGB888,PF_BGR888
		Return $ff000000|(argb&$ffffff)
	Default
		Return argb
	End Select
End Function
Try
	Local formats:Int[]=[PF_I8,PF_A8,PF_BGR888,PF_RGB888,PF_BGRA8888,PF_RGBA8888,PF_ARGB8888,PF_ABGR8888]
	Local identifiers:Int[]=[1,2,3,4,5,6,13,14]
	Local bytes:Int[]=[0,1,1,3,3,4,4,1,1,1,1,1,1,4,4]
	Local bits:Int[]=[0,8,8,24,24,32,32,4,4,4,4,4,4,32,32]
	Local alpha:Int[]=[0,0,8,0,0,8,8,0,0,0,8,0,0,8,8]
	For Local i:Int=0 Until bytes.Length
		Check(BytesPerPixel[i]=bytes[i] And BitsPerPixel[i]=bits[i] And AlphaBitsPerPixel[i]=alpha[i],"Existing format tables")
	Next
	Check(PF_STDFORMAT=6,"Default format")
	Local colors:Int[]=[$12345678,$ffabcdef,$00010203,$ffffffff,$ff000000]
	For Local index:Int=0 Until formats.Length
		Local format:Int=formats[index]
		Check(format=identifiers[index],"Existing format identifiers")
		Local p:TPixmap=CreatePixmap(5,3,format)
		Check(p.pitch=((5*bytes[format]+3)/4)*4,"Default row alignment")
		For Local color:Int=EachIn colors
			Local expected:Int=Stored(color,format)
			p.ClearPixels(color)
			Check(p.ReadPixel(4,2)=expected,"Clear")
			p.WritePixel(0,0,color)
			p.WritePixel(1,0,New SColor8(color))
			Check(p.ReadPixel(0,0)=expected And p.ReadPixel(1,0)=expected,"Both write overloads")
			Check(p.Copy().ReadPixel(4,2)=expected,"Copy")
			Check(XFlipPixmap(p).ReadPixel(0,0)=expected And YFlipPixmap(p).ReadPixel(4,2)=expected,"Flips")
			Check(ResizePixmap(p,7,5).ReadPixel(3,2)=expected,"Uniform resize")
			For Local destination:Int=EachIn formats
				Local converted:TPixmap=p.Convert(destination)
				Check(converted.ReadPixel(4,2)=Stored(expected,destination),"Every legacy conversion pair")
				Local target:TPixmap=CreatePixmap(7,5,destination)
				target.ClearPixels(0)
				target.Paste(p,1,1)
				Check(target.ReadPixel(5,3)=Stored(expected,destination),"Cross-format paste")
			Next
		Next
	Next
	Print "Legacy pixmap formats passed"
Catch error:Object
	Print "FAILED: "+error.ToString()
	EndWithCode(1)
End Try
