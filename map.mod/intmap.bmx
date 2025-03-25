SuperStrict

Import "common.bmx"

Extern
	Function bmx_map_intmap_clear(root:SavlRoot Ptr Ptr)
	Function bmx_map_intmap_isempty:Int(root:SavlRoot Ptr)
	Function bmx_map_intmap_insert(key:Int, value:Object, root:SavlRoot Ptr Ptr)
	Function bmx_map_intmap_contains:Int(key:Int, root:SavlRoot Ptr)
	Function bmx_map_intmap_valueforkey:Object(key:Int, root:SavlRoot Ptr)
	Function bmx_map_intmap_remove:Int(key:Int, root:SavlRoot Ptr Ptr)
	Function bmx_map_intmap_firstnode:SIntMapNode Ptr(root:SavlRoot Ptr)
	Function bmx_map_intmap_nextnode:SIntMapNode Ptr(node:SIntMapNode Ptr)
	Function bmx_map_intmap_key:Int(node:SIntMapNode Ptr)
	Function bmx_map_intmap_value:Object(node:SIntMapNode Ptr)
	Function bmx_map_intmap_hasnext:Int(node:SIntMapNode Ptr, root:SavlRoot Ptr)
	Function bmx_map_intmap_copy(dst:SavlRoot Ptr Ptr, _root:SavlRoot Ptr)
End Extern

Struct SIntMapNode
	Field link:SavlRoot
	Field key:Int
	Field value:Object
End Struct

Rem
bbdoc: A key/value (Int/Object) map.
End Rem
Type TIntMap

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
		bmx_map_intmap_clear(Varptr _root)
	End Method
	
	Rem
	bbdoc: Checks if the map is empty.
	about: #True if @map is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int()
		Return bmx_map_intmap_isempty(_root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Insert( key:Int,value:Object )
		bmx_map_intmap_insert(key, value, Varptr _root)
?ngcmod
		_modCount :+ 1
?
	End Method

	Rem
	bbdoc: Checks if the map contains @key.
	returns: #True if the map contains @key.
	End Rem
	Method Contains:Int( key:Int )
		Return bmx_map_intmap_contains(key, _root)
	End Method
	
	Rem
	bbdoc: Finds a value given a @key.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method ValueForKey:Object( key:Int )
		Return bmx_map_intmap_valueforkey(key, _root)
	End Method
	
	Rem
	bbdoc: Remove a key/value pair from the map.
	returns: #True if @key was removed, or #False otherwise.
	End Rem
	Method Remove:Int( key:Int )
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
	
	Rem
	bbdoc: Gets the map keys.
	returns: An enumeration object
	about: The object returned by #Keys can be used with #EachIn to iterate through the keys in the map.
	End Rem
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
	
	Rem
	bbdoc: Get the map values.
	returns: An enumeration object.
	about: The object returned by #Values can be used with #EachIn to iterate through the values in the map.
	End Rem
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
	
	Rem
	bbdoc: Returns a copy the contents of this map.
	End Rem
	Method Copy:TIntMap()
		Local map:TIntMap=New TIntMap
		bmx_map_intmap_copy(Varptr map._root, _root)
		Return map
	End Method
	
	Rem
	bbdoc: Returns a node enumeration object.
	about: The object returned by #ObjectEnumerator can be used with #EachIn to iterate through the nodes in the map.
	End Rem
	Method ObjectEnumerator:TIntNodeEnumerator()
		Local nodeenum:TIntNodeEnumerator
		If Not isEmpty() Then
			nodeenum = New TIntNodeEnumerator
			nodeenum._node=_FirstNode()
			nodeenum._map = Self
		Else
			nodeenum=New TIntEmptyEnumerator
		End If
		Return nodeenum
	End Method

	Rem
	bbdoc: Finds a value given a @key using index syntax.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method Operator[]:Object(key:Int)
		Return bmx_map_intmap_valueforkey(key, _root)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map using index syntax.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Operator[]=(key:Int, value:Object)
		bmx_map_intmap_insert(key, value, Varptr _root)
	End Method

	Field _root:SavlRoot Ptr

?ngcmod
	Field _modCount:Int
?

End Type

Type TIntNode
	Field _root:SavlRoot Ptr
	Field _nodePtr:SIntMapNode Ptr
	
	Field _nextNode:SIntMapNode Ptr
	
	Method Key:Int()
		Return bmx_map_intmap_key(_nodePtr)
	End Method
	
	Method Value:Object()
		Return bmx_map_intmap_value(_nodePtr)
	End Method

	Method HasNext:Int()
		Return bmx_map_intmap_hasnext(_nodePtr, _root)
	End Method
	
	Method NextNode:TIntNode()
		If Not _nodePtr Then
			_nodePtr = bmx_map_intmap_firstnode(_root)
		Else
			'_nodePtr = bmx_map_intmap_nextnode(_nodePtr)
			_nodePtr = _nextNode
		End If

		If HasNext() Then
			_nextNode = bmx_map_intmap_nextnode(_nodePtr)
		End If

		Return Self
	End Method
	
	Method Remove()
		
	End Method
	
End Type

Rem
bbdoc: Int holder for key returned by TIntMap.Keys() enumerator.
about: Because a single instance of #TIntKey is used during enumeration, #value changes on each iteration.
End Rem
Type TIntKey
	Rem
	bbdoc: Int key value.
	End Rem
	Field value:Int
End Type

Type TIntNodeEnumerator
	Method HasNext:Int()
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
	Method NextObject:Object() Override
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
	Method NextObject:Object() Override
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
	Method HasNext:Int() Override
		_map = Null
		Return False
	End Method
End Type
