
Strict

Rem
bbdoc: Data structures/Maps
End Rem
Module BRL.Map

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09"
ModuleInfo "History: Added index operator overloads to maps."
ModuleInfo "History: 1.08"
ModuleInfo "History: Added TStringMap."
ModuleInfo "History: (Debug) Assertion on modification during iteration."
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Fixed MapKeys/MapValues functions to return enumerators"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Restored KeyValue enumerator"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added Copy method"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed Clear memleak"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Finally changed to red/back tree!"
ModuleInfo "History: Added procedural interface"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed TMap.Remove:TNode not returning node"

Import "intmap.bmx"
Import "ptrmap.bmx"
Import "stringmap.bmx"
Import "objectmap.bmx"
Import "map.c"

Private

Global nil:TNode=New TNode

nil._color=TMap.BLACK
nil._parent=nil
nil._left=nil
nil._right=nil

Public

Type TKeyValue

	Method Key:Object()
		Return _key
	End Method
	
	Method Value:Object()
		Return _value
	End Method
	
	'***** PRIVATE *****

	Field _key:Object,_value:Object

End Type

Type TNode Extends TKeyValue

	Method NextNode:TNode()
		Local node:TNode=Self
		If node._right<>nil
			node=_right
			While node._left<>nil
				node=node._left
			Wend
			Return node
		EndIf
		Local parent:TNode=_parent
		While node=parent._right
			node=parent
			parent=parent._parent
		Wend
		Return parent
	End Method
	
	Method PrevNode:TNode()
		Local node:TNode=Self
		If node._left<>nil
			node=node._left
			While node._right<>nil
				node=node._right
			Wend
			Return node
		EndIf
		Local parent:TNode=node._parent
		While node=parent._left
			node=parent
			parent=node._parent
		Wend
		Return parent
	End Method
	
	Method Clear()
		_parent=Null
		If _left<>nil _left.Clear
		If _right<>nil _right.Clear
	End Method
	
	Method Copy:TNode( parent:TNode )
		Local t:TNode=New TNode
		t._key=_key
		t._value=_value
		t._color=_color
		t._parent=parent
		If _left<>nil t._left=_left.Copy( t )
		If _right<>nil t._right=_right.Copy( t )
		Return t
	End Method
	
	Method Key:Object()
		Return _key
	End Method
	
	Method Value:Object()
		Return _value
	End Method

	'***** PRIVATE *****
	
	Field _color,_parent:TNode=nil,_left:TNode=nil,_right:TNode=nil

End Type

Type TNodeEnumerator
	Method HasNext()
		Local has:Int = _node<>nil
		If Not has Then
			_map = Null
		End If
		Return has
	End Method
	
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TMap Concurrent Modification"
?
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TNode
	
	Field _map:TMap
	Field _expectedModCount:Int
End Type

Type TKeyEnumerator Extends TNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TMap Concurrent Modification"
?
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node._key
	End Method
End Type

Type TValueEnumerator Extends TNodeEnumerator
	Method NextObject:Object()
?ngcmod
		Assert _expectedModCount = _map._modCount, "TMap Concurrent Modification"
?
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node._value
	End Method
End Type

Type TMapEnumerator
	Method ObjectEnumerator:TNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TNodeEnumerator
End Type

'***** PUBLIC *****

Rem
bbdoc: An key/value (Object/Object) map backed by a Red/Black tree.
End Rem
Type TMap

?Not Threaded
	Method Delete()
		Clear
	End Method
?
	Rem
	bbdoc: Clears the map.
	about: Removes all keys and values.
	End Rem
	Method Clear()
		If _root=nil Return
		_root.Clear
		_root=nil
?ngcmod
		_modCount :+ 1
?
	End Method
	
	Rem
	bbdoc: Checks if the map is empty.
	about: #True if @map is empty, otherwise #False.
	End Rem
	Method IsEmpty()
		Return _root=nil
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Insert( key:Object,value:Object )

		Assert key Else "Can't insert Null key into map"

		Local node:TNode=_root,parent:TNode=nil,cmp
		
		While node<>nil
			parent=node
			cmp=key.Compare( node._key )
			If cmp>0
				node=node._right
			Else If cmp<0
				node=node._left
			Else
				node._value=value
				Return
			EndIf
		Wend
		
		node=New TNode
		node._key=key
		node._value=value
		node._color=RED
		node._parent=parent

?ngcmod
		_modCount :+ 1
