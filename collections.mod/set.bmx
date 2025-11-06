SuperStrict

Import "list.bmx"

Interface ISet<T> Extends ICollection<T>

	Method Add:Int(element:T)
	Method Clear()
	Method Contains:Int(element:T)

End Interface

Rem
bbdoc: Represents a collection of elements that is maintained in sorted order. Duplicate elements are not allowed.
End Rem
Type TSet<T> Implements ISet<T>

	Private
	Field root:TSetNode<T>
	Field size:Int
	
	Field version:Int
	
	Field comparator:IComparator<T>
	Public

	Rem
	bbdoc: Creates a new #TSet instance using the default comparator.
	End Rem
	Method New()
	End Method
	
	Rem
	bbdoc: Creates a new #TSet instance using the specified comparator.
	End Rem
	Method New(comparator:IComparator<T>)
		Self.comparator = comparator
	End Method

	Rem
	bbdoc: Creates a new #TSet initialised by @array.
	End Rem
	Method New(array:T[], comparator:IComparator<T> = Null)
		Self.comparator = comparator
		
		If array Then
			For Local element:T = EachIn array
				Add(element)
			Next
		End If
	End Method

	Rem
	bbdoc: Creates a new #TSet initialised by @iterable.
	End Rem
	Method New(iterable:IIterable<T>, comparator:IComparator<T> = Null)
		Self.comparator = comparator
		
		If iterable Then
			For Local element:T = EachIn iterable
				Add(element)
			Next
		End If
	End Method

	Rem
	bbdoc: Returns an iterator that iterates through the #TSet.
	End Rem
	Method GetIterator:IIterator<T>()
		Return New TSetIterator<T>(FirstNode())
	End Method
	
	Rem
	bbdoc: Removes all elements from the set.
	End Rem
	Method Clear()
		root = Null
		size = 0
		version :+ 1
	End Method

	Rem
	bbdoc: Gets the number of elements contained in the #TSet.
	End Rem
	Method Count:Int()
		Return size
	End Method

	Rem
	bbdoc: Returns #True if the #TSet is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int() Override
		Return size = 0
	End Method

	Method CopyTo(array:T[], index:Int = 0)
	End Method
	
	Rem
	bbdoc: Adds an element to the #TSet and returns a value that indicates if it was successfully added.
	End Rem
	Method Add:Int(element:T)
		Local node:TSetNode<T>=root
		Local parent:TSetNode<T>
		Local cmp:Int
		
		While node<>Null
			parent=node
			
			cmp = DoCompare(element, node.element)
			
			If cmp < 0 Then
				node=node.leftNode
			Else If cmp > 0 Then
				node=node.rightNode
			Else
				Return False
			End If
		Wend
		
		node=New TSetNode<T>
		node.element=element
		node.colour=0
		node.parent=parent

		size :+ 1
		version :+ 1

		If parent=Null
			root=node
			Return True
		EndIf
		If cmp > 0 Then
			parent.rightNode=node
		Else
			parent.leftNode=node
		EndIf
		
		RepairAdd node		
		
		Return True
	End Method

	Rem
	bbdoc: Removes any element in the current #TSet that is also in @other.
	End Rem
	Method Complement(other:IIterable<T>)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If

		If Not size Then
			Return
		End If
		
		If other = Self Then
			Clear()
			Return
		End If
		
		Local set:TSet<T> = TSet<T>(other)
		If set Then
			If Not (DoCompare(set.LastNode().element, FirstNode().element) < 0 Or DoCompare(set.FirstNode().element, LastNode().element) > 0) Then
				Local minimum:T = FirstNode().element
				Local maximum:T = LastNode().element
				For Local element:T = EachIn other
					If DoCompare(element, minimum) < 0 Then
						Continue
					End If
					
					If DoCompare(element, maximum) > 0 Then
						Exit
					End If
					
					Remove(element)
				Next
			End If
		Else
			Local minimum:T = FirstNode().element
			Local maximum:T = LastNode().element
			For Local element:T = EachIn other
				If Not (DoCompare(element, minimum) < 0 Or DoCompare(element, maximum) > 0) And Contains(element) Then
					Remove(element)
				End If
			Next
		End If
	End Method

	Rem
	bbdoc: Determines whether the #TSet contains the specified key.
	returns: #True if the #TSet contains an element with the specified key; otherwise, #False.
	End Rem
	Method Contains:Int(element:T)
		Return FindNode( element )<>Null
	End Method
	
	Rem
	bbdoc: Returns a view of a subset in the #TSet.
	returns: A subset view that contains only the values in the specified range.
	about: This method returns a view of the range of elements that fall between @lowerValue and @upperValue.
	This method does not copy elements from the #TSet, but provides a window into the underlying #TSet itself.
	You can make changes in both the view and in the underlying #TSet.
	End Rem
	Method ViewBetween:TSet<T>(lowerValue:T, upperValue:T)
		If DoCompare(lowerValue, upperValue) > 0 Then
			Throw New TArgumentException("lowerValue is greater than upperValue")
		End If
		
		Return New TSubSet<T>(Self, lowerValue, upperValue)
	End Method

	Rem
	bbdoc: Modifies the current #TSet so that it contains only elements that are also in a specified #IIterable.
	End Rem
	Method Intersection(other:IIterable<T>)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If

		If Not size Then
			Return
		End If
		
		If TSubSet<T>(Self) Then
			Sync()
		End If
		
		Local tmp:TArrayList<T> = New TArrayList<T>(size)
		For Local element:T = EachIn other
			If Contains(element) Then
				tmp.Add(element)
				Remove(element)
			End If
		Next
		Clear()

		For Local element:T = EachIn tmp
			If Not Contains(element) Then
				Add(element)
			End If
		Next
	End Method
	
	Rem
	bbdoc: Determines whether the #TSet object is a proper subset of the specified #IIterable.
	returns: #True if the #TSet is a proper subset of @other; otherwise, #False.
	about: An empty set is a proper subset of any other collection. Therefore, this method returns #True if the collection represented
	by the current #TSet is empty unless @other is also an empty set.

	This method always returns #False if #Count is greater than or equal to the number of elements in @other.
	End Rem
	Method IsProperSubsetOf:Int(other:IIterable<T>)
		Return DoIsSubsetOf(other, True)
	End Method
	
	Rem
	bbdoc: Determines whether the #TSet is a proper superset of the specified #IIterable.
	returns: #True if the #TSet is a proper superset of @other; otherwise, #False.
	about: An empty set is a proper superset of any other collection. Therefore, this method returns #True if the
	collection represented by @other is empty unless the current #TSet is also empty.

	This method always returns #False if #Count is less than or equal to the number of elements in @other.
	End Rem
	Method IsProperSupersetOf:Int(other:IIterable<T>)
		Return DoIsSupersetOf(other, True)
	End Method
	
	Rem
	bbdoc: Determines whether the #TSet is a subset of the specified #IIterable.
	returns: #True if the current #TSet is a subset of @other; otherwise, #False.
	about: An empty set is a subset of any other collection, including an empty set; therefore, this method returns
	#True if the collection represented by the current #TSet is empty, even if the @other parameter is an empty set.

	This method always returns #False if #Count is greater than the number of elements in @other.
	End Rem
	Method IsSubsetOf:Int(other:IIterable<T>)
		Return DoIsSubsetOf(other, False)
	End Method
	
	Rem
	bbdoc: Determines whether the #TSet is a superset of the specified #IIterable.
	returns: #True if the #TSet is a superset of @other; otherwise, #False.
	about: All collections, including the empty set, are supersets of the empty set. Therefore, this method returns #True if
	the collection represented by @other is empty, even if the current #TSet is empty.

	This method always returns #False if #Count is less than the number of elements in @other.
	End Rem
	Method IsSupersetOf:Int(other:IIterable<T>)
		Return DoIsSupersetOf(other, False)
	End Method
	
	Rem
	bbdoc: Determines whether the current #TSet and a specified #IIterable share common elements.
	returns: #True if the #TSet and @other share at least one common element; otherwise, #False.
	End Rem
	Method Overlaps:Int(other:IIterable<T>)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If
		
		If Not size Then
			Return False
		End If
		
		For Local element:T = EachIn other
			If Contains(element) Then
				Return True
			End If
		Next
		
		Return False
	End Method

	Rem
	bbdoc: Removes a specified element from the #TSet.
	returns: #True if the element is successfully found and removed; otherwise, #False. This method returns #False if the element is not found in the #TSet.
	End Rem
	Method Remove:Int(element:T)
		Local node:TSetNode<T> = FindNode(element)
		If node=Null Then
			Return False
		End If
		RemoveNode node
		size :- 1
		version :+ 1
		Return True
	End Method

	Rem
	bbdoc: Modifies the current #TSet so that it contains only elements that are present either in the current set or in the specified #IIterable, but not both.
	End Rem
	Method SymmetricDifference(other:IIterable<T>)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If

		If Not size Then
			UnionOf(other)
			Return
		End If
		
		If other = Self Then
			Clear()
			Return
		End If
		
		Local set:TSet<T> = TSet<T>(other)
		
		If Not set Then
			set = New TSet<T>(other, comparator)
		End If
		
		For Local element:T = EachIn set
			If Contains(element) Then
				Remove(element)
			Else
				Add(element)
			End If
		Next
	End Method

	Rem
	bbdoc: Searches the set for a given value and returns the equal value it finds, if any.
	End Rem
	Method TryGetValue:Int(value:T, actualValue:T Var)
		Local node:TSetNode<T> = FindNode(value)
		If node <> Null Then
			actualValue = node.element
			Return True
		End If
		Return False
	End Method
	
	Rem
	bbdoc: Modifies the current #TSet so that it contains all elements that are present in either the current #TSet or the specified #IIterable.
	End Rem
	Method UnionOf(other:IIterable<T>)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If
		
		Local set:TSet<T> = TSet<T>(other)

		If TSubSet<T>(Self) Then
			Sync()
		End If
		
		If set And Not TSubSet<T>(Self) And Not size Then
			Local tmp:TSet<T> = New TSet<T>(other, comparator)
			root = tmp.root
			size = tmp.size
			version :+ 1
			Return
		End If
				
		For Local element:T = EachIn other
			If Not Contains(element) Then
				Add(element)
			End If
		Next
	End Method

	Rem
	bbdoc: Converts a #TSet to an array.
	returns: An array of elements.
	End Rem
	Method ToArray:T[]()
		Local arr:T[Count()]
		Local i:Int
		For Local elem:T = EachIn Self
			arr[i] = elem
			i :+ 1
		Next
		Return arr
	End Method

	Rem
	bbdoc: Creates a new #TSet from an array.
	returns: A new #TSet containing the elements from @array.
	End Rem
	Function FromArray:TSet<T>(array:T[], comparator:IComparator<T> = Null)
		Return New TSet<T>(array, comparator)
	End Function

