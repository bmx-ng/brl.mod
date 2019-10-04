SuperStrict

Import "collection.bmx"
Import "list.bmx"

Interface IMap<K, V> Extends ICollection<TMapNode<K,V>>

	Method Keys:ICollection<K>()
	Method Values:ICollection<V>()
	Method Add(key:K, value:V)
	Method ContainsKey:Int(key:K)
	Method Remove:Int(key:K)
	Method TryGetValue:Int(key:K, value:V Var)

End Interface

Rem
bbdoc: Represents a collection of keys and values.
End Rem
Type TTreeMap<K, V> Implements IMap<K,V>

	Private
	Field root:TMapNode<K,V>
	Field size:Int
	
	Field comparator:IComparator<K>
	Public

	Rem
	bbdoc: Creates a new #TTreeMap instance using the default comparator.
	End Rem
	Method New()
	End Method
	
	Rem
	bbdoc: Creates a new #TTreeMap instance using the specified comparator.
	End Rem
	Method New(comparator:IComparator<K>)
		Assert comparator
		Self.comparator = comparator
	End Method

	Rem
	bbdoc: Returns an iterator that iterates through the #TTreeMap.
	End Rem
	Method GetIterator:IIterator<TMapNode<K,V>>()
		Return New TMapIterator<K,V>(FirstNode())
	End Method
	
	Rem
	bbdoc: Removes all elements from the #TTreeMap.
	End Rem
	Method Clear()
		root = Null
		size = 0
	End Method

	Rem
	bbdoc: Gets the number of key/value pairs contained in the #TTreeMap.
	End Rem
	Method Count:Int()
		Return size
	End Method

	Rem
	bbdoc: Returns #True if the #TTreeMap is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int() Override
		Return size = 0
	End Method

	Method CopyTo(array:TMapNode<K,V>[], index:Int = 0)
	End Method
	
	Rem
	bbdoc: Returns the #TTreeMap keys as a collection.
	End Rem
	Method Keys:ICollection<K>()
		Local list:TArrayList<K> = New TArrayList<K>(size)
		If size > 0 Then
			For Local node:TMapNode<K,V> = EachIn Self
				list.Add(node.key)
			Next
		End If
		Return list
	End Method

	Rem
	bbdoc: Returns the #TTreeMap values as a collection.
	End Rem
	Method Values:ICollection<V>()
		Local list:TArrayList<V> = New TArrayList<V>(size)
		If size > 0 Then
			For Local node:TMapNode<K,V> = EachIn Self
				list.Add(node.value)
			Next
		End If
		Return list
	End Method

	Rem
	bbdoc: Adds the specified key and value to the #TTreeMap.
	about: Throws an exception if an element with the specified key already exists.
	End Rem
	Method Add(key:K, value:V)
		If FindNode(key) Then
			Throw New TArgumentException("An element with the same key already exists in the map")
		End If
	
		Local node:TMapNode<K,V>=root
		Local parent:TMapNode<K,V>
		Local cmp:Int
		
		While node<>Null
			parent=node
			
			If comparator Then
				cmp = comparator.Compare(key, node.key)
			Else
				cmp = DefaultComparator_Compare(key, node.key)
			End If
			
			If cmp < 0 Then
				node=node.leftNode
			Else If cmp > 0 Then
				node=node.rightNode
			Else
				node.value = value
				Return
			End If
		Wend
		
		node=New TMapNode<K,V>
		node.key=key
		node.value=value
		node.colour=0
		node.parent=parent

		size :+ 1

		If parent=Null
			root=node
			Return
		EndIf
		If cmp > 0 Then
			parent.rightNode=node
		Else
			parent.leftNode=node
		EndIf
		
		RepairAdd node		
	End Method

	Rem
	bbdoc: Determines whether the #TTreeMap contains the specified key.
	returns: #True if the #TTreeMap contains an element with the specified key; otherwise, #False.
	End Rem
	Method ContainsKey:Int(key:K)
		Return FindNode( key )<>Null
	End Method
	
	Rem
	bbdoc: Determines whether the #TTreeMap contains a specific value.
	returns: #True if the #TTreeMap contains an element with the specified value; otherwise, #False.
	End Rem
	Method ContainsValue:Int(value:V)
		For Local node:TMapNode<K,V> = EachIn Self
			If value = node.value Then
				Return True
			End If
		Next
		Return False
	End Method

	Rem
	bbdoc: Removes the value with the specified key from the #TTreeMap.
	returns: #True if the element is successfully found and removed; otherwise, #False. This method returns #False if key is not found in the #TTreeMap.
	End Rem
	Method Remove:Int(key:K)
		Local node:TMapNode<K,V> = FindNode(key)
		If node=Null Then
			Return False
		End If
		RemoveNode node
		size :- 1
		Return True
	End Method

	Rem
	bbdoc: Gets the value associated with the specified key.
	returns: #True if the #TTreeMap contains an element with the specified key; otherwise, #False.
	about: When this method returns, @value contains the value associated with the specified key, if the key is found;
	otherwise, @value will remain unchanged.
	End Rem
	Method TryGetValue:Int(key:K, value:V Var)
		Local node:TMapNode<K,V> = FindNode(key)
		If node <> Null Then
			value = node.value
			Return True
		End If
		Return False
	End Method

	Rem
	bbdoc: Gets the element with the specified key.
	returns: The value if @key exists in the #TTreeMap; otherwise returns the default/#Null value for the value type.
	End Rem
	Method Operator [] :V(key:K)
		Local node:TMapNode<K,V> = FindNode(key)

		If node Then
			Return node.value
		Else
			Local value:V
			Return value
		End If
	End Method

	Rem
	bbdoc: Sets the element with the specified key.
	about: Unlike with #Add, if @key already exists, the current value is replaced with @value.
	End Rem
	Method Operator []= (key:K, value:V)
		Local node:TMapNode<K,V> = FindNode(key)

		If node Then
			node.value = value
		Else
			Add(key, value)
		End If
	End Method

