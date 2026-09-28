
SuperStrict

Import BRL.PixelFormat

Global BytesPerPixel:Int[]=			[0,1,1,3,3,4,4, 1,1,1,1,1,1,4,4,2,2,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2]

Global RedBitsPerPixel:Int[]=		[1,0,0,8,8,8,8, 8,0,0,0,0,0,8,8,5,5,5,5,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,8,8,0,0] ' Max2d compressed textures version
Global GreenBitsPerPixel:Int[]=		[0,0,0,8,8,8,8, 0,8,0,0,0,0,8,8,6,6,6,6,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,0,8,0,0] ' stores dds format
Global BlueBitsPerPixel:Int[]=		[0,0,0,8,8,8,8, 0,0,8,0,0,0,8,8,5,5,5,5,2,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,0,0,0,0] ' stores texture name
Global AlphaBitsPerPixel:Int[]=		[0,0,8,0,0,8,8, 0,0,0,8,0,0,8,8,0,0,0,0,0,4,4,4,4,4,4,4,4,1,1,1,1,1,1,1,1,0,0,8,8]
Global IntensityBitsPerPixel:Int[]=	[0,0,0,0,0,0,0, 0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8]
Global LuminanceBitsPerPixel:Int[]=	[0,0,0,0,0,0,0, 0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

Global BitsPerPixel:Int[]=			[0,8,8,24,24,32,32, 4,4,4,4,4,4,32,32,16,16,16,16,8,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,8,16,16,16]
Global ColorBitsPerPixel:Int[]=		[0,0,0,24,24,24,24, 8,8,8,0,0,0,24,24,16,16,16,16,8,12,12,12,12,12,12,12,12,15,15,15,15,15,15,15,15,8,16,0,0]

Function CopyPixels( in_buf:Byte Ptr,out_buf:Byte Ptr,format:Int,count:Int )
	If format<0 Or format>PF_AI88 Then Throw "Pixmap: unsupported conversion format"
	MemCopy out_buf,in_buf, Size_T(count*BytesPerPixel[format])
End Function

Function ConvertPixels( in_buf:Byte Ptr,in_format:Int,out_buf:Byte Ptr,out_format:Int,count:Int )
	If in_format<0 Or in_format>PF_AI88 Or out_format<0 Or out_format>PF_AI88 Then Throw "Pixmap: unsupported conversion format"
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
	If format<0 Or format>PF_AI88 Then Throw "Pixmap: unsupported conversion format"
	Local in:Byte Ptr=in_buf
	Local out:Byte Ptr=out_buf
	Local out_end:Byte Ptr=out+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_R8
		While out<>out_end
			out[0]=in[0]
			out[1]=0
			out[2]=0
			out[3]=255
			in:+1
			out:+4
		Wend
	Case PF_RG88
		While out<>out_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=0
			out[3]=255
			in:+2
			out:+4
		Wend
	Case PF_IA88
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=in[1]
			in:+2
			out:+4
		Wend
	Case PF_AI88
		While out<>out_end
			out[0]=in[1]
			out[1]=in[1]
			out[2]=in[1]
			out[3]=in[0]
			in:+2
			out:+4
		Wend
	Case PF_RGB332,PF_RGBA4444_LE,PF_RGBA4444_BE,PF_BGRA4444_LE,PF_BGRA4444_BE,PF_ARGB4444_LE,PF_ARGB4444_BE,PF_ABGR4444_LE,PF_ABGR4444_BE,PF_RGBA5551_LE,PF_RGBA5551_BE,PF_BGRA5551_LE,PF_BGRA5551_BE,PF_ARGB1555_LE,PF_ARGB1555_BE,PF_ABGR1555_LE,PF_ABGR1555_BE
		Local stride:Int=BytesPerPixel[format]
		While out<>out_end
			Local argb:Int=_ReadPackedColour(in,format)
			out[0]=argb Shr 16
			out[1]=argb Shr 8
			out[2]=argb
			out[3]=argb Shr 24
			in:+stride
			out:+4
		Wend
	Case PF_RGB565_LE,PF_RGB565_BE,PF_BGR565_LE,PF_BGR565_BE
		While out<>out_end
			Local argb:Int=_ReadPacked565(in,format)
			out[0]=argb Shr 16
			out[1]=argb Shr 8
			out[2]=argb
			out[3]=255
			in:+2
			out:+4
		Wend
	Case PF_A8
		While out<>out_end
			out[0]=255
			out[1]=255
			out[2]=255
			out[3]=in[0]
			in:+1
			out:+4
		Wend
	Case PF_I8
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=255
			in:+1
			out:+4
		Wend
	Case PF_RGB888
		While out<>out_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			out[3]=255
			in:+3
			out:+4
		Wend
	Case PF_BGR888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=255
			in:+3
			out:+4
		Wend
	Case PF_BGRA8888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4
			out:+4
		Wend
	Case PF_ARGB8888
		While out<>out_end
			out[0]=in[1]
			out[1]=in[2]
			out[2]=in[3]
			out[3]=in[0]
			in:+4
			out:+4
		Wend
	Case PF_ABGR8888
		While out<>out_end
			out[0]=in[3]
			out[1]=in[2]
			out[2]=in[1]
			out[3]=in[0]
			in:+4
			out:+4
		Wend
	Case PF_RED
		While out<>out_end
			out[0]=in[0]
			out[1]=0
			out[2]=0
			out[3]=1
			in:+1
			out:+4
		Wend
	Case PF_GREEN
		While out<>out_end
			out[0]=0
			out[1]=in[0]
			out[2]=0
			out[3]=1
			in:+1
			out:+4
		Wend
	Case PF_BLUE
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=in[0]
			out[3]=1
			in:+1
			out:+4
		Wend
	Case PF_ALPHA
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=0
			out[3]=in[0]
			in:+1
			out:+4
		Wend
	Case PF_INTENSITY
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=in[0]
			in:+1
			out:+4
		Wend
	Case PF_LUMINANCE
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=1
			in:+1
			out:+4
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function

Function ConvertPixelsFromStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format:Int,count:Int )
	If format<0 Or format>PF_AI88 Then Throw "Pixmap: unsupported conversion format"
	Local out:Byte Ptr=out_buf
	Local in:Byte Ptr=in_buf
	Local in_end:Byte Ptr=in+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_R8
		While in<>in_end
			out[0]=in[0]
			out:+1
			in:+4
		Wend
	Case PF_RG88
		While in<>in_end
			out[0]=in[0]
			out[1]=in[1]
			out:+2
			in:+4
		Wend
	Case PF_IA88
		While in<>in_end
			out[0]=(Int(in[0])+in[1]+in[2])/3
			out[1]=in[3]
			out:+2
			in:+4
		Wend
	Case PF_AI88
		While in<>in_end
			out[0]=in[3]
			out[1]=(Int(in[0])+in[1]+in[2])/3
			out:+2
			in:+4
		Wend
	Case PF_RGB332,PF_RGBA4444_LE,PF_RGBA4444_BE,PF_BGRA4444_LE,PF_BGRA4444_BE,PF_ARGB4444_LE,PF_ARGB4444_BE,PF_ABGR4444_LE,PF_ABGR4444_BE,PF_RGBA5551_LE,PF_RGBA5551_BE,PF_BGRA5551_LE,PF_BGRA5551_BE,PF_ARGB1555_LE,PF_ARGB1555_BE,PF_ABGR1555_LE,PF_ABGR1555_BE
		Local stride:Int=BytesPerPixel[format]
		While in<>in_end
			_WritePackedColour(out,format,(Int(in[3]) Shl 24)|(Int(in[0]) Shl 16)|(Int(in[1]) Shl 8)|in[2])
			in:+4
			out:+stride
		Wend
	Case PF_RGB565_LE,PF_RGB565_BE,PF_BGR565_LE,PF_BGR565_BE
		While in<>in_end
			_WritePacked565(out,format,(Int(in[0]) Shl 16)|(Int(in[1]) Shl 8)|in[2])
			in:+4
			out:+2
		Wend
	Case PF_A8
		While in<>in_end
			out[0]=in[3]
			in:+4
			out:+1
		Wend
	Case PF_I8
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4
			out:+1
		Wend
	Case PF_RGB888
		While in<>in_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			in:+4
			out:+3
		Wend
	Case PF_BGR888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			in:+4
			out:+3
		Wend
	Case PF_BGRA8888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4
			out:+4
		Wend
	Case PF_ARGB8888 ' RGBA -> ARGB
		While in<>in_end
			out[0]=in[3]
			out[1]=in[0]
			out[2]=in[1]
			out[3]=in[2]
			in:+4
			out:+4
		Wend
	Case PF_ABGR8888 ' RGBA -> ABGR
		While in<>in_end
			out[0]=in[3]
			out[1]=in[2]
			out[2]=in[1]
			out[3]=in[0]
			in:+4
			out:+4
		Wend
	Case PF_RED
		While in<>in_end
			out[0]=in[0]
			in:+4
			out:+1
		Wend
	Case PF_GREEN
		While in<>in_end
			out[0]=in[1]
			in:+4
			out:+1
		Wend
	Case PF_BLUE
		While in<>in_end
			out[0]=in[2]
			in:+4
			out:+1
		Wend
	Case PF_ALPHA
		While in<>in_end
			out[0]=in[3]
			in:+4
			out:+1
		Wend
	Case PF_INTENSITY
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2]+in[3])/4
			in:+4
			out:+1
		Wend
	Case PF_LUMINANCE
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4
			out:+1
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function

