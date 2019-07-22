SuperStrict


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

Rem
bbdoc: A key/value (Byte Ptr/Object) map.
End Rem
Type TPtrMap

	Method Delete()
		Clear
	End Method

	Rem
	bbdoc: Clears the map.
	about: Removes all keys and values.
	End Rem
	Method Clear()
?ngcmod
		If Not IsEmpty() Then
			_modCount :+ 1
		End If
?
		bmx_map_ptrmap_clear(Varptr _root)
	End Method
	
	Rem
	bbdoc: Checks if the map is empty.
	about: #True if @map is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int()
		Return bmx_map_ptrmap_isempty(Varptr _root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Insert( key:Byte Ptr,value:Object )
		bmx_map_ptrmap_insert(key, value, Varptr _root)
?ngcmod
		_modCount :+ 1
?
	End Method

	Rem
	bbdoc: Checks if the map contains @key.
	returns: #True if the map contains @key.
	End Rem
	Method Contains:Int( key:Byte Ptr )
		Return bmx_map_ptrmap_contains(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Finds a value given a @key.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method ValueForKey:Object( key:Byte Ptr )
		Return bmx_map_ptrmap_valueforkey(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Remove a key/value pair from the map.
	returns: #True if @key was removed, or #False otherwise.
	End Rem
	Method Remove:Int( key:Byte Ptr )
?ngcmod
		_modCount :+ 1
?
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
	
	Rem
	bbdoc: Gets the map keys.
	returns: An enumeration object
	about: The object returned by #Keys can be used with #EachIn to iterate through the keys in the map.
	End Rem
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
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Rem
	bbdoc: Get the map values.
	returns: An enumeration object.
	about: The object returned by #Values can be used with #EachIn to iterate through the values in the map.
	End Rem
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
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return mapenum
	End Method
	
	Rem
	bbdoc: Returns a copy the contents of this map.
	End Rem
	Method Copy:TPtrMap()
		Local map:TPtrMap=New TPtrMap
		bmx_map_ptrmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Rem
	bbdoc: Returns a node enumeration object.
	about: The object returned by #ObjectEnumerator can be used with #EachIn to iterate through the nodes in the map.
	End Rem
	Method ObjectEnumerator:TPtrNodeEnumerator()
		Local nodeenum:TPtrNodeEnumerator
		If Not isEmpty() Then
			nodeenum = New TPtrNodeEnumerator
			nodeenum._node=_FirstNode()
			nodeenum._map = Self
		Else
			nodeenum = New TPtrEmptyEnumerator
		End If
		Return nodeenum
	End Method

	Rem
	bbdoc: Finds a value given a @key using index syntax.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method Operator[]:Object(key:Byte Ptr)
		Return bmx_map_ptrmap_valueforkey(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map using index syntax.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Operator[]=(key:Byte Ptr, value:Object)
		bmx_map_ptrmap_insert(key, value, Varptr _root)
	End Method

	Field _root:Byte Ptr
	
?ngcmod
	Field _modCount:Int
?
	
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

	Method HasNext:Int()
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
about: Because a single instance of #TPtrKey is used during enumeration, #value changes on each iteration.
End Rem
Type TPtrKey
	Rem
	bbdoc: Byte Ptr key value.
	End Rem
	Field value:Byte Ptr
End Type

Type TPtrNodeEnumerator
	Method HasNext:Int()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
?
		Local node:TPtrNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TPtrNode	

	Field _map:TPtrMap
?ngcmod
	Field _expectedModCount:Int
?
End Type

Type TPtrKeyEnumerator Extends TPtrNodeEnumerator
	Field _key:TPtrKey = New TPtrKey
	Method NextObject:Object() Override
?ngcmod
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
?
		Local node:TPtrNode=_node
		_node=_node.NextNode()
		_key.value = node.Key()
		Return _key
	End Method
End Type

Type TPtrValueEnumerator Extends TPtrNodeEnumerator
	Method NextObject:Object() Override
?ngcmod
		Assert _expectedModCount = _map._modCount, "TPtrMap Concurrent Modification"
?
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
	Method HasNext:Int() Override
		_map = Null
		Return False
	End Method
End Type

