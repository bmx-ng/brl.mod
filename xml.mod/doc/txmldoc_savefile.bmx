SuperStrict

Framework brl.xml
Import BRL.StandardIO

' Create a new document
Local doc:TxmlDoc = TxmlDoc.newDoc("1.0")

If doc Then

	' create a test stream
	Local stream:TTestStream = TTestStream.Create()

	' create a new node, initially not attached to the document
	Local root:TxmlNode = TxmlNode.newNode("root")
	
	' set the node as the document root node
	doc.setRootElement(root)
 
	root.addChild("things", "some stuff")

	' output the document to a file
	doc.saveFile("testfile.xml")
	
	' output the document to a stream
	doc.saveFile(stream)
	
	' output the document to console
	doc.saveFile("-")
	
	doc.Free()
End If


Type TTestStream Extends TStream

	Function Create:TTestStream( )
		Return New TTestStream
	End Function

	Method Write:Long( buf:Byte Ptr, count:Long )
		
		Print "outputing..."
		Print String.FromBytes( buf, Int(count) )
		
		Return count
	End Method

	
End Type