' Internal helpers shared by pixel conversion and TPixmap.
Function _ReadPacked565:Int(p:Byte Ptr,format:Int)
	Local value:Int
	If format=PF_RGB565_BE Or format=PF_BGR565_BE Then
		value=Int(p[0]) Shl 8 | p[1]
	Else
		value=Int(p[1]) Shl 8 | p[0]
	End If
	Local r:Int=value Shr 11,g:Int=(value Shr 5)&63,b:Int=value&31
	If format=PF_BGR565_LE Or format=PF_BGR565_BE Then
		Local swap:Int=r
		r=b
		b=swap
	End If
	r=(r Shl 3)|(r Shr 2)
	g=(g Shl 2)|(g Shr 4)
	b=(b Shl 3)|(b Shr 2)
	Return $ff000000 | (r Shl 16) | (g Shl 8) | b
End Function

Function _WritePacked565(p:Byte Ptr,format:Int,argb:Int)
	Local r:Int=(argb Shr 19)&31,g:Int=(argb Shr 10)&63,b:Int=(argb Shr 3)&31
	If format=PF_BGR565_LE Or format=PF_BGR565_BE Then
		Local swap:Int=r
		r=b
		b=swap
	End If
	Local value:Int=(r Shl 11)|(g Shl 5)|b
	If format=PF_RGB565_BE Or format=PF_BGR565_BE Then
		p[0]=value Shr 8
		p[1]=value
	Else
		p[0]=value
		p[1]=value Shr 8
	End If
