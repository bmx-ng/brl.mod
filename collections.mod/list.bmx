SuperStrict

Import "collection.bmx"
Import "queue.bmx"

Interface IListIterator<E> Extends IIterator<E>
	Method HasNext:Int()
	Method NextElement:E()
	Method HasPrevious:Int()
	Method PreviousElement:E()
	Method NextIndex:Int()
	Method PreviousIndex:Int()
	Method Remove()
	Method Set(element:E)
	Method Add(element:E)
End Interface


Interface IList<E> Extends ICollection<E>

	Method Get:E(index:Int)
	Method Set:E(index:Int, element:E)
	Method Add(index:Int, element:E)
	Method AddAll:Int(index:Int, c:ICollection<E>)
	Method RemoveElement:E(index:Int)
	Method ListIterator:IListIterator<E>()
	Method ListIterator:IListIterator<E>(index:Int)
	Method IndexOf:Int(element:E)
	Method LastIndexOf:Int(element:E)

End Interface

Type TAbstractList<E> Extends TAbstractCollection<E> Implements IList<E> Abstract

	Method Add:Int(element:E)
		Add(Size(), element)
		Return True
	End Method
	
	Method AddAll:Int(index:Int, c:ICollection<E>)
		If index < 0 Or index > Size() Then
			Throw New TIndexOutOfBoundsException
		End If

		Local isModified:Int = False
		Local i:IIterator<E> = c.Iterator()
		While i.HasNext()
			Add(index, i.NextElement())
			index :+ 1
			isModified = True
		Wend
		Return isModified
	End Method
	
	Method Clear()
		RemoveRange(0, Size())
	End Method
	
	Method Iterator:IIterator<E>()
		Return New TAbstractListIter<E>(Self)
	End Method
	
	Method ListIterator:IListIterator<E>()
		Return New TAbstractListListIter<E>(Self)
	End Method
	
	Method ListIterator:IListIterator<E>(index:Int)
		Return New TAbstractListListIter<E>(Self, index)
	End Method
	
	Method Set:E(index:Int, element:E)
		Throw New TUnsupportedOperationException
	End Method
	
	Method Add(index:Int, element:E)
		Throw New TUnsupportedOperationException
	End Method

	Method Remove:E(index:Int)
		Throw New TUnsupportedOperationException
	End Method
	
	Method IndexOf:Int(element:E)
		Local iterator:IListIterator<E> = ListIterator()
		If Not element Then
			While iterator.HasNext()
				If iterator.NextElement() = Null Then
					Return iterator.PreviousIndex()
				End If
			Wend
		Else
			While iterator.HasNext()
				If element = iterator.NextElement() Then
					Return iterator.PreviousIndex()
				End If
			Wend
		End If
		
		Return -1
	End Method
	
	Method LastIndexOf:Int(element:E)
		Local iterator:IListIterator<E> = ListIterator(Size())
		If Not element Then
			While iterator.HasPrevious()
				If iterator.PreviousElement() = Null Then
					Return iterator.NextIndex()
				End If
			Wend
		Else
			While iterator.HasPrevious()
				If element = iterator.PreviousElement() Then
					Return iterator.NextIndex()
				End If
			Wend
		End If
		
		Return -1
	End Method
	
	Method RemoveRange(indexFrom:Int, indexTo:Int)
		Local iter:IIterator<E> = ListIterator(indexFrom)
		Local n:Int = indexTo - indexFrom
		For Local i:Int = 0 Until n
			iter.NextElement()
			iter.Remove()
		Next
	End Method

	Type TAbstractListIter<E> Implements IIterator<E>
		Field index:Int
		Field lastReturned:Int = -1
		
		Field list:TAbstractList<E>
		
		Method New(list:TAbstractList<E>)
			Self.list = list
		End Method
		
		Method HasNext:Int()
			Return index <> list.Size()
		End Method
		
		Method NextElement:E()
			Local i:Int = index
			
			Local n:E = list.Get(i)
			lastReturned = i
			index = i + 1
			
			Return n
		End Method
		
		Method Remove()
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			list.Remove(lastReturned)
			
			If lastReturned < index Then
				index :- 1
			End If
			
			lastReturned = -1
		End Method
		
	End Type
	
	Type TAbstractListListIter<E> Extends TAbstractListIter<E> Implements IListIterator<E>
	
		Method New(list:TAbstractList<E>, index:Int)
			New(list)
			Self.index = index
		End Method
	
		Method HasPrevious:Int()
			Return index <> 0
		End Method
		
		Method PreviousElement:E()
			Local i:Int = index = 1
			Local previous:E = list.Get(i)
			lastReturned = i
			index = i
			Return previous
		End Method
		
		Method NextIndex:Int()
			Return index
		End Method
		
		Method PreviousIndex:Int()
			Return index - 1
		End Method
		
		Method Set(element:E)
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			list.Set(lastReturned, element)
		End Method
		
		Method Add(element:E)
			Local i:Int = index
			
			list.Add(i, element)
			lastReturned = -1
			
			index = i + 1
		End Method
	
	End Type

End Type