?
		
		If parent=nil
			_root=node
			Return
		EndIf
		If cmp>0
			parent._right=node
		Else
			parent._left=node
		EndIf
		
		_InsertFixup node
	End Method
	
	Rem
	bbdoc: Checks if the map contains @key.
	returns: #True if the map contains @key.
	End Rem
	Method Contains( key:Object )
		Return _FindNode( key )<>nil
	End Method

	Rem
	bbdoc: Finds a value given a @key.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method ValueForKey:Object( key:Object )
		Local node:TNode=_FindNode( key )
		If node<>nil Return node._value
	End Method
	
	Rem
	bbdoc: Remove a key/value pair from the map.
	returns: #True if @key was removed, or #False otherwise.
	End Rem
	Method Remove( key:Object )
		Local node:TNode=_FindNode( key )
		If node=nil Return 0
		 _RemoveNode node
?ngcmod
		_modCount :+ 1
?
		Return 1
	End Method
	
	Rem
	bbdoc: Gets the map keys.
	returns: An enumeration object
	about: The object returned by #Keys can be used with #EachIn to iterate through the keys in the map.
	End Rem
	Method Keys:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TKeyEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
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
	Method Values:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TValueEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
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
	Method Copy:TMap()
		Local map:TMap=New TMap
		'avoid copying an empty map (_root = nil there), else it borks "eachin"
		If _root <> nil
			map._root=_root.Copy( nil )
		EndIf
		Return map
	End Method

	Rem
	bbdoc: Returns a node enumeration Object.
	about: The object returned by #ObjectEnumerator can be used with #EachIn to iterate through the nodes in the map.
	End Rem
	Method ObjectEnumerator:TNodeEnumerator()
		Local nodeenum:TNodeEnumerator=New TNodeEnumerator
		nodeenum._node=_FirstNode()
		nodeenum._map = Self
?ngcmod
		nodeenum._expectedModCount = _modCount
?
		Return nodeenum
	End Method
	
	'***** PRIVATE *****
	
	Method _FirstNode:TNode()
		Local node:TNode=_root
		While node._left<>nil
			node=node._left
		Wend
		Return node
	End Method
	
	Method _LastNode:TNode()
		Local node:TNode=_root
		While node._right<>nil
			node=node._right
		Wend
		Return node
	End Method
	
	Method _FindNode:TNode( key:Object )
		Local node:TNode=_root
		While node<>nil
			Local cmp=key.Compare( node._key )
			If cmp>0
				node=node._right
			Else If cmp<0
				node=node._left
			Else
				Return node
			EndIf
		Wend
		Return node
	End Method
	
	Method _RemoveNode( node:TNode )
		Local splice:TNode,child:TNode
		
		If node._left=nil
			splice=node
			child=node._right
		Else If node._right=nil
			splice=node
			child=node._left
		Else
			splice=node._left
			While splice._right<>nil
				splice=splice._right
			Wend
			child=splice._left
			node._key=splice._key
			node._value=splice._value
		EndIf
		Local parent:TNode=splice._parent
		If child<>nil
			child._parent=parent
		EndIf
		If parent=nil
			_root=child
			Return
		EndIf
		If splice=parent._left
			parent._left=child
		Else
			parent._right=child
		EndIf
		
		If splice._color=BLACK _DeleteFixup child,parent
	End Method
	
	Method _InsertFixup( node:TNode )
		While node._parent._color=RED And node._parent._parent<>nil
			If node._parent=node._parent._parent._left
				Local uncle:TNode=node._parent._parent._right
				If uncle._color=RED
					node._parent._color=BLACK
					uncle._color=BLACK
					uncle._parent._color=RED
					node=uncle._parent
				Else
					If node=node._parent._right
						node=node._parent
						_RotateLeft node
					EndIf
					node._parent._color=BLACK
					node._parent._parent._color=RED
					_RotateRight node._parent._parent
				EndIf
			Else
				Local uncle:TNode=node._parent._parent._left
				If uncle._color=RED
					node._parent._color=BLACK
					uncle._color=BLACK
					uncle._parent._color=RED
					node=uncle._parent
				Else
					If node=node._parent._left
						node=node._parent
						_RotateRight node
					EndIf
					node._parent._color=BLACK
					node._parent._parent._color=RED
					_RotateLeft node._parent._parent
				EndIf
			EndIf
		Wend
		_root._color=BLACK
	End Method
	
	Method _RotateLeft( node:TNode )
		Local child:TNode=node._right
		node._right=child._left
		If child._left<>nil
			child._left._parent=node
		EndIf
		child._parent=node._parent
		If node._parent<>nil
			If node=node._parent._left
				node._parent._left=child
			Else
				node._parent._right=child
			EndIf
		Else
			_root=child
		EndIf
		child._left=node
		node._parent=child
	End Method
	
	Method _RotateRight( node:TNode )
		Local child:TNode=node._left
		node._left=child._right
		If child._right<>nil
			child._right._parent=node
		EndIf
		child._parent=node._parent
		If node._parent<>nil
			If node=node._parent._right
				node._parent._right=child
			Else
				node._parent._left=child
			EndIf
		Else
			_root=child
		EndIf
		child._right=node
		node._parent=child
	End Method
	
	Method _DeleteFixup( node:TNode,parent:TNode )
	
		While node<>_root And node._color=BLACK
			If node=parent._left
			
				Local sib:TNode=parent._right

				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateLeft parent
					sib=parent._right
				EndIf
				
				If sib._left._color=BLACK And sib._right._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._right._color=BLACK
						sib._left._color=BLACK
						sib._color=RED
						_RotateRight sib
						sib=parent._right
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._right._color=BLACK
					_RotateLeft parent
					node=_root
				EndIf
			Else	
				Local sib:TNode=parent._left
				
				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateRight parent
					sib=parent._left
				EndIf
				
				If sib._right._color=BLACK And sib._left._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._left._color=BLACK
						sib._right._color=BLACK
						sib._color=RED
						_RotateLeft sib
						sib=parent._left
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._left._color=BLACK
					_RotateRight parent
					node=_root
				EndIf
			EndIf
		Wend
		node._color=BLACK
	End Method

	Rem
	bbdoc: Finds a value given a @key using index syntax.
	returns: The value associated with @key.
	about: If the map does not contain @key, a #Null object is returned.
	End Rem
	Method Operator[]:Object(key:Object)
		Return ValueForKey(key)
	End Method
	
	Rem
	bbdoc: Inserts a key/value pair into the map using index syntax.
	about: If the map already contains @key, its value is overwritten with @value. 
	End Rem
	Method Operator[]=(key:Object, value:Object)
		Insert(key, value)
	End Method

	Const RED=-1,BLACK=1
	
	Field _root:TNode=nil
	
