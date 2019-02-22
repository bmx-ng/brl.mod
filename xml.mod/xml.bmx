' Copyright 2019 Bruce A Henderson
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'     http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
'
SuperStrict

Rem
bbdoc: XML
End Rem
Module BRL.XML

ModuleInfo "Version: 1.00"
ModuleInfo "License: Apache 2.0"
ModuleInfo "Copyright: 2019 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import "common.bmx"

' disable wrapping
bmx_mxmlSetWrapMargin(0)

Rem
bbdoc: 
End Rem
Type TxmlBase Abstract

	Field nodePtr:Byte Ptr

	Rem
	bbdoc: Returns the element name.
	End Rem
	Method getName:String()
		Return bmx_mxmlGetElement(nodePtr)
	End Method
	
	Rem
	bbdoc: Returns a string representation of the element.
	End Rem
	Method ToString:String()
		Return bmx_mxmlSaveString(nodePtr, False)
	End Method

	Rem
	bbdoc: Returns a string representation of the element, optionally formatting the output.
	End Rem
	Method ToStringFormat:String(format:Int = False)
		Return bmx_mxmlSaveString(nodePtr, format)
	End Method

End Type

Rem
bbdoc: An XML Node.
End Rem
Type TxmlNode Extends TxmlBase

	Function _create:TxmlNode(nodePtr:Byte Ptr)
		If nodePtr Then
			Local this:TxmlNode = New TxmlNode
			this.nodePtr = nodePtr
			Return this
		End If
	End Function

	Rem
	bbdoc: Creates a new node element.
	End Rem
	Function newNode:TxmlNode(name:String)
		Return _create(bmx_mxmlNewElement(Null, name))
	End Function

	Rem
	bbdoc: Gets the parent.
	returns: The parent to this object.
	End Rem
	Method GetParent:TxmlNode()
		Return TxmlNode._create(bmx_mxmlGetParent(nodePtr))
	End Method

	Rem
	bbdoc: Creates a new child element.
	about: Added at the end of child nodes list.
	End Rem
	Method addChild:TxmlNode(name:String, content:String = Null)
		Local n:TxmlNode = _create(bmx_mxmlNewElement(nodePtr, name))
		If content And n Then
			n.setContent(content)
		End If
		Return n
	End Method

	Rem
	Rem
	bbdoc: Adds a new node @node as the next sibling.
	End Rem
	Method addNextSibling(node:TxmlNode)
		Local parent:TxmlBase = GetParent()
		If parent Then
			bmx_mxmlAdd(parent.nodePtr, MXML_ADD_AFTER, nodePtr, node.nodePtr)
		End If
	End Method

	Rem
	bbdoc: Adds a new node @node as the previous sibling.
	End Rem
	Method addPreviousSibling(node:TxmlNode)
		Local parent:TxmlBase = GetParent()
		If parent Then
			bmx_mxmlAdd(parent.nodePtr, MXML_ADD_BEFORE, nodePtr, node.nodePtr)
		End If
	End Method

	Rem
	bbdoc: Appends the extra substring to the node content.
	End Rem
	Method addContent(content:String)
		bmx_mxmlAddContent(nodePtr, content)
	End Method
	
	Rem
	bbdoc: Replaces the content of a node.
	End Rem
	Method setContent(content:String)
		bmx_mxmlSetContent(nodePtr, content)
	End Method
	
	Rem
	bbdoc: Sets (or resets) the name of the node.
	End Rem
	Method setName(name:String)
		bmx_mxmlSetElement(nodePtr, name)
	End Method
	
	Rem
	bbdoc: Creates a new attribute.
	End Rem
	Method addAttribute(name:String, value:String = "")
		setAttribute(name, value)
	End Method
	
	Rem
	bbdoc: Sets (or resets) an attribute carried by the node.
	End Rem
	Method setAttribute(name:String, value:String = "")
		bmx_mxmlElementSetAttr(nodePtr, name, value)
	End Method
	
	Rem
	bbdoc: Provides the value of the attribute with the specified qualified name.
	End Rem
	Method getAttribute:String(name:String)
		Return bmx_mxmlElementGetAttr(nodePtr, name)
	End Method
	
	Rem
	bbdoc: Returns the list of node attributes.
	returns: The list of attributes.
	End Rem
	Method getAttributeList:TList()
		Local list:TList = New TList
		Local count:Int = bmx_mxmlElementGetAttrCount(nodePtr)
		If count Then
			For Local i:Int = 0 Until count
				Local name:String
				Local value:String = bmx_mxmlElementGetAttrByIndex(nodePtr, i, name)
				list.AddLast(New TxmlAttribute(name, value))
			Next
		End If
		Return list
	End Method
	
	Rem
	bbdoc: Remove an attribute carried by the node.
	End Rem
	Method unsetAttribute(name:String)
		bmx_mxmlElementDeleteAttr(nodePtr, name)
	End Method
	
	Rem
	bbdoc: Search an attribute associated to the node
	returns: the attribute or Null if not found.
	End Rem
	Method hasAttribute:Int(name:String)
		Return bmx_mxmlElementHasAttr(nodePtr, name)
	End Method
	
	Rem
	bbdoc: Returns a list of child nodes.
	End Rem
	Method getChildren:TList()
		Local list:TList = New TList
		
		Local n:Byte Ptr = bmx_mxmlWalkNext(nodePtr, nodePtr, MXML_DESCEND)
		
		While n
			If bmx_mxmlGetType(n) = MXML_ELEMENT Then
				list.AddLast(TxmlNode._create(n))
			End If
			n = bmx_mxmlWalkNext(n, nodePtr, MXML_NO_DESCEND)
		Wend
		
		Return list
	End Method

	Rem
	bbdoc: Gets the first child.
	returns: The first child or Null if none.
	End Rem
	Method getFirstChild:TxmlBase()
		Return TxmlNode._create(bmx_mxmlGetFirstChild(nodePtr))
	End Method

	Rem
	bbdoc: Gets the last child.
	returns: The last child or Null if none.
	End Rem
	Method getLastChild:TxmlBase()
		Return TxmlNode._create(bmx_mxmlGetLastChild(nodePtr))
	End Method

	Rem
	bbdoc: Get the next sibling node
	returns: The next node or Null if there are none.
	End Rem
	Method nextSibling:TxmlNode()
		Return TxmlNode._create(bmx_mxmlGetNextSibling(nodePtr))
	End Method
	
	Rem
	bbdoc: Get the previous sibling node
	returns: The previous node or Null if there are none.
	End Rem
	Method previousSibling:TxmlNode()
		Return TxmlNode._create(bmx_mxmlGetPrevSibling(nodePtr))
	End Method
	
	Rem
	bbdoc: Reads the value of a node.
	returns: The node content.
	End Rem
	Method getContent:String()
		Local sb:TStringBuilder = New TStringBuilder()
		
		Local n:Byte Ptr = bmx_mxmlWalkNext(nodePtr, nodePtr, MXML_DESCEND)
		While n
			If bmx_mxmlGetType(n) = MXML_OPAQUE Then
				sb.Append(bmx_mxmlGetContent(n))
			End If
			n = bmx_mxmlWalkNext(n, nodePtr, MXML_DESCEND)
		Wend
		
		Return sb.ToString()
	End Method
	
	Rem
	bbdoc: Finds an element of the given @element name, attribute or attribute/value.
	returns: A node or Null if no match was found.
	End Rem
	Method findElement:TxmlNode(element:String = "", attr:String = "", value:String = "")
		Return TxmlNode._create(bmx_mxmlFindElement(nodePtr, element, attr, value))
	End Method

	Rem
	bbdoc: Frees a node and all of its children.
	End Rem
	Method Free()
		If nodePtr Then
			bmx_mxmlDelete(nodePtr)
			nodePtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: An XML Document.