Private
	Method RotateLeft( node:TSetNode<T> )
		Local child:TSetNode<T>=node.rightNode
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
	
	Method RotateRight( node:TSetNode<T> )
		Local child:TSetNode<T>=node.leftNode
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
	
	Method RepairAdd( node:TSetNode<T> )
		While node.parent And node.parent.colour=0 And node.parent.parent<>Null
			If node.parent = node.parent.parent.leftNode Then
				Local uncle:TSetNode<T>=node.parent.parent.rightNode
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
				Local uncle:TSetNode<T>=node.parent.parent.leftNode
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

	Method FindNode:TSetNode<T>( element:T )
		Local node:TSetNode<T>=root
		While node<>Null
			Local cmp:Int = DoCompare(element, node.element)

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

	Method FirstNode:TSetNode<T>()
		Local node:TSetNode<T> = root
		While node And node.leftNode
			node = node.leftNode
		Wend
		Return node
	End Method

	Method LastNode:TSetNode<T>()
		Local node:TSetNode<T> = root
		While node And node.rightNode
			node = node.rightNode
		Wend
		Return node
	End Method

	Method RemoveNode( node:TSetNode<T> )
		Local splice:TSetNode<T>
		Local child:TSetNode<T>
		
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
			node.element = splice.element
		EndIf
		
		Local parent:TSetNode<T> = splice.parent
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

	Method RepairRemove(node:TSetNode<T>, parent:TSetNode<T>)

		Function IsBlack:Int(n:TSetNode<T>) Inline
			' Null is black in RB-trees
			Return n = Null Or n.colour = 1
		End Function

		Function IsRed:Int(n:TSetNode<T>) Inline
			Return n <> Null And n.colour = 0
		End Function

		' node may be Null
		While node <> root And (node = Null Or node.colour = 1)
			Local leftBranch:Int = (parent <> Null And node = parent.leftNode)
			Local sib:TSetNode<T> = Null
			If leftBranch Then
				If parent <> Null Then
					sib = parent.rightNode
				End If
			Else
				If parent <> Null Then
					sib = parent.leftNode
				End If
			End If

			' red sibling
			If IsRed(sib) Then
				sib.colour = 1
				parent.colour = 0
				If leftBranch Then
					RotateLeft parent
					If parent <> Null Then
						sib = parent.rightNode
					End If
				Else
					RotateRight parent
					If parent <> Null Then
						sib = parent.leftNode
					End If
				End If
			End If

			' Now sibling is black (or Null)
			Local sibLeft:TSetNode<T> = Null
			Local sibRight:TSetNode<T> = Null
			If sib <> Null Then
				sibLeft = sib.leftNode
				sibRight = sib.rightNode
			End If

			If leftBranch Then
				' Case 2: both of sibling's children are black
				If IsBlack(sibLeft) And IsBlack(sibRight) Then
					If sib <> Null Then
						sib.colour = 0
					End If
					node = parent
					If parent <> Null Then
						parent = parent.parent
					End If
				Else
					' Case 3/4: ensure sibRight is red; if not, rotate at sib
					If IsBlack(sibRight) Then
						If sibLeft <> Null Then
							sibLeft.colour = 1
						End If
						If sib <> Null Then
							sib.colour = 0
						End If
						If sib <> Null Then
							RotateRight sib
						End If
						If parent <> Null Then
							sib = parent.rightNode
						End If
					End If
					' Final rotate at parent
					If sib <> Null Then
						sib.colour = parent.colour
					End If
					parent.colour = 1
					If sib <> Null And sib.rightNode <> Null Then
						sib.rightNode.colour = 1
					End If
					RotateLeft parent
					node = root
				End If
			Else
				' Mirror cases
				If IsBlack(sibRight) And IsBlack(sibLeft) Then
					If sib <> Null Then
						sib.colour = 0
					End If
					node = parent
					If parent <> Null Then
						parent = parent.parent
					End If
				Else
					If IsBlack(sibLeft) Then
						If sibRight <> Null Then
							sibRight.colour = 1
						End If
						If sib <> Null Then
							sib.colour = 0
						End If
						If sib <> Null Then
							RotateLeft sib
						End If
						If parent <> Null Then
							sib = parent.leftNode
						End If
					End If
					If sib <> Null Then
						sib.colour = parent.colour
					End If
					If sib <> Null Then
						sib.colour = parent.colour
					End If
					parent.colour = 1
					If sib <> Null And sib.leftNode <> Null Then
						sib.leftNode.colour = 1
					End If
					RotateRight parent
					node = root
				End If
			End If
		Wend

		' Repaint node black if non-null
		If node <> Null Then
			node.colour = 1
		End If
	End Method

	Method FindRange:TSetNode<T>(elementFrom:T, elementTo:T)
		Local currentNode:TSetNode<T> = root
		While currentNode
			Local cmp:Int = DoCompare(elementFrom, currentNode.element)
			
			If cmp > 0 Then
				currentNode = currentNode.NextNode()
			Else
				cmp = DoCompare(elementTo, currentNode.element)
				
				If cmp < 0 Then
					currentNode = currentNode.PreviousNode()
				Else
					Return currentNode
				End If
			End If
		Wend
		
		Return Null
	End Method
	
	Method CountUniqueAndMissingElements:SElementCount(other:IIterable<T>, exitIfMissing:Int)
		
		Local elementCount:SElementCount
		
		If Not size Then
			Local hasElements:Int
			For Local element:T = EachIn other
				hasElements = True
				Exit
			Next
			elementCount.missingCount = hasElements
			Return elementCount
		End If
		
		Local bitTest:TBitTest =  New TBitTest(size)
		Local missingCount:Int
		Local foundCount:Int
		
		For Local element:T = EachIn other
			Local index:Int = IndexOf(element)
			If index >= 0 Then
				If Not bitTest.IsMarked(index) Then
					bitTest.Mark(index)
					foundCount :+ 1
				End If
			Else
				missingCount :+ 1
				If exitIfMissing Then
					Exit
				End If
			End If
		Next
		
		elementCount.uniqueCount = foundCount
		elementCount.missingCount = missingCount
		
		Return elementCount
	End Method
	
	Method IndexOf:Int(element:T)
		Local currentNode:TSetNode<T> = root
		Local count:Int
		While currentNode
			Local cmp:Int = DoCompare(element, currentNode.element)
			
			If Not cmp Then
				Return count
			Else If cmp < 0 Then
				currentNode = currentNode.PreviousNode()
				count = 2 * count + 1
			Else
				currentNode = currentNode.NextNode()
				count = 2 * count + 2
			End If
		Wend
		
		Return -1
	End Method

	Method DoIsSubsetOf:Int(other:IIterable<T>, isProper:Int)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If

		If isProper Then
			If ICollection<T>(other) Then
				If Not size Then
					Return ICollection<T>(other).Count() > 0
				End If
			End If
		Else If Not size Then
			Return True
		End If
		
		Local otherSet:TSet<T> = TSet<T>(other)
		If otherSet Then
			If size > otherSet.size Then
				Return False
			End If

			Local prunedOther:TSet<T> = otherSet.ViewBetween(FirstNode().element, LastNode().element)
			For Local element:T = EachIn Self
				If Not prunedOther.Contains(element) Then
					Return False
				End If
			Next
			
			Return True
		Else
			Local elementCount:SElementCount = CountUniqueAndMissingElements(other, False)
			Return elementCount.uniqueCount = size And elementCount.missingCount >= 0
		End If
	End Method

	Method DoIsSupersetOf:Int(other:IIterable<T>, proper:Int)
		If Not other Then
			Throw New TArgumentNullException("other")
		End If

		If proper Then
			If Not size Then
				Return False
			End If
		Else
			If ICollection<T>(other) And Not ICollection<T>(other).Count() Then
				Return True
			End If
		End If
		
		Local set:TSet<T> = TSet<T>(other)
		If set Then
			If size < set.size Then
				Return False
			End If
			
			Local pruned:TSet<T> = ViewBetween(set.FirstNode().element, set.LastNode().element)
			For Local element:T = EachIn set
				If Not pruned.Contains(element) Then
					Return False
				End If
			Next
			Return True
		Else
			For Local element:T = EachIn other
				If Not Contains(element) Then
					Return False
				End If
			Next
			Return True
		End If
	End Method

	Method DoCompare:Int(elem1:T, elem2:T)
		If comparator Then
			Return comparator.Compare(elem1, elem2)
		Else
			Return DefaultComparator_Compare(elem1, elem2)
		End If
	End Method
	
	Method Sync()
	End Method