?ngcmod
	Field _modCount:Int
?
End Type

Rem
bbdoc: Creates a map
returns: A new map object
End Rem
Function CreateMap:TMap()
	Return New TMap
End Function

Rem
bbdoc: Clears a map
about:
#ClearMap removes all keys and values from @map
End Rem
Function ClearMap( map:TMap )
	map.Clear
End Function

Rem
bbdoc: Checks if a map is empty
returns: True if @map is empty, otherwise false
End Rem
Function MapIsEmpty( map:TMap )
	Return map.IsEmpty()
End Function

Rem
bbdoc: Inserts a key/value pair into a map
about:
If @map already contained @key, it's value is overwritten with @value. 
End Rem
Function MapInsert( map:TMap,key:Object,value:Object )
	map.Insert key,value
End Function

Rem
bbdoc: Finds a value given a key
returns: The value associated with @key
about:
If @map does not contain @key, a #Null object is returned.
End Rem
Function MapValueForKey:Object( map:TMap,key:Object )
	Return map.ValueForKey( key )
End Function

Rem
bbdoc: Checks if a map contains a key
returns: True if @map contains @key
End Rem
Function MapContains( map:TMap,key:Object )
	Return map.Contains( key )
End Function

Rem
bbdoc: Removes a key/value pair from a map
End Rem
Function MapRemove( map:TMap,key:Object )
	map.Remove key
End Function

Rem
bbdoc: Gets map keys
returns: An iterator object
about:
The object returned by #MapKeys can be used with #EachIn to iterate through 
the keys in @map.
End Rem
Function MapKeys:TMapEnumerator( map:TMap )
	Return map.Keys()
End Function

Rem
bbdoc: Gets map values
returns: An iterator object
about:
The object returned by #MapValues can be used with #EachIn to iterate through 
the values in @map.
End Rem
Function MapValues:TMapEnumerator( map:TMap )
	Return map.Values()
End Function

Rem
bbdoc: Copies a map
returns: A copy of @map
End Rem
Function CopyMap:TMap( map:TMap )
	Return map.Copy()
End Function

