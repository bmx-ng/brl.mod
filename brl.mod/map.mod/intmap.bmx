Strict


Extern
	Function bmx_map_intmap_clear(root:Byte Ptr Ptr)
	Function bmx_map_intmap_isempty:Int(root:Byte Ptr Ptr)
	Function bmx_map_intmap_insert(key:Int, value:Object, root:Byte Ptr Ptr)
	Function bmx_map_intmap_contains:Int(key:Int, root:Byte Ptr Ptr)
	Function bmx_map_intmap_valueforkey:Object(key:Int, root:Byte Ptr Ptr)
	Function bmx_map_intmap_remove:Int(key:Int, root:Byte Ptr Ptr)
	Function bmx_map_intmap_firstnode:Byte Ptr(root:Byte Ptr)
	Function bmx_map_intmap_nextnode:Byte Ptr(node:Byte Ptr)
	Function bmx_map_intmap_key:Int(node:Byte Ptr)
	Function bmx_map_intmap_value:Object(node:Byte Ptr)
	Function bmx_map_intmap_hasnext:Int(node:Byte Ptr, root:Byte Ptr)
	Function bmx_map_intmap_copy(dst:Byte Ptr Ptr, _root:Byte Ptr)
End Extern

Type TIntMap

	Method Delete()
		Clear
	End Method

	Method Clear()
?ngcmod
		If Not IsEmpty() Then
			_modCount :+ 1
		End If
?
		bmx_map_intmap_clear(Varptr _root)
	End Method
	
	Method IsEmpty()
		Return bmx_map_intmap_isempty(Varptr _root)
	End Method
	
	Method Insert( key:Int,value:Object )
		bmx_map_intmap_insert(key, value, Varptr _root)
?ngcmod
		_modCount :+ 1
?
	End Method

	Method Contains:Int( key:Int )
		Return bmx_map_intmap_contains(key, Varptr _root)
	End Method
	
	Method ValueForKey:Object( key:Int )
		Return bmx_map_intmap_valueforkey(key, Varptr _root)
	End Method
	
	Method Remove( key:Int )
?ngcmod
		_modCount :+ 1
?
		Return bmx_map_intmap_remove(key, Varptr _root)
	End Method

	Method _FirstNode:TIntNode()
		If Not IsEmpty() Then
			Local node:TIntNode= New TIntNode
			node._root = _root
			Return node
		Else
			Return Null
		End If
	End Method
	
	Method Keys:TIntMapEnumerator()
		Local nodeenum:TIntNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TIntKeyEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TIntEmptyEnumerator
		End If
		Local mapenum:TIntMapEnumerator=New TIntMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Values:TIntMapEnumerator()
		Local nodeenum:TIntNodeEnumerator
		If Not isEmpty() Then
			nodeenum=New TIntValueEnumerator
			nodeenum._node=_FirstNode()
		Else
			nodeenum=New TIntEmptyEnumerator
		End If
		Local mapenum:TIntMapEnumerator=New TIntMapEnumerator
		mapenum._enumerator=nodeenum
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Method Copy:TIntMap()
		Local map:TIntMap=New TIntMap
		bmx_map_intmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Method ObjectEnumerator:TIntNodeEnumerator()
		Local nodeenum:TIntNodeEnumerator=New TIntNodeEnumerator
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

Type TIntNode
	Field _root:Byte Ptr
	Field _nodePtr:Byte Ptr
	
	Method Key:Int()
		Return bmx_map_intmap_key(_nodePtr)
	End Method
	
	Method Value:Object()
		Return bmx_map_intmap_value(_nodePtr)
	End Method

	Method HasNext()
		Return bmx_map_intmap_hasnext(_nodePtr, _root)
	End Method
	
	Method NextNode:TIntNode()
		If Not _nodePtr Then
			_nodePtr = bmx_map_intmap_firstnode(_root)
		Else
			_nodePtr = bmx_map_intmap_nextnode(_nodePtr)
		End If

		Return Self
	End Method
	
End Type

Rem
bbdoc: Int holder for key returned by TIntMap.Keys() enumerator.
End Rem
Type TIntKey
	Field value:Int
End Type

Type TIntNodeEnumerator
	Method HasNext()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TIntMap Concurrent Modification"
?
		Local node:TIntNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TIntNode	

	Field _map:TIntMap
?ngcmod
	Field _expectedModCount:Int
?
End Type

Type TIntKeyEnumerator Extends TIntNodeEnumerator
	Field _key:TIntKey = New TIntKey
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TIntMap Concurrent Modification"
?
		Local node:TIntNode=_node
		_node=_node.NextNode()
		_key.value = node.Key()
		Return _key
	End Method
End Type

Type TIntValueEnumerator Extends TIntNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TIntMap Concurrent Modification"
?
		Local node:TIntNode=_node
		_node=_node.NextNode()
		Return node.Value()
	End Method
End Type

Type TIntMapEnumerator
	Method ObjectEnumerator:TIntNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TIntNodeEnumerator
End Type

Type TIntEmptyEnumerator Extends TIntNodeEnumerator
	Method HasNext()
		_map = Null
		Return False
	End Method
End Type
