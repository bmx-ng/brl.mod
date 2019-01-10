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

Import Pub.mxml
Import brl.stream
Import brl.linkedlist

Import "glue.c"

Extern

	Function bmx_mxmlLoadStream:Byte Ptr(stream:TStream)
	Function bmx_mxmlNewXML:Byte Ptr(version:String)
	Function bmx_mxmlNewElement:Byte Ptr(parent:Byte Ptr, name:String)
	Function bmx_mxmlDelete(handle:Byte Ptr)
	Function bmx_mxmlLoadString:Byte Ptr(txt:String)

	Function bmx_mxmlSetRootElement:Byte Ptr(handle:Byte Ptr, root:Byte Ptr)
	Function bmx_mxmlAdd(parent:Byte Ptr, _where:Int, child:Byte Ptr, node:Byte Ptr)
	Function bmx_mxmlGetElement:String(handle:Byte Ptr)
	Function bmx_mxmlSetContent(handle:Byte Ptr, content:String)
	Function bmx_mxmlElementSetAttr(handle:Byte Ptr, name:String, value:String)
	Function bmx_mxmlElementGetAttr:String(handle:Byte Ptr, name:String)
	Function bmx_mxmlElementDeleteAttr(handle:Byte Ptr, name:String)
	Function bmx_mxmlElementHasAttr:Int(handle:Byte Ptr, name:String)
	Function bmx_mxmlSetElement(handle:Byte Ptr, name:String)
	Function bmx_mxmlElementGetAttrCount:Int(handle:Byte Ptr)
	Function bmx_mxmlElementGetAttrByIndex:String(handle:Byte Ptr, index:Int, name:String Var)
	Function bmx_mxmlGetRootElement:Byte Ptr(handle:Byte Ptr)
	Function bmx_mxmlWalkNext:Byte Ptr(node:Byte Ptr, top:Byte Ptr, descend:Int)
	Function bmx_mxmlGetType:Int(handle:Byte Ptr)
	Function bmx_mxmlAddContent(handle:Byte Ptr, content:String)
	Function bmx_mxmlGetParent:Byte Ptr(handle:Byte Ptr)
	Function bmx_mxmlGetFirstChild:Byte Ptr(handle:Byte Ptr)
	Function bmx_mxmlGetLastChild:Byte Ptr(handle:Byte Ptr)
	Function bmx_mxmlGetNextSibling:Byte Ptr(handle:Byte Ptr)
	Function bmx_mxmlGetPrevSibling:Byte Ptr(handle:Byte Ptr)
	
	Function bmx_mxmlSaveStdout:Int(handle:Byte Ptr)
	Function bmx_mxmlSaveString:String(handle:Byte Ptr)
	Function bmx_mxmlSaveStream:Int(handle:Byte Ptr, stream:TStream)
End Extern

Rem
bbdoc: Descend when finding/walking.
End Rem
Const MXML_DESCEND:Int = 1
Rem
bbdoc: Don't descend when finding/walking.
End Rem
Const MXML_NO_DESCEND:Int = 0
Rem
bbdoc: Descend for first find.
End Rem
Const MXML_DESCEND_FIRST:Int = -1

Const MXML_IGNORE:Int = -1
Const MXML_ELEMENT:Int = 0
Const MXML_INTEGER:Int = 1
Const MXML_OPAQUE:Int = 2
Const MXML_REAL:Int = 3
Const MXML_TEXT:Int = 4
Const MXML_CUSTOM:Int = 5

Const BOM_UTF8:String = Chr(239) + Chr(187) + Chr(191)
