SuperStrict

Framework brl.xml
Import brl.standardio

Local docname:String = "sample.xml"
Local doc:TxmlDoc

doc = TxmlDoc.parseFile(docname)
If doc Then
	Local root:TxmlNode = doc.getRootElement()
	
	Local node:TxmlNode = TxmlNode(root.getLastChild())
	
	Print "Previous sibling is - " + node.previousSibling().getName()

End If
