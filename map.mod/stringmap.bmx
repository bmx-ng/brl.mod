Strict


Extern
	Function bmx_map_stringmap_clear(root:Byte Ptr Ptr)
	Function bmx_map_stringmap_isempty:Int(root:Byte Ptr Ptr)
	Function bmx_map_stringmap_insert(key:String, value:Object, root:Byte Ptr Ptr)
	Function bmx_map_stringmap_contains:Int(key:String, root:Byte Ptr Ptr)
	Function bmx_map_stringmap_valueforkey:Object(key:String, root:Byte Ptr Ptr)
	Function bmx_map_stringmap_remove:Int(key:String, root:Byte Ptr Ptr)
	Function bmx_map_stringmap_firstnode:Byte Ptr(root:Byte Ptr)
	Function bmx_map_stringmap_nextnode:Byte Ptr(node:Byte Ptr)
	Function bmx_map_stringmap_key:String(node:Byte Ptr)
	Function bmx_map_stringmap_value:Object(node:Byte Ptr)
	Function bmx_map_stringmap_hasnext:Int(node:Byte Ptr, root:Byte Ptr)
	Function bmx_map_stringmap_copy(dst:Byte Ptr Ptr, _root:Byte Ptr)
End Extern

Type TStringMap

	Method Delete()
		Clear
	End Method

	Method Clear()
?ngcmod
		If Not IsEmpty() Then
			_modCount :+ 1
		End If
?
		bmx_map_stringmap_clear(Varptr _root)
	End Method
	
	Method IsEmpty()
		Return bmx_map_stringmap_isempty(Varptr _root)
	End Method
	
	Method Insert( key:String,value:Object )
		bmx_map_stringmap_insert(key, value, Varptr _root)
?ngcmod
		_modCount :+ 1
?
	End Method

	Method Contains:Int( key:String )
		Return bmx_map_stringmap_contains(key, Varptr _root)
	End Method
	
	Method ValueForKey:Object( key:String )
		Return bmx_map_stringmap_valueforkey(key, Varptr _root)
	End Method
	
	Method Remove( key:String )
?ngcmod
		_modCount :+ 1
?
		Return bmx_map_stringmap_remove(key, Varptr _root)
	End Method

	Method _FirstNode:TStringNode()
		If Not IsEmpty() Then
			Local node:TStringNode= New TStringNode
			node._root = _root
			Return node
		Else
			Return Null
		End If
	End Method
	
	Method Keys:TStringMapEnumerator()
		Local nodeenum:TStringNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TStringKeyEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TStringEmptyEnumerator
		End If
		Local mapenum:TStringMapEnumerator=New TStringMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Values:TStringMapEnumerator()
		Local nodeenum:TStringNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TStringValueEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TStringEmptyEnumerator
		End If
		Local mapenum:TStringMapEnumerator=New TStringMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Copy:TStringMap()
		Local map:TStringMap=New TStringMap
		bmx_map_stringmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Method ObjectEnumerator:TStringNodeEnumerator()
		Local nodeenum:TStringNodeEnumerator=New TStringNodeEnumerator
		nodeenum._node=_FirstNode()
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return nodeenum
	End Method

	Field _root:Byte Ptr

?ngcmod
	Field _modCount:Int
?

End Type

Type TStringNode
	Field _root:Byte Ptr
	Field _nodePtr:Byte Ptr
	
	Method Key:String()
		Return bmx_map_stringmap_key(_nodePtr)
	End Method
	
	Method Value:Object()
		Return bmx_map_stringmap_value(_nodePtr)
	End Method

	Method HasNext()
		Return bmx_map_stringmap_hasnext(_nodePtr, _root)
	End Method
	
	Method NextNode:TStringNode()
		If Not _nodePtr Then
			_nodePtr = bmx_map_stringmap_firstnode(_root)
		Else
			_nodePtr = bmx_map_stringmap_nextnode(_nodePtr)
		End If

		Return Self
	End Method
	
End Type

Type TStringNodeEnumerator
	Method HasNext()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TStringMap Concurrent Modification"
?
		Local node:TStringNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TStringNode	

	Field _map:TStringMap
?ngcmod
	Field _expectedModCount:Int
?
End Type

Type TStringKeyEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TStringMap Concurrent Modification"
?
		Local node:TStringNode=_node
		_node=_node.NextNode()
		Return node.Key()
	End Method
End Type

Type TStringValueEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TStringMap Concurrent Modification"
?
		Local node:TStringNode=_node
		_node=_node.NextNode()
		Return node.Value()
	End Method
End Type

Type TStringMapEnumerator
	Method ObjectEnumerator:TStringNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TStringNodeEnumerator
End Type

Type TStringEmptyEnumerator Extends TStringNodeEnumerator
	Method HasNext()
		_map = Null
		Return False
	End Method
End Type