Public

	Method ToString:String()
	End Method
End Type

Type TSetNode<T>
Private
	Field parent:TSetNode
	Field leftNode:TSetNode
	Field rightNode:TSetNode
	Field colour:Int
Public
	Field element:T
	
	Method NextNode:TSetNode<T>()
		Local node:TSetNode<T> = Self
		If node.rightNode<>Null
			node=rightNode
			While node.leftNode <> Null
				node=node.leftNode
			Wend
			Return node
		EndIf
		Local parent:TSetNode<T>=parent
		While parent And node=parent.rightNode
			node=parent
			parent=parent.parent
		Wend
		Return parent
	End Method

	Method PreviousNode:TSetNode<T>()
		Local node:TSetNode<T> = Self
		If node.leftNode<>Null
			node=node.leftNode
			While node.rightNode <> Null
				node = node.rightNode
			Wend
			Return node
		EndIf
		Local parent:TSetNode<T> = node.parent
		While node = parent.leftNode
			node = parent
			parent = node.parent
		Wend
		Return parent
	End Method

End Type

Type TSetIterator<T> Implements IIterator<T> 
	Private
	Field initial:TSetNode<T>
	
	Method New(initial:TSetNode<T>)
		Self.initial = initial
	End Method
	
	Field node:TSetNode<T>

	Public

	Method Current:T()
		Return node.element
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

