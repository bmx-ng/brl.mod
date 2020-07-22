SuperStrict


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

Rem
bbdoc: A key/value (String/Object) map.
End Rem
Type TStringMap

	Method Delete()
		Clear
	End Method

	Rem
	bbdoc: Clears the map.
	about: Removes all keys and values.
	End Rem
	Method Clear()
		bmx_map_stringmap_clear(Varptr _root)
	End Method
	
	Rem
	bbdoc: Checks if the map is empty.
	about: #True if @map is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int()
		Return bmx_map_stringmap_isempty(Varptr _root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Insert( key:String,value:Object )
		key.Hash()
		bmx_map_stringmap_insert(key, value, Varptr _root)
	End Method

	Rem
	bbdoc: Checks if the map contains @key.
	returns: #True if the map contains @key.
	End Rem
	Method Contains:Int( key:String )
		key.Hash()
		Return bmx_map_stringmap_contains(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Finds a value given a @key.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method ValueForKey:Object( key:String )
		key.Hash()
		Return bmx_map_stringmap_valueforkey(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Remove a key/value pair from the map.
	returns: #True if @key was removed, or #False otherwise.
	End Rem
	Method Remove:Int( key:String )
		key.Hash()
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
	
	Rem
	bbdoc: Gets the map keys.
	returns: An enumeration object
	about: The object returned by #Keys can be used with #EachIn to iterate through the keys in the map.
	End Rem
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
		Return mapenum
	End Method
	
	Rem
	bbdoc: Get the map values.
	returns: An enumeration object.
	about: The object returned by #Values can be used with #EachIn to iterate through the values in the map.
	End Rem
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
		Return mapenum
	End Method
	
	Rem
	bbdoc: Returns a copy the contents of this map.
	End Rem
	Method Copy:TStringMap()
		Local map:TStringMap=New TStringMap
		bmx_map_stringmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Rem
	bbdoc: Returns a node enumeration object.
	about: The object returned by #ObjectEnumerator can be used with #EachIn to iterate through the nodes in the map.
	End Rem
	Method ObjectEnumerator:TStringNodeEnumerator()
		Local nodeenum:TStringNodeEnumerator
		If Not isEmpty() Then
			nodeenum = New TStringNodeEnumerator
			nodeenum._node=_FirstNode()
			nodeenum._map = Self
		Else
			nodeenum = New TStringEmptyEnumerator
		End If
		Return nodeenum
	End Method
	
	Rem
	bbdoc: Finds a value given a @key using index syntax.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method Operator[]:Object(key:String)
		Return bmx_map_stringmap_valueforkey(key, Varptr _root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map using index syntax.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Operator[]=(key:String, value:Object)
		bmx_map_stringmap_insert(key, value, Varptr _root)
	End Method

	Field _root:Byte Ptr

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

	Method HasNext:Int()
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
	Method HasNext:Int()
		Local has:Int = _node.HasNext()
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
		Local node:TStringNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TStringNode	

	Field _map:TStringMap
End Type

Type TStringKeyEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object() Override
		Local node:TStringNode=_node
		_node=_node.NextNode()
		Return node.Key()
	End Method
End Type

Type TStringValueEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object() Override
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
	Method HasNext:Int() Override
		_map = Null
		Return False
	End Method
End Type

