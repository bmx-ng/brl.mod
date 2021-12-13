
SuperStrict

Import "driver.bmx"

Rem
bbdoc: Max2D Image type
End Rem
Type TImage

	Field width:Int,height:Int,flags:Int
	Field mask_r:Int,mask_g:Int,mask_b:Int
	Field handle_x#,handle_y#
	Field pixmaps:TPixmap[]

	Field frames:TImageFrame[]
	Field seqs:Int[]
	
	Method _pad()
	End Method
	
	Method Frame:TImageFrame( index:Int )
		Assert index < seqs.length And index < frames.length Else "Index out of bounds"
		If seqs[index]=GraphicsSeq Return frames[index]
		frames[index]=_max2dDriver.CreateFrameFromPixmap( Lock(index,True,False),flags )
		If frames[index] seqs[index]=GraphicsSeq Else seqs[index]=0
		Return frames[index]
	End Method
	
	Method Lock:TPixmap( index:Int,read:Int,write:Int )
		Assert index < seqs.length And index < frames.length Else "Index out of bounds"
		If write
			seqs[index]=0
			frames[index]=Null
		EndIf
		If Not pixmaps[index]
			pixmaps[index]=CreatePixmap( width,height,PF_RGBA8888 )
		EndIf
		Return pixmaps[index]
	End Method
	
	Method SetPixmap( index:Int,pixmap:TPixmap )
		Assert index < seqs.length And index < frames.length And index < pixmaps.length Else "Index out of bounds"
		If (flags & MASKEDIMAGE) And AlphaBitsPerPixel[pixmap.format]=0
			pixmap=MaskPixmap( pixmap,mask_r,mask_g,mask_b )
		EndIf
		pixmap.dds_fmt=GreenBitsPerPixel[0] ' set dds format
		pixmap.tex_name=BlueBitsPerPixel[0] ' set texture name
		pixmaps[index]=pixmap
		seqs[index]=0
		frames[index]=Null
	End Method
	
	Function Create:TImage( width:Int,height:Int,frames:Int,flags:Int,mr:Int,mg:Int,mb:Int )
		Assert width > 0 And height > 0 Else "Image dimensions out of bounds"
		Local t:TImage=New TImage
		t.width=width
		t.height=height
		t.flags=flags
		t.mask_r=mr
		t.mask_g=mg
		t.mask_b=mb
		t.pixmaps=New TPixmap[frames]
		t.frames=New TImageFrame[frames]
		t.seqs=New Int[frames]
		Return t
	End Function
	
	Function Load:TImage( url:Object,flags:Int,mr:Int,mg:Int,mb:Int )
		Local pixmap:TPixmap=TPixmap(url)
		If Not pixmap pixmap=LoadPixmap(url)
		If Not pixmap Return null
		Local t:TImage=Create( pixmap.width,pixmap.height,1,flags,mr,mg,mb )
		t.SetPixmap 0,pixmap
		Return t
	End Function

	Function LoadAnim:TImage( url:Object,cell_width:Int,cell_height:Int,first:Int,count:Int,flags:Int,mr:Int,mg:Int,mb:Int )
		Assert cell_width > 0 And cell_height > 0 Else "Cell dimensions out of bounds"
		Local pixmap:TPixmap=TPixmap(url)
		If Not pixmap pixmap=LoadPixmap(url)
		If Not pixmap Return null

		Local x_cells:Int=pixmap.width/cell_width
		Local y_cells:Int=pixmap.height/cell_height
		If first+count>x_cells*y_cells Return null
		
		Local t:TImage=Create( cell_width,cell_height,count,flags,mr,mg,mb )

		For Local cell:Int=first To first+count-1
			Local x:Int=cell Mod x_cells * cell_width
			Local y:Int=cell / x_cells * cell_height
			Local window:TPixmap=pixmap.Window( x,y,cell_width,cell_height )
			t.SetPixmap cell-first,window.Copy()
		Next
		Return t
	End Function
	
End Type
