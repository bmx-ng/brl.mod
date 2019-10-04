SuperStrict

Import "collection.bmx"
Import "errors.bmx"
Import "sort.bmx"

Interface IList<T> Extends ICollection<T>

	Method Add(element:T)
	Method Clear()
	Method Contains:Int(element:T)
	Method IndexOf:Int(element:T)
	Method Insert(index:Int, element:T)
	Method Remove(element:T)
	Method RemoveAt(index:Int)

End Interface


Rem
bbdoc: Represents a collection of elements that can be individually accessed by index.
End Rem
Type TArrayList<T> Implements IList<T>

Private
	Field data:T[]
	Field size:Int
	Field initialCapacity:Int
Public

	Rem
	bbdoc: Creates a new TArrayList
	End Rem
	Method New(initialCapacity:Int = 16)
		Self.initialCapacity = initialCapacity
		data = New T[initialCapacity]
	End Method

	Rem
	bbdoc: Creates a new #TArrayList initialised by @array.
	End Rem
	Method New(array:T[])
		initialCapacity = 16
		If array Then
			initialCapacity = Max(initialCapacity, array.length)
		End If
		data = New T[initialCapacity]
		
		If data Then
			For Local element:T = EachIn array
				Add(element)
			Next
		End If
	End Method

	Rem
	bbdoc: Creates a new #TArrayList initialised by @iterable.
	End Rem
	Method New(iterable:IIterable<T>)
		New(16)
		If iterable Then
			For Local value:T = EachIn iterable
				Add(value)
			Next
		End If
	End Method

	Rem
	bbdoc: Returns an iterator that iterates through the #TList.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TArrayListIterator<T>(Self)
	End Method
	
	Rem
	bbdoc: Gets the number of elements contained in the #TArrayList.
	End Rem
	Method Count:Int() Override
		Return size
	End Method

	Rem
	bbdoc: Returns #True if the #TArrayList is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int() Override
		Return size = 0
	End Method
	
	Rem
	bbdoc: Gets the total number of elements the internal data structure can hold without resizing.
	about: #Capacity is the number of elements that the #TArrayList can store before resizing is required, whereas #Count is
	the number of elements that are actually in the #TArrayList.
	End Rem
	Method Capacity:Int()
		Return data.length
	End Method
	
	Rem
	bbdoc: Sets the total number of elements the internal data structure can hold without resizing.
	about: #Capacity is the number of elements that the #TArrayList can store before resizing is required, whereas #Count is
	the number of elements that are actually in the #TArrayList.
	End Rem
	Method SetCapacity(value:Int)
		If value < data.length Then
			Throw New TArgumentOutOfRangeException
		End If
		
		data = data[..value]
	End Method
	
	Method CopyTo(array:T[], index:Int = 0) Override
		' TODO
	End Method
	
	Rem
	bbdoc: Adds an element to the end of the #TArrayList.
	End Rem
	Method Add(element:T) Override
		ResizeAsNeeded(size + 1)
		data[size] = element
		size :+ 1
	End Method
	
	Rem
	bbdoc: Removes all elements from the #TArrayList.
	End Rem
	Method Clear() Override
		For Local i:Int = 0 Until size
			data[i] = Null
		Next
		size = 0
	End Method
	
	Rem
	bbdoc: Determines whether an element is in the #TArrayList.
	End Rem
	Method Contains:Int(element:T) Override
		Return IndexOf(element) >= 0
	End Method
	
	Rem
	bbdoc: Returns the zero-based index of the first occurrence of a value in the #List.
	End Rem
	Method IndexOf:Int(element:T) Override
		For Local i:Int = 0 Until size
			If data[i] = element Then
				Return i
			End If
		Next
		Return -1
	End Method
	
	Rem
	bbdoc: Returns the zero-based index of the first occurrence of a value in a portion of the #TArrayList.
	End Rem
	Method IndexOf:Int(element:T, index:Int)
		If index < 0 Or index >= size Then
			Throw New TIndexOutOfBoundsException
		End If

		For Local i:Int = index Until size
			If data[i] = element Then
				Return i
			End If
		Next
		Return -1
	End Method
	
	Rem
	bbdoc: Returns the zero-based index of the first occurrence of a value in a portion of the #TArrayList.
	End Rem
	Method IndexOf:Int(element:T, index:Int, count:Int)
		If index < 0 Or index >= size Or count < 0 Or index + count > size Then
			Throw New TIndexOutOfBoundsException
		End If

		For Local i:Int = index Until index + count
			If data[i] = element Then
				Return i
			End If
		Next
		Return -1
		
	End Method
	
	Rem
	bbdoc: Inserts an element into the #TArrayList at the specified index.
	End Rem
	Method Insert(index:Int, element:T) Override
		If index < 0 Or index > size Then
			Throw New TIndexOutOfBoundsException
		End If

		ResizeAsNeeded(size + 1)
		
		ArrayCopy(data, index, data, index + 1, size - index)
		data[index] = element
		
		size :+ 1
	End Method
	
	Rem
	bbdoc: Returns the zero-based index of the last occurrence of a value in the #TArrayList.
	End Rem
	Method LastIndexOf:Int(element:T)
		Local i:Int = size - 1
		While i >= 0
			If data[i] = element Then
				Return i
			End If
			i :- 1
		Wend
		
		Return -1
	End Method

	Rem
	bbdoc: Returns the zero-based index of the last occurrence of a value in a portion of the #TArrayList.
	End Rem
	Method LastIndexOf:Int(element:T, index:Int)
		If index < 0 Or index >= size Then
			Throw New TIndexOutOfBoundsException
		End If

		Local i:Int = index
		While i >= 0
			If data[i] = element Then
				Return i
			End If
			i :- 1
		Wend
		
		Return -1
	End Method

	Rem
	bbdoc: Returns the zero-based index of the last occurrence of a value in a portion of the #TArrayList.
	End Rem
	Method LastIndexOf:Int(element:T, index:Int, count:Int)
		If index < 0 Or index >= size Or count < 0 Or index - count < -1 Then
			Throw New TIndexOutOfBoundsException
		End If

		Local i:Int = index
		While i >= 0 And count > 0
			If data[i] = element Then
				Return i
			End If
			i :- 1
			count :- 1
		Wend
		
		Return -1
	End Method
	
	Rem
	bbdoc: Removes the first occurrence of a specific element from the #TArrayList.
	End Rem
	Method Remove(element:T) Override
		Local index:Int = IndexOf(element)
		If index >= 0 Then
			RemoveAt(index)
		End If
	End Method

	Rem
	bbdoc: Removes the element at the specified index of the #TArrayList.
	End Rem
	Method RemoveAt(index:Int) Override
		If index < 0 Or index >= size Then
			Throw New TIndexOutOfBoundsException
		End If

		Local moveCount:Int = size - index - 1
		
		If moveCount > 0 Then
			ArrayCopy(data, index + 1, data, index, moveCount)
		End If
		
		size :- 1
		data[size] = Null
	End Method
	
	Rem
	bbdoc: Sorts the elements in the entire #TArrayList using the specified comparator, or the default if #Null.
	End Rem
	Method Sort(comparator:IComparator<T> = Null)
		' nothing to sort
		If size < 2 Then
			Return
		End If
		
		Local depth:Int
		Local n:Int = size
		While n >= 1
			depth :+ 1
			n = n / 2
		Wend
		
		depth :* 2
		
		If comparator Then
			New TComparatorArraySort<T>(comparator).Sort(data, 0, size - 1, depth)
		Else
			New TArraySort<T>().Sort(data, 0, size - 1, depth)
		End If
	End Method
	
	Rem
	bbdoc: Converts a #TArrayList to an array.
	returns: An array of elements.
	End Rem
	Method ToArray:T[]()
		Local arr:T[size]
			
		ArrayCopy(data, 0, arr, 0, size)
		
		Return arr
	End Method

	Rem
	bbdoc: Sets the capacity to the actual number of elements in the #TArrayList.
	about: This method can be used to minimize a collection's memory overhead if no new elements will be added to the collection. 
	End Rem
	Method TrimExcess()
		If size = 0 Then
			data = data[..initialCapacity]
		Else If size < data.length Then
			data = data[..size]
		End If
	End Method
	
	Rem
	bbdoc: Gets the element at the specified index.
	End Rem
	Method Operator [] :T(index:Int)
		If index < 0 Or index >= size Then
			Throw New TIndexOutOfBoundsException
		End If

		Return data[index]
	End Method

	Rem
	bbdoc: Sets the element at the specified index.
	End Rem
	Method Operator []= (index:Int, value:T)
		If index < 0 Or index >= size Then
			Throw New TIndexOutOfBoundsException
		End If

		data[index] = value
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


Type TArrayListIterator<T> Implements IIterator<T> 
	Private
	Field list:TArrayList<T>
	Field index:Int = -1
	
	Method New(list:TArrayList<T>)
		Self.list = list
	End Method
	
	Public

	Method Current:T() Override
		Return list[index]
	End Method
	
	Method MoveNext:Int() Override
		index :+ 1
		Return index < list.size
	End Method
End Type