Private
	Method RotateLeft( node:TMapNode<K,V> )
		Local child:TMapNode<K,V>=node.rightNode
		node.rightNode=child.leftNode
		If child.leftNode<>Null
			child.leftNode.parent=node
		EndIf
		child.parent=node.parent
		If node.parent<>Null
			If node=node.parent.leftNode
				node.parent.leftNode=child
			Else
				node.parent.rightNode=child
			EndIf
		Else
			root=child
		EndIf
		child.leftNode=node
		node.parent=child
	End Method
	
	Method RotateRight( node:TMapNode<K,V> )
		Local child:TMapNode<K,V>=node.leftNode
		node.leftNode=child.rightNode
		If child.rightNode<>Null
			child.rightNode.parent=node
		EndIf
		child.parent=node.parent
		If node.parent<>Null
			If node=node.parent.rightNode
				node.parent.rightNode=child
			Else
				node.parent.leftNode=child
			EndIf
		Else
			root=child
		EndIf
		child.rightNode=node
		node.parent=child
	End Method
	
	Method RepairAdd( node:TMapNode<K,V> )
		While node.parent And node.parent.colour=0 And node.parent.parent<>Null
			If node.parent = node.parent.parent.leftNode Then
				Local uncle:TMapNode<K,V>=node.parent.parent.rightNode
				If uncle And uncle.colour = 0 Then
					node.parent.colour = 1
					uncle.colour = 1
					uncle.parent.colour = 0
					node = uncle.parent
				Else
					If node = node.parent.rightNode Then
						node = node.parent
						RotateLeft node
					EndIf
					node.parent.colour=1
					node.parent.parent.colour=0
					RotateRight node.parent.parent
				EndIf
			Else
				Local uncle:TMapNode<K,V>=node.parent.parent.leftNode
				If uncle And uncle.colour=0
					node.parent.colour=1
					uncle.colour=1
					uncle.parent.colour=0
					node=uncle.parent
				Else
					If node = node.parent.leftNode Then
						node=node.parent
						RotateRight node
					EndIf
					node.parent.colour=1
					node.parent.parent.colour=0
					RotateLeft node.parent.parent
				EndIf
			EndIf
		Wend
		root.colour=1
	End Method

	Method FindNode:TMapNode<K,V>( key:K )
		Local node:TMapNode<K,V>=root
		While node<>Null
			Local cmp:Int
			If comparator Then
				cmp = comparator.Compare(key, node.key)
			Else
				cmp = DefaultComparator_Compare(key, node.key)
			End If

			If cmp > 0 Then
				node=node.rightNode
			Else If cmp < 0 Then
				node=node.leftNode
			Else
				Return node
			EndIf
		Wend
		Return node
	End Method

	Method FirstNode:TMapNode<K,V>()
		Local node:TMapNode<K,V> = root
		While node.leftNode <> Null
			node = node.leftNode
		Wend
		Return node
	End Method

	Method RemoveNode( node:TMapNode<K,V> )
		Local splice:TMapNode<K,V>
		Local child:TMapNode<K,V>
		
		If node.leftNode = Null Then
			splice = node
			child = node.rightNode
		Else If node.rightNode = Null Then
			splice = node
			child = node.leftNode
		Else
			splice = node.leftNode
			While splice.rightNode <> Null
				splice = splice.rightNode
			Wend
			child = splice.leftNode
			node.key = splice.key
			node.value = splice.value
		EndIf
		
		Local parent:TMapNode<K,V> = splice.parent
		If child <> Null Then
			child.parent = parent
		EndIf
		If parent = Null Then
			root = child
			Return
		EndIf
		If splice = parent.leftNode Then
			parent.leftNode = child
		Else
			parent.rightNode = child
		EndIf
		
		If splice.colour=1 Then
			RepairRemove child, parent
		End If
	End Method

	Method RepairRemove(node:TMapNode<K,V>, parent:TMapNode<K,V> )
	
		While node <> root And node.colour=1
			If node=parent.leftNode
			
				Local sib:TMapNode<K,V> = parent.rightNode

				If sib.colour=0
					sib.colour=1
					parent.colour=0
					RotateLeft parent
					sib=parent.rightNode
				EndIf
				
				If sib.leftNode.colour=1 And sib.rightNode.colour=1
					sib.colour=0
					node=parent
					parent=parent.parent
				Else
					If sib.rightNode.colour=1
						sib.leftNode.colour=1
						sib.colour=0
						RotateRight sib
						sib=parent.rightNode
					EndIf
					sib.colour=parent.colour
					parent.colour=1
					sib.rightNode.colour=1
					RotateLeft parent
					node=root
				EndIf
			Else	
				Local sib:TMapNode<K,V> = parent.leftNode
				
				If sib.colour=0
					sib.colour=1
					parent.colour=0
					RotateRight parent
					sib=parent.leftNode
				EndIf
				
				If sib.rightNode.colour=1 And sib.leftNode.colour=1
					sib.colour=0
					node=parent
					parent=parent.parent
				Else
					If sib.leftNode.colour=1
						sib.rightNode.colour=1
						sib.colour=0
						RotateLeft sib
						sib=parent.leftNode
					EndIf
					sib.colour=parent.colour
					parent.colour=1
					sib.leftNode.colour=1
					RotateRight parent
					node=root
				EndIf
			EndIf
		Wend
		node.colour=1
	End Method