Type TSubSet<T> Extends TSet<T>
Private
	Field base:TSet<T>
	Field minimum:T
	Field maximum:T

	Method New(base:TSet<T>, minimum:T, maximum:T)
		New(base.comparator)
		Self.base = base
		Self.minimum = minimum
		Self.maximum = maximum
		root = base.FindRange(minimum, maximum)
		version = -1
		size = 0
		Sync()
	End Method

	Method FindNode:TSetNode<T>( element:T )
		If Not IsWithinRange(element) Then
			Return Null
		End If
		
		Sync()
		
		Return Super.FindNode(element)
	End Method

	Method FirstNode:TSetNode<T>()
		Sync()
		Return root
	End Method

	Method IsWithinRange:Int(element:T)
		Local cmp:Int = DoCompare(minimum, element)
		
		If cmp > 0 Then
			Return False
		End If
		
		cmp = DoCompare(maximum, element)
		
		If cmp < 0 Then
			Return False
		End If
		
		Return True
	End Method
	
	Method Sync()
		If version <> base.version Then

			root = base.FindRange(minimum, maximum)
			version = base.version
			size = 0
			
			For Local element:T = EachIn Self
				size :+ 1
			Next
		End If
	End Method
	
Public
	Method Add:Int(element:T)
		If Not IsWithinRange(element) Then
			Throw New TArgumentOutOfRangeException
		End If
	
		Local result:Int = base.Add(element)
		
		Sync()
		
		Return result
	End Method

	Method Count:Int()
		Sync()
		Return Super.Count()
	End Method

	Method GetIterator:IIterator<T>()
		Return New TSubSetIterator<T>(FirstNode(), Self)
	End Method
	
	Method ViewBetween:TSet<T>(lowerValue:T, upperValue:T)
		Local cmp:Int = DoCompare(minimum, lowerValue)
		
		If cmp > 0 Then
			Throw New TArgumentOutOfRangeException
		End If

		cmp = DoCompare(maximum, upperValue)

		If cmp < 0 Then
			Throw New TArgumentOutOfRangeException
		End If

		Return base.ViewBetween(lowerValue, upperValue)
	End Method

	Method Contains:Int(element:T)
		Sync()
		
		Return  Super.Contains(element)
	End Method
	
	Method Clear()
		If Not size Then
			Return
		End If
		
		Local list:TArrayList<T> = New TArrayList<T>
		For Local element:T = EachIn Self
			list.Add(element)
		Next
		
		While list.Count()
			base.Remove(list[list.Count() - 1])
			list.RemoveAt(list.Count() - 1)
		Wend
		
		root = Null
		size = 0
		version = base.version
	End Method
	
	Method Remove:Int(element:T)
		If Not IsWithinRange(element) Then
			Return False
		End If
		
		Local result:Int = base.Remove(element)
		Sync()
		
		Return result
	End Method