End Function
Public

' Internal packed-colour access; byte loads also support unaligned buffers.
Function _ReadPackedColour:Int(p:Byte Ptr,format:Int)
	Local value:Int
	Local r:Int,g:Int,b:Int,a:Int=255
	Select format
	Case PF_RGB332
		value=p[0]
		r=(value Shr 5)&7
		r=(r Shl 5)|(r Shl 2)|(r Shr 1)
		g=(value Shr 2)&7
		g=(g Shl 5)|(g Shl 2)|(g Shr 1)
		b=(value Shr 0)&3
		b=b*85
	Case PF_RGBA4444_LE
		value=Int(p[1]) Shl 8 | p[0]
		r=(value Shr 12)&15
		r=r*17
		g=(value Shr 8)&15
		g=g*17
		b=(value Shr 4)&15
		b=b*17
		a=(value Shr 0)&15
		a=a*17
	Case PF_RGBA4444_BE
		value=Int(p[0]) Shl 8 | p[1]
		r=(value Shr 12)&15
		r=r*17
		g=(value Shr 8)&15
		g=g*17
		b=(value Shr 4)&15
		b=b*17
		a=(value Shr 0)&15
		a=a*17
	Case PF_BGRA4444_LE
		value=Int(p[1]) Shl 8 | p[0]
		b=(value Shr 12)&15
		b=b*17
		g=(value Shr 8)&15
		g=g*17
		r=(value Shr 4)&15
		r=r*17
		a=(value Shr 0)&15
		a=a*17
	Case PF_BGRA4444_BE
		value=Int(p[0]) Shl 8 | p[1]
		b=(value Shr 12)&15
		b=b*17
		g=(value Shr 8)&15
		g=g*17
		r=(value Shr 4)&15
		r=r*17
		a=(value Shr 0)&15
		a=a*17
	Case PF_ARGB4444_LE
		value=Int(p[1]) Shl 8 | p[0]
		a=(value Shr 12)&15
		a=a*17
		r=(value Shr 8)&15
		r=r*17
		g=(value Shr 4)&15
		g=g*17
		b=(value Shr 0)&15
		b=b*17
	Case PF_ARGB4444_BE
		value=Int(p[0]) Shl 8 | p[1]
		a=(value Shr 12)&15
		a=a*17
		r=(value Shr 8)&15
		r=r*17
		g=(value Shr 4)&15
		g=g*17
		b=(value Shr 0)&15
		b=b*17
	Case PF_ABGR4444_LE
		value=Int(p[1]) Shl 8 | p[0]
		a=(value Shr 12)&15
		a=a*17
		b=(value Shr 8)&15
		b=b*17
		g=(value Shr 4)&15
		g=g*17
		r=(value Shr 0)&15
		r=r*17
	Case PF_ABGR4444_BE
		value=Int(p[0]) Shl 8 | p[1]
		a=(value Shr 12)&15
		a=a*17
		b=(value Shr 8)&15
		b=b*17
		g=(value Shr 4)&15
		g=g*17
		r=(value Shr 0)&15
		r=r*17
	Case PF_RGBA5551_LE
		value=Int(p[1]) Shl 8 | p[0]
		r=(value Shr 11)&31
		r=(r Shl 3)|(r Shr 2)
		g=(value Shr 6)&31
		g=(g Shl 3)|(g Shr 2)
		b=(value Shr 1)&31
		b=(b Shl 3)|(b Shr 2)
		a=(value Shr 0)&1
		a=a*255
	Case PF_RGBA5551_BE
		value=Int(p[0]) Shl 8 | p[1]
		r=(value Shr 11)&31
		r=(r Shl 3)|(r Shr 2)
		g=(value Shr 6)&31
		g=(g Shl 3)|(g Shr 2)
		b=(value Shr 1)&31
		b=(b Shl 3)|(b Shr 2)
		a=(value Shr 0)&1
		a=a*255
	Case PF_BGRA5551_LE
		value=Int(p[1]) Shl 8 | p[0]
		b=(value Shr 11)&31
		b=(b Shl 3)|(b Shr 2)
		g=(value Shr 6)&31
		g=(g Shl 3)|(g Shr 2)
		r=(value Shr 1)&31
		r=(r Shl 3)|(r Shr 2)
		a=(value Shr 0)&1
		a=a*255
	Case PF_BGRA5551_BE
		value=Int(p[0]) Shl 8 | p[1]
		b=(value Shr 11)&31
		b=(b Shl 3)|(b Shr 2)
		g=(value Shr 6)&31
		g=(g Shl 3)|(g Shr 2)
		r=(value Shr 1)&31
		r=(r Shl 3)|(r Shr 2)
		a=(value Shr 0)&1
		a=a*255
	Case PF_ARGB1555_LE
		value=Int(p[1]) Shl 8 | p[0]
		a=(value Shr 15)&1
		a=a*255
		r=(value Shr 10)&31
		r=(r Shl 3)|(r Shr 2)
		g=(value Shr 5)&31
		g=(g Shl 3)|(g Shr 2)
		b=(value Shr 0)&31
		b=(b Shl 3)|(b Shr 2)
	Case PF_ARGB1555_BE
		value=Int(p[0]) Shl 8 | p[1]
		a=(value Shr 15)&1
		a=a*255
		r=(value Shr 10)&31
		r=(r Shl 3)|(r Shr 2)
		g=(value Shr 5)&31
		g=(g Shl 3)|(g Shr 2)
		b=(value Shr 0)&31
		b=(b Shl 3)|(b Shr 2)
	Case PF_ABGR1555_LE
		value=Int(p[1]) Shl 8 | p[0]
		a=(value Shr 15)&1
		a=a*255
		b=(value Shr 10)&31
		b=(b Shl 3)|(b Shr 2)
		g=(value Shr 5)&31
		g=(g Shl 3)|(g Shr 2)
		r=(value Shr 0)&31
		r=(r Shl 3)|(r Shr 2)
	Case PF_ABGR1555_BE
		value=Int(p[0]) Shl 8 | p[1]
		a=(value Shr 15)&1
		a=a*255
		b=(value Shr 10)&31
		b=(b Shl 3)|(b Shr 2)
		g=(value Shr 5)&31
		g=(g Shl 3)|(g Shr 2)
		r=(value Shr 0)&31
		r=(r Shl 3)|(r Shr 2)
	End Select
	Return (a Shl 24)|(r Shl 16)|(g Shl 8)|b
