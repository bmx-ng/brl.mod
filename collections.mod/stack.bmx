SuperStrict

Import "collection.bmx"

Rem
bbdoc: A last-in-first-out (LIFO) stack of elements of the specified type. 
End Rem
Type TStack<T> Implements ICollection<T>

Private
	Field data:T[]
	Field size:Int
	Field initialCapacity:Int
Public

	Rem
	bbdoc: Creates a new #TStack.
	End Rem
	Method New(initialCapacity:Int = 16)
		Self.initialCapacity = 16
		data = New T[initialCapacity]
	End Method

	Rem
	bbdoc: Creates a new #TStack initialised by @array.
	End Rem
	Method New(array:T[])
		initialCapacity = 16
		If array Then
			initialCapacity = Max(initialCapacity, array.length)
		End If
		data = New T[initialCapacity]
		
		If array Then
			For Local element:T = EachIn array
				Push(element)
			Next
		End If
	End Method

	Rem
	bbdoc: Creates a new #TStack initialised by @iterable.
	End Rem
	Method New(iterable:IIterable<T>)
		New(16)
		If iterable Then
			For Local value:T = EachIn iterable
				Push(value)
			Next
		End If
	End Method

	Rem
	bbdoc: Returns an iterator for the #TStack.
	End Rem
	Method GetIterator:IIterator<T>()
		Return New TStackIterator<T>(Self)
	End Method

	Rem
	bbdoc: Gets the number of elements contained in the #TStack.
	about: The capacity of the #TStack is the number of elements that the #TStack can store. #Count is the number of
	elements that are actually in the #TStack.
	The capacity is always greater than or equal to #Count. If #Count exceeds the capacity while adding elements,
	the capacity is increased by automatically reallocating the internal array before copying the old elements and adding the new elements.
	End Rem
	Method Count:Int()
		Return size
	End Method
	
	Method CopyTo(array:T[], index:Int = 0)
	End Method

	Rem
	bbdoc: Removes all elements from the stack.
	about: #Count is set to zero, but the capacity remains unchanged. To reset the capacity of the #TStack, call #TrimExcess.
	End Rem
	Method Clear()
		For Local i:Int = 0 Until size
			data[i] = Null
		Next
		size = 0
	End Method
	
	Rem
	bbdoc: Determines whether an element is in the #TStack.
	returns: #True if element is found in the #TStack, otherwise #False.
	End Rem
	Method Contains:Int(element:T)
		For Local i:Int = 0 Until size
			If data[i] = element Then
				Return True
			End If
		Next
		Return False
	End Method
	
	Rem
	bbdoc: Returns the element at the top of the #TStack without removing it.
	returns: The element at the top of the #TStack.
	about: This method is similar to #Pop, but #Peek does not modify the #TStack.
	End Rem
	Method Peek:T()
		If Not size Then
			Throw New TInvalidOperationException("The stack is empty")
		End If
		
		Return data[size - 1]
	End Method
	
	Rem
	bbdoc: Removes and returns the element at the top of the #TStack.
	returns: The element removed from the top of the #TStack.
	about: This method is similar to #Peek, but #Peek does not modify the #TStack.
	End Rem
	Method Pop:T()
		If Not size Then
			Throw New TInvalidOperationException("The stack is empty")
		End If

		Local element:T = data[size - 1]
		data[size - 1] = Null
		size :- 1
		Return element
	End Method
	
	Rem
	bbdoc: Inserts an element at the top of the #TStack.
	about: If #Count already equals the capacity, the capacity of the #TStack is increased by automatically reallocating the internal array, 
	and the existing elements are copied to the new array before the new element is added.
	End Rem
	Method Push(element:T)
		If size = data.length Then
			ResizeAsNeeded(size + 1)
		End If
		
		data[size] = element
		
		size :+ 1
	End Method

	Rem
	bbdoc: Converts a #TStack to an array.
	returns: An array of elements.
	End Rem
	Method ToArray:T[]()
		Local arr:T[size]
			
		For Local i:Int = 0 Until size
			arr[i] = data[size - i - 1]
		Next
		
		Return arr
	End Method
	
	Rem
	bbdoc: Can be used to minimize a collection's memory overhead if no new elements will be added to the collection.
	about: To reset a #TStack to its initial state, call the #Clear method before calling #TrimExcess.
	Trimming an empty #TStack sets the capacity of the #TStack to the default capacity.
	End Rem
	Method TrimExcess()
		If Not size Then
			data = data[..initialCapacity]
		Else If size < data.length Then
			data = data[..size]
		End If
	End Method
	
	Rem
	bbdoc: Tries to return an element from the top of the #TStack without removing it.
	returns: #True if an element was returned successfully; otherwise, #False.
	End Rem
	Method TryPeek:Int(value:T Var)
		If Not size Then
			Return False
		End If
		
		value = Peek()
		Return True
	End Method
	
	Rem
	bbdoc: Tries to remove and return an element from the top of the #TStack.
	returns: #True if an element was removed and returned from the top of the #TStack successfully; otherwise, #False.
	End Rem
	Method TryPop:Int(value:T Var)
		If Not size Then
			Return False
		End If

		value = Pop()
		Return True
	End Method
	
	Private
	Method ResizeAsNeeded(minCapacity:Int)
		Local capacity:Int = data.length
		If minCapacity > capacity Then
			Local newCapacity:Int = (capacity * 3) / 2 + 1
			If newCapacity < minCapacity Then
				newCapacity = minCapacity
			End If
			data = data[..newCapacity]
		End If
	End Method
	Public
End Type

Type TStackIterator<T> Implements IIterator<T> 
	Private
	Field stack:TStack<T>
	Field index:Int
	
	Method New(stack:TStack<T>)
		Self.stack = stack
		index = stack.size
	End Method
	
	Public

	Method Current:T()
		Return stack.data[index]
	End Method
	
	Method MoveNext:Int()
		If Not stack.size Then
			Return False
		End If

		index :- 1
	
		Return index >= 0
	End Method
End Type