Type TArrayList<E> Extends TAbstractList<E> Implements IList<E>

	Private
	
	Field data:E[]
	Field count:Int
	
	Public

	Method New(initial:Int = 16)
		data = New E[initial]
	End Method

	Method Iterator:IIterator<E>()
		Return New TArrayListIter<E>(Self)
	End Method
	
	Method ListIterator:IListIterator<E>()
		Return New TArrayListListIter<E>(Self, 0)
	End Method

	Method ListIterator:IListIterator<E>(index:Int)
		Return New TArrayListListIter<E>(Self, index)
	End Method

	Method Size:Int()
		Return count
	End Method
	
	Method IsEmpty:Int()
		Return count = 0
	End Method

	Method ToArray:E[]()
		Return data[..count]
	End Method

	Method Add:Int(element:E)
		ResizeAsNeeded(count + 1)
		
		If count < data.length Then
			data[count] = element
			count :+ 1
		End If
	End Method
	
	Method Add(index:Int, element:E)
		If index < 0 Or index > count Then
			Throw New TIndexOutOfBoundsException
		End If

		ResizeAsNeeded(count + 1)
		
		ArrayCopy(data, index, data, index + 1, count - index)
		data[index] = element
		
		count :+ 1
	End Method

	Method Remove:Int(element:E)
		For Local i:Int = 0 Until count
			If data[i] = element Then
				Return True
			End If
		Next
		Return False
	End Method

	Method Contains:Int(element:E)
		For Local i:Int = 0 Until count
			If data[i] = element Then
				Return True
			End If
		Next
		Return False
	End Method
	
	Method AddAll:Int(c:ICollection<E>)
	
		ResizeAsNeeded(count + c.Size())
		
		For Local i:E = EachIn c.ToArray()
			Add(i)
		Next
	End Method
	
	Method AddAll:Int(a:E[])

		ResizeAsNeeded(count + a.length)
	
		For Local i:E = EachIn a
			Add(i)
		Next
	End Method
	
	Method AddAll:Int(index:Int, c:ICollection<E>)
		' TODO
	End Method

	Method RemoveAll:Int(c:ICollection<E>)
		' TODO
	End Method

	Method RetainAll:Int(c:ICollection<E>)
		' TODO
	End Method

	Method Clear()
		For Local i:Int = 0 Until count
			data[i] = Null
		Next
		count = 0
	End Method

	Method Equals:Int(o:Object)
		' TODO
	End Method

	Method Get:E(index:Int)
		If index >= count Then
			Throw New TIndexOutOfBoundsException
		End If
	
		Return data[index]
	End Method

	Method Set:E(index:Int, element:E)
		If index >= count Then
			Throw New TIndexOutOfBoundsException
		End If

		Local old:E = data[index]
		data[index] = element
		Return old
	End Method

	Method RemoveElement:E(index:Int)
		If index >= count Then
			Throw New TIndexOutOfBoundsException
		End If

		Local old:E = data[index]
		
		Local moveCount:Int = count - index - 1
		
		If moveCount > 0 Then
			ArrayCopy(data, index + 1, data, index, moveCount)
		End If
		
		count :- 1
		data[count] = Null
		
		Return old
	End Method

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

	Method TrimToSize()
		If count < data.Length Then
			data = data[..count]
		End If
	End Method
	
	Method IndexOf:Int(element:E)
		If Not element Then
			For Local i:Int = 0 Until count
				If data[i] = Null Then
					Return i
				End If
			Next
		Else
			For Local i:Int = 0 Until count
				If element = data[i] Then
					Return i
				End If
			Next
		End If
		Return -1
	End Method

	Method LastIndexOf:Int(element:E)
		If Not element Then
			Local i:Int = count - 1
			While i
				If data[i] = Null Then
					Return i
				End If
				i :- 1
			Wend
		Else
			Local i:Int = count - 1
			While i
				If element = data[i] Then
					Return i
				End If
				i :- 1
			Wend
		End If
		Return -1
	End Method

	Type TArrayListIter<E> Implements IIterator<E>
		Field index:Int
		Field lastReturned:Int = -1
		
		Field list:TArrayList<E>
		
		Method New(list:TArrayList<E>)
			Self.list = list
		End Method
		
		Method HasNext:Int()
			Return index <> list.count
		End Method
		
		Method NextElement:E()
			Local i:Int = index
			If index >= list.count Then
				Throw New TNoSuchElementException
			End If
			Local data:E[] = list.data
			If i >= data.length Then
				' throw error
			End If
			index = i + 1
			lastReturned = i
			Return data[lastReturned]
		End Method
		
		Method Remove()
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			list.RemoveElement(lastReturned)
			index = lastReturned
			lastReturned = -1
			
		End Method
		
	End Type
	
	
	
	Type TArrayListListIter<E> Extends TArrayListIter<E> Implements IListIterator<E>
	
		Method New(list:TArrayList<E>, index:Int)
			New(list)
			Self.index = index
		End Method
	
		Method HasPrevious:Int()
			Return index <> 0
		End Method
		
		Method PreviousElement:E()
			Local i:Int = index - 1
			If i < 0 Then
				Throw New TNoSuchElementException
			End If
			
			Local data:E[] = list.data
			
			index = i
			lastReturned = i
			Return data[i]
		End Method
		
		Method NextIndex:Int()
			Return index
		End Method
		
		Method PreviousIndex:Int()
			Return index - 1
		End Method
		
		Method Set(element:E)
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			list.Set(lastReturned, element)
		End Method
		
		Method Add(element:E)
			Local i:Int = index
			list.Add(i, element)
			index = i + 1
			lastReturned = -1
		End Method
		
	End Type
	

End Type

