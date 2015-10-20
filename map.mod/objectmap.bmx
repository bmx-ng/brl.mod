Strict


Extern
	Function bmx_map_objectmap_clear(root:Byte Ptr Ptr)
	Function bmx_map_objectmap_isempty:Int(root:Byte Ptr Ptr)
	Function bmx_map_objectmap_insert(key:Object, value:Object, root:Byte Ptr Ptr)
	Function bmx_map_objectmap_contains:Int(key:Object, root:Byte Ptr Ptr)
	Function bmx_map_objectmap_valueforkey:Object(key:Object, root:Byte Ptr Ptr)
	Function bmx_map_objectmap_remove:Int(key:Object, root:Byte Ptr Ptr)
	Function bmx_map_objectmap_firstnode:Byte Ptr(root:Byte Ptr)
	Function bmx_map_objectmap_nextnode:Byte Ptr(node:Byte Ptr)
	Function bmx_map_objectmap_key:Object(node:Byte Ptr)
	Function bmx_map_objectmap_value:Object(node:Byte Ptr)
	Function bmx_map_objectmap_hasnext:Int(node:Byte Ptr, root:Byte Ptr)
	Function bmx_map_objectmap_copy(dst:Byte Ptr Ptr, _root:Byte Ptr)
End Extern

Type TObjectMap

	Method Delete()
		Clear
	End Method

	Method Clear()
?ngcmod
		If Not IsEmpty() Then
			_modCount :+ 1
		End If
?
		bmx_map_objectmap_clear(Varptr _root)
	End Method
	
	Method IsEmpty()
		Return bmx_map_objectmap_isempty(Varptr _root)
	End Method
	
	Method Insert( key:Object,value:Object )
		bmx_map_objectmap_insert(key, value, Varptr _root)
?ngcmod
		_modCount :+ 1
?
	End Method

	Method Contains:Int( key:Object )
		Return bmx_map_objectmap_contains(key, Varptr _root)
	End Method
	
	Method ValueForKey:Object( key:Object )
		Return bmx_map_objectmap_valueforkey(key, Varptr _root)
	End Method
	
	Method Remove( key:Object )
?ngcmod
		_modCount :+ 1
?
		Return bmx_map_objectmap_remove(key, Varptr _root)
	End Method

	Method _FirstNode:TObjectNode()
		If Not IsEmpty() Then
			Local node:TObjectNode= New TObjectNode
			node._root = _root
			Return node
		Else
			Return Null
		End If
	End Method
	
	Method Keys:TObjectMapEnumerator()
		Local nodeenum:TObjectNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TObjectKeyEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TObjectEmptyEnumerator
		End If
		Local mapenum:TObjectMapEnumerator=New TObjectMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Values:TObjectMapEnumerator()
		Local nodeenum:TObjectNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TObjectValueEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TObjectEmptyEnumerator
		End If
		Local mapenum:TObjectMapEnumerator=New TObjectMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Copy:TObjectMap()
		Local map:TObjectMap=New TObjectMap
		bmx_map_objectmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Method ObjectEnumerator:TObjectNodeEnumerator()
		Local nodeenum:TObjectNodeEnumerator=New TObjectNodeEnumerator
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

Type TObjectNode
	Field _root:Byte Ptr
	Field _nodePtr:Byte Ptr
	
	Method Key:Object()
		Return bmx_map_objectmap_key(_nodePtr)
	End Method
	
	Method Value:Object()
		Return bmx_map_objectmap_value(_nodePtr)
	End Method

	Method HasNext()
		Return bmx_map_objectmap_hasnext(_nodePtr, _root)
	End Method
	
	Method NextNode:TObjectNode()
		If Not _nodePtr Then
			_nodePtr = bmx_map_objectmap_firstnode(_root)
		Else
			_nodePtr = bmx_map_objectmap_nextnode(_nodePtr)
		End If

		Return Self
	End Method
	
End Type

Type TObjectNodeEnumerator
	Method HasNext()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TObjectMap Concurrent Modification"
?
		Local node:TObjectNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TObjectNode	

	Field _map:TObjectMap
?ngcmod
	Field _expectedModCount:Int
?
End Type

Type TObjectKeyEnumerator Extends TObjectNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TObjectMap Concurrent Modification"
?
		Local node:TObjectNode=_node
		_node=_node.NextNode()
		Return node.Key()
	End Method
End Type

Type TObjectValueEnumerator Extends TObjectNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TObjectMap Concurrent Modification"
?
		Local node:TObjectNode=_node
		_node=_node.NextNode()
		Return node.Value()
	End Method
End Type

Type TObjectMapEnumerator
	Method ObjectEnumerator:TObjectNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TObjectNodeEnumerator
End Type

Type TObjectEmptyEnumerator Extends TObjectNodeEnumerator
	Method HasNext()
		_map = Null
		Return False
	End Method
End Type


