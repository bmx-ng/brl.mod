SuperStrict

Framework brl.xml
Import brl.standardio

Local doc:TxmlDoc = TxmlDoc.parseFile("attributes.xml")

If doc Then

	Local node:TxmlNode = TxmlNode(doc.getRootElement().getFirstChild())

	Local desc:TxmlNode = node.addChild("description")

	desc.addContent("Some of the songs on this CD are awesome.~n")
	desc.addContent("Tracks 5 & 6 put this CD up there...")

	doc.savefile("-")

End If
