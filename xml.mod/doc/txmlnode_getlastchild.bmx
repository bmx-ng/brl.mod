SuperStrict

Framework brl.xml
Import brl.standardio

Local docname:String = "sample.xml"
Local doc:TxmlDoc

doc = TxmlDoc.parseFile(docname)
If doc Then
	Local root:TxmlNode = doc.getRootElement()
	
	Print "Last child is - " + root.getLastChild().getName()

End If