Public

	Method ToString:String()
	End Method
End Type

Rem
bbdoc: A #TTreeMap node representing a key/value pair.
End Rem
Type TMapNode<K, V>
Private
	Field parent:TMapNode
	Field leftNode:TMapNode
	Field rightNode:TMapNode
	Field colour:Int

	Field key:K
	Field value:V

Public	
	Rem
	bbdoc: Returns the next node in the sequence.
	End Rem
	Method NextNode:TMapNode<K,V>()
		Local node:TMapNode<K,V> = Self
		If node.rightNode<>Null
			node=rightNode
			While node.leftNode <> Null
				node=node.leftNode
			Wend
			Return node
		EndIf
		Local parent:TMapNode<K,V>=parent
		While parent And node=parent.rightNode
			node=parent
			parent=parent.parent
		Wend
		Return parent
	End Method

	Rem
	bbdoc: Returns the key for this node.
	End Rem
	Method GetKey:K()
		Return key
	End Method

	Rem
	bbdoc: Returns the value for this node.
	End Rem
	Method GetValue:V()
		Return value
	End Method
		
End Type

Type TMapIterator<K,V> Implements IIterator<TMapNode<K,V>> 
	Private
	Field initial:TMapNode<K,V>
	
	Method New(initial:TMapNode<K,V>)
		Self.initial = initial
	End Method
	
	Field node:TMapNode<K,V>

	Public

	Method Current:TMapNode<K,V>()
		Return node
	End Method
	
	Method MoveNext:Int()
		If initial Then
			node = initial
			initial = Null
			Return True
		End If
		
		If node Then
			node = node.NextNode()
			Return node <> Null
		End If
		
		Return False
	End Method

End Type

