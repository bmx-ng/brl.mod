SuperStrict

Framework brl.xml
Import brl.standardio

Local docname:String = "attributes.xml"
Local doc:TxmlDoc = TxmlDoc.parseFile(docname)

If doc Then
	Local root:TxmlNode = doc.getRootElement()
	For Local node:TxmlNode = EachIn root.getChildren()
		Print node.getName() + " : "
		
		For Local attribute:TxmlAttribute = EachIn node.getAttributeList()
			Print "    " + attribute.getName() + " : " + attribute.getValue()
		Next
		
		Print ""
	Next
End If
