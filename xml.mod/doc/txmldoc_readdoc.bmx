SuperStrict

Framework brl.xml
Import brl.standardio

Local xml:String = LoadText("sample.xml")

Local doc:TxmlDoc = TxmlDoc.readDoc(xml)

If doc Then
	doc.savefile("-")
	doc.Free()
End If
