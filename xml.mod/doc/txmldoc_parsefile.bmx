SuperStrict

Framework brl.xml
Import brl.standardio
Import brl.ramstream

Incbin "sample.xml"

Local doc:TxmlDoc = TxmlDoc.parseFile("sample.xml")

If doc Then
	Print "~nFilename :"
	doc.savefile("-")
	doc.Free()
End If

Local stream:TStream = ReadStream("sample.xml")
doc = TxmlDoc.parseFile(stream)

If doc Then
	Print "~nStream :"
	doc.savefile("-")
	doc.Free()
End If

stream = ReadStream("incbin::sample.xml")
doc = TxmlDoc.parseFile(stream)

If doc Then
	Print "~nIncbin Stream :"
	doc.savefile("-")
	doc.Free()
End If
