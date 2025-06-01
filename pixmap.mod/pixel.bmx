
SuperStrict

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

Global BytesPerPixel:Int[]=			[0,1,1,3,3,4,4, 1,1,1,1,1,1,4,4]

Global RedBitsPerPixel:Int[]=		[1,0,0,8,8,8,8, 8,0,0,0,0,0,8,8] ' Max2d compressed textures version
Global GreenBitsPerPixel:Int[]=		[0,0,0,8,8,8,8, 0,8,0,0,0,0,8,8] ' stores dds format
Global BlueBitsPerPixel:Int[]=		[0,0,0,8,8,8,8, 0,0,8,0,0,0,8,8] ' stores texture name
Global AlphaBitsPerPixel:Int[]=		[0,0,8,0,0,8,8, 0,0,0,8,0,0,8,8]
Global IntensityBitsPerPixel:Int[]=	[0,0,0,0,0,0,0, 0,0,0,0,8,0,0,0]
Global LuminanceBitsPerPixel:Int[]=	[0,0,0,0,0,0,0, 0,0,0,0,0,8,0,0]

Global BitsPerPixel:Int[]=			[0,8,8,24,24,32,32, 4,4,4,4,4,4,32,32]
Global ColorBitsPerPixel:Int[]=		[0,0,0,24,24,24,24, 8,8,8,0,0,0,24,24]

Function CopyPixels( in_buf:Byte Ptr,out_buf:Byte Ptr,format:Int,count:Int )
	MemCopy out_buf,in_buf, Size_T(count*BytesPerPixel[format])
End Function

Function ConvertPixels( in_buf:Byte Ptr,in_format:Int,out_buf:Byte Ptr,out_format:Int,count:Int )
	If in_format=out_format
		CopyPixels in_buf,out_buf,out_format,count
	Else If in_format=PF_STDFORMAT
		ConvertPixelsFromStdFormat in_buf,out_buf,out_format,count
	Else If out_format=PF_STDFORMAT
		ConvertPixelsToStdFormat in_buf,out_buf,in_format,count
	Else
		Local tmp_buf:Int[count]
		ConvertPixelsToStdFormat in_buf,tmp_buf,in_format,count
		ConvertPixelsFromStdFormat tmp_buf,out_buf,out_format,count
	EndIf
End Function

Function ConvertPixelsToStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format:Int,count:Int )
	Local in:Byte Ptr=in_buf
	Local out:Byte Ptr=out_buf
	Local out_end:Byte Ptr=out+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_A8
		While out<>out_end
			out[0]=255
			out[1]=255
			out[2]=255
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_I8
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=255
			in:+1;out:+4
		Wend
	Case PF_RGB888
		While out<>out_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			out[3]=255
			in:+3;out:+4
		Wend
	Case PF_BGR888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=255
			in:+3;out:+4
		Wend
	Case PF_BGRA8888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4;out:+4
		Wend
	Case PF_ARGB8888
		While out<>out_end
			out[0]=in[1]
			out[1]=in[2]
			out[2]=in[3]
			out[3]=in[0]
			in:+4;out:+4
		Wend
	Case PF_ABGR8888
		While out<>out_end
			out[0]=in[3]
			out[1]=in[2]
			out[2]=in[1]
			out[3]=in[0]
			in:+4;out:+4
		Wend
	Case PF_RED
		While out<>out_end
			out[0]=in[0]
			out[1]=0
			out[2]=0
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_GREEN
		While out<>out_end
			out[0]=0
			out[1]=in[0]
			out[2]=0
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_BLUE
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=in[0]
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_ALPHA
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=0
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_INTENSITY
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_LUMINANCE
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function

Function ConvertPixelsFromStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format:Int,count:Int )
	Local out:Byte Ptr=out_buf
	Local in:Byte Ptr=in_buf
	Local in_end:Byte Ptr=in+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_A8
		While in<>in_end
			out[0]=in[3]
			in:+4;out:+1
		Wend
	Case PF_I8
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4;out:+1
		Wend
	Case PF_RGB888
		While in<>in_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			in:+4;out:+3
		Wend
	Case PF_BGR888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			in:+4;out:+3
		Wend
	Case PF_BGRA8888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4;out:+4
		Wend
	Case PF_ARGB8888 ' RGBA -> ARGB
		While in<>in_end
			out[0]=in[3]
			out[1]=in[0]
			out[2]=in[1]
			out[3]=in[2]
			in:+4;out:+4
		Wend
	Case PF_ABGR8888 ' RGBA -> ABGR
		While in<>in_end
			out[0]=in[3]
			out[1]=in[2]
			out[2]=in[1]
			out[3]=in[0]
			in:+4;out:+4
		Wend
	Case PF_RED
		While in<>in_end
			out[0]=in[0]
			in:+4;out:+1
		Wend
	Case PF_GREEN
		While in<>in_end
			out[0]=in[1]
			in:+4;out:+1
		Wend
	Case PF_BLUE
		While in<>in_end
			out[0]=in[2]
			in:+4;out:+1
		Wend
	Case PF_ALPHA
		While in<>in_end
			out[0]=in[3]
			in:+4;out:+1
		Wend
	Case PF_INTENSITY
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2]+in[3])/4
			in:+4;out:+1
		Wend
	Case PF_LUMINANCE
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4;out:+1
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function
