SuperStrict

Import "collection.bmx"

Rem
bbdoc: A doubly linked list.
End Rem
Type TLinkedList<T> Implements ICollection<T>
Private
	Field head:TLinkedListNode<T>
	Field size:Int
Public

	Rem
	bbdoc: Creates a new #TLinkedList initialised by @array.
	End Rem
	Method New(array:T[])
		If array Then
			For Local value:T = EachIn array
				AddLast(value)
			Next
		End If
	End Method

	Rem
	bbdoc: Creates a new #TLinkedList initialised by @iterable.
	End Rem
	Method New(iterable:IIterable<T>)
		If iterable Then
			For Local value:T = EachIn iterable
				AddLast(value)
			Next
		End If
	End Method

	Rem
	bbdoc: Returns an iterator that iterates through the #TLinkedList.
	End Rem
	Method GetIterator:IIterator<T>()
		Return New TLinkedListIterator<T>(Self)
	End Method

	Rem
	bbdoc: Gets the number of nodes contained in the #TLinkedList. 
	End Rem
	Method Count:Int()
		Return size
	End Method

	Method CopyTo(array:T[], index:Int = 0)
		' TODO
	End Method

	Rem
	bbdoc: Gets the first node of the #TLinkedList.
	End Rem
	Method First:TLinkedListNode<T>()
		Return head
	End Method
	
	Rem
	bbdoc: Gets the last node of the #TLinkedList.
	End Rem
	Method Last:TLinkedListNode<T>()
		If head Then
			Return head.PreviousNode
		Else
			Return Null
		End If
	End Method
	
	Rem
	bbdoc: Adds a new node containing the specified @value after the specified existing @node in the #TLinkedList.
	returns: The new node.
	End Rem
	Method AddAfter:TLinkedListNode<T>(node:TLinkedListNode<T>, value:T)
		ValidateNode(node)
		
		Local newNode:TLinkedListNode<T> = New TLinkedListNode<T>(Self, value)
		
		InsertNodeBefore(node.nextNode, newNode)
		
		Return newNode
	End Method
	
	Rem
	bbdoc: Adds the specified @newNode after the specified existing @node in the #TLinkedList.

	End Rem
	Method AddAfter(node:TLinkedListNode<T>, newNode:TLinkedListNode<T>)
		ValidateNode(node)
		ValidateNewNode(newNode)
		
		InsertNodeBefore(node.nextNode, newNode)
		newNode.list = Self
	End Method
	
	Rem
	bbdoc: Adds a new node containing the specified @value before the specified existing @node in the #TLinkedList.
	returns: The new node.
	End Rem
	Method AddBefore:TLinkedListNode<T>(node:TLinkedListNode<T>, value:T)
		ValidateNode(node)
		Local newNode:TLinkedListNode<T> = New TLinkedListNode<T>(Self, value)

		InsertNodeBefore(node, newNode)

		If node = head Then
			head = newNode
		End If
		
		Return newNode
	End Method
	
	Rem
	bbdoc: Adds the specified @newNode before the specified existing node in the LinkedList<T>.
	End Rem
	Method AddBefore(node:TLinkedListNode<T>, newNode:TLinkedListNode<T>)
		ValidateNode(node)
		ValidateNewNode(newNode)
		
		InsertNodeBefore(node, newNode)
		newNode.list = Self
		
		If node = head Then
			head = newNode
		End If
	End Method
	
	Rem
	bbdoc: Adds the specified new @node at the start of the #TLinkedList.
	End Rem
	Method AddFirst(node:TLinkedListNode<T>)
		ValidateNewNode(node)
		If Not head Then
			CreateHead(head)
		Else
			InsertNodeBefore(head, node)
			head = node
		End If
		node.list = Self
	End Method
	
	Rem
	bbdoc: Adds a new node containing the specified @value at the start of the #TLinkedList.
	returns: The new node.
	End Rem
	Method AddFirst:TLinkedListNode<T>(value:T)
		Local node:TLinkedListNode<T> = New TLinkedListNode<T>(Self, value)
		If Not head Then
			CreateHead(node)
		Else
			InsertNodeBefore(head, node)
			head = node
		End If
		Return node
	End Method
	
	Rem
	bbdoc: Adds the specified new @node at the end of the #TLinkedList.
	End Rem
	Method AddLast(node:TLinkedListNode<T>)
		ValidateNewNode(node)
		
		If Not head Then
			CreateHead(node)
		Else
			InsertNodeBefore(head, node)
		End If
		node.list = Self
	End Method
	
	Rem
	bbdoc: Adds a new node containing the specified @value at the end of the #TLinkedList.
	End Rem
	Method AddLast:TLinkedListNode<T>(value:T)
		Local node:TLinkedListNode<T> = New TLinkedListNode<T>(Self, value)
		If Not head Then
			CreateHead(node)
		Else
			InsertNodeBefore(head, node)
		End If
		Return node
	End Method
	
	Rem
	bbdoc: Removes all nodes from the #TLinkedList.
	End Rem
	Method Clear()
		Local node:TLinkedListNode<T> = head
		While node
			Local tmp:TLinkedListNode<T> = node
			node = node.nextNode
			tmp.Clear()
		Wend
		
		head = Null
		size = 0
	End Method
	
	Rem
	bbdoc: Determines whether @value is in the #TLinkedList.
	returns: #True if @value is in the #TLinkedList, or #Fale otherwise.
	End Rem
	Method Contains:Int(value:T)
		Return Find(value) <> Null
	End Method
	
	Rem
	bbdoc: Finds the first node that contains @value.
	returns: The first node that contains @value or #Null if not found.
	End Rem
	Method Find:TLinkedListNode<T>(value:T)
		Local node:TLinkedListNode<T> = head
		If node Then
			Repeat
				If node.value = value Then
					Return node
				End If
				node = node.nextNode
			Until node = head
		End If
		
		Return Null
	End Method
	
	Rem
	bbdoc: Finds the last node that contains @value.
	End Rem
	Method FindLast:TLinkedListNode<T>(value:T)
		If Not head Then
			Return Null
		End If
		
		Local last:TLinkedListNode<T> = head.previousNode
		Local node:TLinkedListNode<T> = last
		
		If node
			Repeat
				If node.value = value Then
					Return node
				End If
				node = node.previousNode
			Until node = last
		End If
		
		Return Null
	End Method
	
	Rem
	bbdoc: Removes the specified @node from the #TLinkedList.
	End Rem
	Method Remove(node:TLinkedListNode<T>)
		ValidateNode(node)
		RemoveNode(node)
	End Method
	
	Rem
	bbdoc: Removes the first occurrence of @value from the #TLinkedList.
	End Rem
	Method Remove:Int(value:T)
		Local node:TLinkedListNode<T>
		If node Then
			RemoveNode(node)
			Return True
		End If
		Return False
	End Method
	
	Rem
	bbdoc: Removes the node at the start of the #TLinkedList.
	End Rem
	Method RemoveFirst()
		If Not head Then
			Throw New TInvalidOperationException("list is empty")
		End If
		
		RemoveNode(head)
	End Method
	
	Rem
	bbdoc: Removes the node at the end of the #TLinkedList.
	End Rem
	Method RemoveLast()
		If Not head Then
			Throw New TInvalidOperationException("list is empty")
		End If
		
		RemoveNode(head.previousNode)		
	End Method
	