End Rem
Type TxmlDoc Extends TxmlBase

	Function _create:TxmlDoc(nodePtr:Byte Ptr)
		If nodePtr Then
			Local this:TxmlDoc = New TxmlDoc
			this.nodePtr = nodePtr
			Return this
		End If
	End Function

	Rem
	bbdoc: Creates a new XML document.
	End Rem
	Function newDoc:TxmlDoc(version:String)
		Local this:TxmlDoc = New TxmlDoc
		this.nodePtr = bmx_mxmlNewXML(version)
		If this.nodePtr Then
			Return this
		End If
	End Function

	Rem
	bbdoc: Parses an XML document from a String or TStream and builds a tree.
	returns: The resulting document tree.
	End Rem
	Function readDoc:TxmlDoc(doc:Object)
		If String(doc) Then
			Local txt:String = String(doc)
	
			' strip utf8 BOM		
			If txt[..3] = BOM_UTF8 Then
				txt = txt[3..]
			End If
			
			Return TxmlDoc._create(bmx_mxmlLoadString(txt))
		
		Else If TStream(doc) Then
			Return parseFile(doc)
		End If
	End Function
	
	Rem
	bbdoc: Sets the root element of the document.
	returns: The old root element if any was found.
	End Rem
	Method setRootElement:TxmlNode(root:TxmlNode)
		Return TxmlNode._create(bmx_mxmlSetRootElement(nodePtr, root.nodePtr))
	End Method
	
	Rem
	bbdoc: Returns the root element of the document.
	End Rem
	Method getRootElement:TxmlNode()
		Return TxmlNode._create(bmx_mxmlGetRootElement(nodePtr))
	End Method
	
	Rem
	bbdoc: Dumps an XML document to a file.
	returns: True on success, or Fales otherwise.
	End Rem
	Method saveFile:Int(file:Object, autoClose:Int = True, format:Int = False)

		Local filename:String = String(file)
		Local created:Int
		
		If filename Then
			If filename = "-" Then
				Return bmx_mxmlSaveStdout(nodePtr, format)
			Else
				file = WriteStream(filename)
				created = True
			End If		
		End If
		
		If TStream(file) Then
			Try
				Return bmx_mxmlSaveStream(nodePtr, TStream(file), format) = 0
			Finally
				If created Or autoClose Then
					TStream(file).Close()
				End If
			End Try
		End If
		
		Return False
	End Method

	Rem
	bbdoc: Parses an XML file and build a tree.
	returns: The resulting document tree or Null if error.
	End Rem
	Function parseFile:TxmlDoc(file:Object)
		
		Local filename:String = String(file)
		Local opened:Int
		
		If filename Then
			file = ReadStream(filename)
			opened = True
		End If
		
		If TStream(file) Then
			Local doc:TxmlDoc
			Try
				doc = _create(bmx_mxmlLoadStream(TStream(file)))
			Finally
				If opened Then
					TStream(file).close()
				End If
			End Try
			Return doc
		End If
		
		Return Null
	End Function

	Rem
	bbdoc: Frees the document.
	End Rem
	Method Free()
		If nodePtr Then
			bmx_mxmlDelete(nodePtr)
			nodePtr = Null
		End If
	End Method
	
End Type

Private
Function _xmlstream_read:Int(stream:TStream, buf:Byte Ptr, count:UInt) { nomangle }
	Return stream.Read(buf, count)
End Function
Function _xmlstream_write:Int(stream:TStream, buf:Byte Ptr, count:UInt) { nomangle }
	Return stream.Write(buf, count)
End Function
Public

Rem
bbdoc: An xml element attribute name/value pair. (read only)
End Rem
Type TxmlAttribute
	Private
	Field name:String
	Field value:String
	Public
	Method New(name:String, value:String)
		Self.name = name
		Self.value = value
	End Method
	
	Method getName:String()
		Return name
	End Method
	
	Method getValue:String()
		Return value
	End Method
End Type
