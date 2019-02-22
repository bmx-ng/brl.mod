SuperStrict

Framework brl.xml
Import brl.standardio

Local docname:String = "sample.xml"
Local doc:TxmlDoc

doc = TxmlDoc.parseFile(docname)
If doc Then

	Local root:TxmlNode = doc.getRootElement()
	
	Local node:TxmlNode = root.findElement("author")
	
	If node Then
		Print node.ToString()
	End If

End If