Private
	Method ValidateNode(node:TLinkedListNode<T>)
		If Not node Then
			Throw New TArgumentNullException("node")
		End If
		
		If node.list <> Self Then
			Throw New TInvalidOperationException("node parent list is different")
		End If
	End Method
	
	Method ValidateNewNode(node:TLinkedListNode<T>)
		If Not node Then
			Throw New TArgumentNullException("node")
		End If
		
		If node.list Then
			Throw New TInvalidOperationException("node is from another list")
		End If
	End Method
	
	Method RemoveNode(node:TLinkedListNode<T>)
		If node.nextNode = node Then
			head = Null
		Else
			node.nextNode.previousNode = node.previousNode
			node.previousNode.nextNode = node.nextNode
			If head = node Then
				head = node.nextNode
			End If
			node.Clear()
			size :- 1
		End If
	End Method
	
	Method CreateHead(node:TLinkedListNode<T>)
		node.nextNode = node
		node.previousNode = node
		head = node
		size :+ 1
	End Method
	
	Method InsertNodeBefore(node:TLinkedListNode<T>, newNode:TLinkedListNode<T>)
		newNode.nextNode = node
		newNode.previousNode = node.previousNode
		node.previousNode.nextNode = newNode
		node.previousNode = newNode
		size :+ 1
	End Method
Public

End Type

Rem
bbdoc: Represents a node in a #TLinkedList.
End Rem
Type TLinkedListNode<T>
Private
	Field list:TLinkedList<T>
	Field nextNode:TLinkedListNode<T>
	Field previousNode:TLinkedListNode<T>
Public
	Field value:T

	Rem
	bbdoc: Creates a new #TLinkedListNode instance with the specified @value.
	End Rem
	Method New(value:T)
		Self.value = value
	End Method
	
Private
	Method New(list:TLinkedList<T>, value:T)
		Self.list = list
		Self.value = value
	End Method

	Method Clear()
		list = Null
		nextNode = Null
		previousNode = Null
	End Method
Public
End Type

Type TLinkedListIterator<T> Implements IIterator<T> 
	Private
	Field list:TLinkedList<T>
	Field node:TLinkedListNode<T>
	Field index:Int
	Field value:T
	
	Method New(list:TLinkedList<T>)
		Self.list = list
		node = list.head
	End Method
	
	Public

	Method Current:T()
		Return value
	End Method
	
	Method MoveNext:Int()
		If Not node Then
			index = list.size + 1
			Return False
		End If
		
		index :+ 1
		value = node.value
		node = node.nextNode
		If node = list.head Then
			node = Null
		End If
		
		Return True
	End Method

End Type