End Function

Function _WritePackedColour(p:Byte Ptr,format:Int,argb:Int)
	Local value:Int
	Select format
	Case PF_RGB332
		value=(((argb Shr 21)&7) Shl 5) | (((argb Shr 13)&7) Shl 2) | (((argb Shr 6)&3) Shl 0)
		p[0]=value
	Case PF_RGBA4444_LE
		value=(((argb Shr 20)&15) Shl 12) | (((argb Shr 12)&15) Shl 8) | (((argb Shr 4)&15) Shl 4) | (((argb Shr 28)&15) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_RGBA4444_BE
		value=(((argb Shr 20)&15) Shl 12) | (((argb Shr 12)&15) Shl 8) | (((argb Shr 4)&15) Shl 4) | (((argb Shr 28)&15) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_BGRA4444_LE
		value=(((argb Shr 4)&15) Shl 12) | (((argb Shr 12)&15) Shl 8) | (((argb Shr 20)&15) Shl 4) | (((argb Shr 28)&15) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_BGRA4444_BE
		value=(((argb Shr 4)&15) Shl 12) | (((argb Shr 12)&15) Shl 8) | (((argb Shr 20)&15) Shl 4) | (((argb Shr 28)&15) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_ARGB4444_LE
		value=(((argb Shr 28)&15) Shl 12) | (((argb Shr 20)&15) Shl 8) | (((argb Shr 12)&15) Shl 4) | (((argb Shr 4)&15) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_ARGB4444_BE
		value=(((argb Shr 28)&15) Shl 12) | (((argb Shr 20)&15) Shl 8) | (((argb Shr 12)&15) Shl 4) | (((argb Shr 4)&15) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_ABGR4444_LE
		value=(((argb Shr 28)&15) Shl 12) | (((argb Shr 4)&15) Shl 8) | (((argb Shr 12)&15) Shl 4) | (((argb Shr 20)&15) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_ABGR4444_BE
		value=(((argb Shr 28)&15) Shl 12) | (((argb Shr 4)&15) Shl 8) | (((argb Shr 12)&15) Shl 4) | (((argb Shr 20)&15) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_RGBA5551_LE
		value=(((argb Shr 19)&31) Shl 11) | (((argb Shr 11)&31) Shl 6) | (((argb Shr 3)&31) Shl 1) | (((argb Shr 31)&1) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_RGBA5551_BE
		value=(((argb Shr 19)&31) Shl 11) | (((argb Shr 11)&31) Shl 6) | (((argb Shr 3)&31) Shl 1) | (((argb Shr 31)&1) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_BGRA5551_LE
		value=(((argb Shr 3)&31) Shl 11) | (((argb Shr 11)&31) Shl 6) | (((argb Shr 19)&31) Shl 1) | (((argb Shr 31)&1) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_BGRA5551_BE
		value=(((argb Shr 3)&31) Shl 11) | (((argb Shr 11)&31) Shl 6) | (((argb Shr 19)&31) Shl 1) | (((argb Shr 31)&1) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_ARGB1555_LE
		value=(((argb Shr 31)&1) Shl 15) | (((argb Shr 19)&31) Shl 10) | (((argb Shr 11)&31) Shl 5) | (((argb Shr 3)&31) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_ARGB1555_BE
		value=(((argb Shr 31)&1) Shl 15) | (((argb Shr 19)&31) Shl 10) | (((argb Shr 11)&31) Shl 5) | (((argb Shr 3)&31) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	Case PF_ABGR1555_LE
		value=(((argb Shr 31)&1) Shl 15) | (((argb Shr 3)&31) Shl 10) | (((argb Shr 11)&31) Shl 5) | (((argb Shr 19)&31) Shl 0)
		p[0]=value
		p[1]=value Shr 8
	Case PF_ABGR1555_BE
		value=(((argb Shr 31)&1) Shl 15) | (((argb Shr 3)&31) Shl 10) | (((argb Shr 11)&31) Shl 5) | (((argb Shr 19)&31) Shl 0)
		p[0]=value Shr 8
		p[1]=value
	End Select
End Function
