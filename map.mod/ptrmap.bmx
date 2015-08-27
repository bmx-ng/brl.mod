Strict


Extern
	Function bmx_map_ptrmap_clear(root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_isempty:Int(root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_insert(key:Byte Ptr, value:Object, root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_contains:Int(key:Byte Ptr, root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_valueforkey:Object(key:Byte Ptr, root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_remove:Int(key:Byte Ptr, root:Byte Ptr Ptr)
	Function bmx_map_ptrmap_firstnode:Byte Ptr(root:Byte Ptr)
	Function bmx_map_ptrmap_nextnode:Byte Ptr(node:Byte Ptr)
	Function bmx_map_ptrmap_key:Byte Ptr(node:Byte Ptr)
	Function bmx_map_ptrmap_value:Object(node:Byte Ptr)
	Function bmx_map_ptrmap_hasnext:Int(node:Byte Ptr, root:Byte Ptr)
	Function bmx_map_ptrmap_copy(dst:Byte Ptr Ptr, _root:Byte Ptr)
End Extern

Type TPtrMap

	Method Delete()
		Clear
	End Method

	Method Clear()
		If Not IsEmpty() Then
			_modCount :+ 1
		End If
		bmx_map_ptrmap_clear(Varptr _root)
	End Method
	
	Method IsEmpty()
		Return bmx_map_ptrmap_isempty(Varptr _root)
	End Method
	
	Method Insert( key:Byte Ptr,value:Object )
		bmx_map_ptrmap_insert(key, value, Varptr _root)
		_modCount :+ 1
	End Method

	Method Contains:Int( key:Byte Ptr )
		Return bmx_map_ptrmap_contains(key, Varptr _root)
	End Method
	
	Method ValueForKey:Object( key:Byte Ptr )
		Return bmx_map_ptrmap_valueforkey(key, Varptr _root)
	End Method
	
	Method Remove( key:Byte Ptr )
		_modCount :+ 1
		Return bmx_map_ptrmap_remove(key, Varptr _root)
	End Method

	Method _FirstNode:TPtrNode()
		If Not IsEmpty() Then
			Local node:TPtrNode= New TPtrNode
			node._root = _root
			Return node
		Else
			Return Null
		End If
	End Method
	
	Method Keys:TPtrMapEnumerator()
		Local nodeenum:TPtrNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TPtrKeyEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TPtrEmptyEnumerator
		End If
		Local mapenum:TPtrMapEnumerator=New TPtrMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
		nodeenum._expectedModCount = _modCount
		Return mapenum
	End Method
	
	Method Values:TPtrMapEnumerator()
		Local nodeenum:TPtrNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TPtrValueEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TPtrEmptyEnumerator
		End If
		Local mapenum:TPtrMapEnumerator=New TPtrMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
		nodeenum._expectedModCount = _modCount
		Return mapenum
	End Method
	
	Method Copy:TPtrMap()
		Local map:TPtrMap=New TPtrMap
		bmx_map_ptrmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Method ObjectEnumerator:TPtrNodeEnumerator()
		Local nodeenum:TPtrNodeEnumerator=New TPtrNodeEnumerator
		nodeenum._node=_FirstNode()
		nodeenum._map = Self
		nodeenum._expectedModCount = _modCount
		Return nodeenum
	End Method

	Field _root:Byte Ptr
	
	Field _modCount:Int
	
End Type

Type TPtrNode
	Field _root:Byte Ptr
	Field _nodePtr:Byte Ptr
	
	Method Key:Byte Ptr()
		Return bmx_map_ptrmap_key(_nodePtr)
	End Method
	
	Method Value:Object()
		Return bmx_map_ptrmap_value(_nodePtr)
	End Method

	Method HasNext()
		Return bmx_map_ptrmap_hasnext(_nodePtr, _root)
	End Method
	
	Method NextNode:TPtrNode()
		If Not _nodePtr Then
			_nodePtr = bmx_map_ptrmap_firstnode(_root)
		Else
			_nodePtr = bmx_map_ptrmap_nextnode(_nodePtr)
		End If

		Return Self
	End Method
	
End Type

Rem
bbdoc: Byte Ptr holder for key returned by TPtrMap.Keys() enumerator.
End Rem
Type TPtrKey
	Field value:Byte Ptr
End Type

Type TPtrNodeEnumerator
	Method HasNext()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
		Local node:TPtrNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TPtrNode	

	Field _map:TPtrMap
	Field _expectedModCount:Int
End Type

Type TPtrKeyEnumerator Extends TPtrNodeEnumerator
	Field _key:TPtrKey = New TPtrKey
	Method NextObject:Object()
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
		Local node:TPtrNode=_node
		_node=_node.NextNode()
		_key.value = node.Key()
		Return _key
	End Method
End Type

Type TPtrValueEnumerator Extends TPtrNodeEnumerator
	Method NextObject:Object()
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
		Local node:TPtrNode=_node
		_node=_node.NextNode()
		Return node.Value()
	End Method
End Type

Type TPtrMapEnumerator
	Method ObjectEnumerator:TPtrNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TPtrNodeEnumerator
End Type

Type TPtrEmptyEnumerator Extends TPtrNodeEnumerator
	Method HasNext()
		_map = Null
		Return False
	End Method
End Type