End Type

Type TSubSetIterator<T> Extends TSetIterator<T> 
	Private
	Field subset:TSubSet<T>
	
	Method New(initial:TSetNode<T>, subset:TSubSet<T>)
		Self.initial = initial
		Self.subset = subset
	End Method
	
	Public
	
	Method MoveNext:Int()
		If initial Then
			node = initial
			initial = Null
			Return True
		End If
		
		If node Then
			node = node.NextNode()
			If node And subset.IsWithinRange(node.element) Then
				Return True
			End If
		End If
		
		Return False
	End Method

End Type

Struct SElementCount
	Field uniqueCount:Int
	Field missingCount:Int
End Struct

Type TBitTest

	Field bits:Int[]
	Field count:Int

	Method New(count:Int)
		Self.count = count
		Local size:Int
		If count Then
			size = (count - 1) / 33
		End If
		bits = New Int[size]
	End Method

	Method Mark(bit:Int)
		Local index:Int = bit / 32
		If index < bits.length And index >= 0 Then
			bits[index] :| (1 Shl (bit Mod 32))
		End If
	End Method
	
	Method IsMarked:Int(bit:Int)
		Local index:Int = bit / 32
		If index < bits.length And index >= 0 Then
			Return bits[index] & (1 Shl (bit Mod 32))
		End If
		Return False
	End Method
	
End Type
