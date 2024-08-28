SuperStrict

Framework BRL.standardio
Import BRL.RectPacker

Local packer:TRectPacker = New TRectPacker

packer.Add(32, 32, 0)
packer.Add(64, 64, 1)
packer.Add(128, 128, 2)
packer.Add(256, 256, 3)
packer.Add(512, 512, 4)
packer.Add(1024, 1024, 5)

Local sheets:TPackedSheet[] = packer.Pack()

For Local i:Int = 0 Until sheets.Length
	Local sheet:TPackedSheet = sheets[i]
	Print "Sheet: " + i + " : " + sheet.width + " " + sheet.height
	For Local j:Int = 0 Until sheet.rects.Length
		Local rect:SPackedRect = sheet.rects[j]
		Print "  Rect: " + j + " " + rect.x + " " + rect.y + " " + rect.width + " " + rect.height
	Next
Next
