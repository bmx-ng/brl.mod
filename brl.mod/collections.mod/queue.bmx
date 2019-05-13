SuperStrict

Import "collection.bmx"

Rem
bbdoc: An ordered list of elements.
End Rem
Interface IQueue<E> Extends ICollection<E>

	Rem
	bbdoc: Adds @element to the queue.
	End Rem
	Method Add:Int(element:E)
	Rem
	bbdoc: Retrieves and removes the element at the head of the queue.
	End Rem
	Method Poll:E()
	Rem
	bbdoc: Retrieves the element at the head of the queue.
	End Rem
	Method Peek:E()	

End Interface

Rem
bbdoc: A double-ended queue (or deck).
End Rem
Interface IDeque<E> Extends IQueue<E>

	Method AddFirst(element:E)
	Method AddLast(element:E)
	Method RemoveFirst:E()
	Method RemoveLast:E()
	Method PollFirst:E()
	Method PollLast:E()
	Method PeekFirst:E()
	Method PeekLast:E()
	Method RemoveFirstOccurrence:Int(element:E)
	Method RemoveLastOccurrence:Int(element:E)
	Method Add:Int(element:E)
	Method Poll:E()
	Method Peek:E()
	Method Push(element:E)
	Method Pop:E()
	Method Remove:Int(element:E)
	Method Contains:Int(element:E)
	Method Size:Int()
	Method Iterator:IIterator<E>()
	Method DescendingIterator:IIterator<E>()

End Interface

Type TAbstractQueue<E> Extends TAbstractCollection<E> Implements IQueue<E> Abstract

	Method Clear()
		While Poll() <> Null
		Wend
	End Method

	Method AddAll:Int(c:ICollection<E>)
		' TODO
	End Method

End Type

Rem
bbdoc: A resizable array, implementing the IDeque interface.
about: The TArrayDeque has no capacity restriction, and grows as necessary.
End Rem
Type TArrayDeque<E> Extends TAbstractCollection<E> Implements IDeque<E>

	Private
	
	Field elements:E[]
	Field head:Int
	Field tail:Int
	
	Public
	
	Method New(initialCapacity:Int = 16)
		If initialCapacity <> 16 Then
			AllocateElements(initialCapacity)
		Else
			elements = New E[initialCapacity]
		End If
	End Method
	
	Method New(c:ICollection<E>)
		AllocateElements(c.Size())
		AddAll(c)
	End Method
	
	Private
	
	Method AllocateElements(count:Int)
		Local capacity:Int = 8
		
		If count >= capacity Then
			capacity = count
			capacity :| capacity Shr 1
			capacity :| capacity Shr 2
			capacity :| capacity Shr 4
			capacity :| capacity Shr 8
			capacity :| capacity Shr 16
			capacity :+ 1
			
			If capacity < 0 Then
				capacity :Shr 1
			End If
		End If
		
		elements = New E[capacity]
	End Method
	
	Method IncreaseCapacity()
		If head <> tail Then
			Return
		End If
		
		Local p:Int = head
		Local n:Int = elements.length
		Local r:Int = n - p

		Local capacity:Int = n Shl 1

		If capacity < 0 Then
			Throw New TIllegalStateException("No space to increase deque capacity")
		End If
		
		elements = elements[p..p+r] + elements[..p]
		elements = elements[..capacity]
		
		head = 0
		tail = n
	End Method
	
	Public
	
	Method DeleteElement:Int(index:Int)
		Local elements:E[] = Self.elements
		Local mask:Int = elements.length - 1
		Local h:Int = head
		Local t:Int = tail
		Local front:Int = (index - h) & mask
		Local back:Int = (t - index) & mask
		
		If front < back Then
			If h <= index Then
				' TODO
			Else
				' TODO
			End If
		
			elements[h] = Null
			head = (h + 1) & mask
			Return False
		Else
			' TODO
			Return True
		End If
		
	End Method

	Rem
	bbdoc: Adds @element to the front of the deque.
	End Rem
	Method AddFirst(element:E)
		head = (head - 1) & (elements.length - 1)
		elements[head] = element
		If head = tail Then
			IncreaseCapacity()
		End If
	End Method
	
	Rem
	bbdoc: Adds @element to the end of the deque.
	End Rem
	Method AddLast(element:E)
		elements[tail] = element
		tail = (tail + 1) & (elements.length - 1)
		If tail = head Then
			IncreaseCapacity()
		End If
	End Method

	Rem
	bbdoc: Retrieves and removes the first element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method RemoveFirst:E()
		Return PollFirst()
	End Method

	Rem
	bbdoc: Retrieves and removes the last element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method RemoveLast:E()
		Return PollLast()
	End Method

	Rem
	bbdoc: Retrieves and removes the first element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method PollFirst:E()
		If Not Size() Then
			Throw New TNoSuchElementException
		End If
	
		Local h:Int = head
		Local element:E = elements[h]
		
		elements[h] = Null
		head = (h + 1) & (elements.length - 1)
		
		Return element
	End Method

	Rem
	bbdoc: Retrieves and removes the last element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method PollLast:E()
		If Not Size() Then
			Throw New TNoSuchElementException
		End If

		Local t:Int = (tail - 1) & (elements.length - 1)
		Local element:E = elements[t]
		elements[t] = Null
		tail = t
		
		Return element
	End Method

	Rem
	bbdoc: Retrieves the first element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method PeekFirst:E()
		If Not Size() Then
			Throw New TNoSuchElementException
		End If
		Return elements[head]
	End Method

	Rem
	bbdoc: Retrieves the last element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method PeekLast:E()
		If Not Size() Then
			Throw New TNoSuchElementException
		End If
		Return elements[(tail - 1) & (elements.length - 1)]
	End Method

	Rem
	bbdoc: Removes the first occurrence of @element from the deque.
	returns: True if the deque contained @element.
	End Rem
	Method RemoveFirstOccurrence:Int(element:E)
		Local mask:Int = elements.length - 1
		Local index:Int = head
		
		While index <> tail
			If element = elements[index] Then
				DeleteElement(index)
				Return True
			End If
			
			index = (index + 1) & mask
		Wend
		
		Return False
	End Method

	Rem
	bbdoc: Removes the last occurrence of @element from the deque.
	returns: True if the deque contained @element.
	End Rem
	Method RemoveLastOccurrence:Int(element:E)
		Local mask:Int = elements.length - 1
		Local index:Int = (tail - 1) & mask
		
		While index <> tail
			If element = elements[index] Then
				DeleteElement(index)
				Return True
			End If
			
			index = (index - 1) & mask
		Wend
		
		Return False
	End Method

	Rem
	bbdoc: Adds @element to the end of the deque.
	End Rem
	Method Add:Int(element:E)
		AddLast(element)
		Return True
	End Method

	Rem
	bbdoc: Retrieves and removes the head element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method Poll:E()
		Return PollFirst()
	End Method

	Rem
	bbdoc: Retrieves the head element from the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method Peek:E()
		Return PeekFirst()
	End Method

	Rem
	bbdoc: Pushes @element onto the head of the stack represented by the deque.
	End Rem
	Method Push(element:E)
		AddFirst(element)
	End Method

	Rem
	bbdoc: Pops an element from the head of the stack represented by the deque.
	about: Throws TNoSuchElementException if empty.
	End Rem
	Method Pop:E()
		Return RemoveFirst()
	End Method

	Rem
	bbdoc: Removes the first occurrence of @element from the deque.
	End Rem
	Method Remove:Int(element:E)
		Return RemovefirstOccurrence(element)
	End Method

	Method Contains:Int(element:E)
		' TODO
	End Method

	Rem
	bbdoc: Returns the number of elements in the deque.
	End Rem
	Method Size:Int()
		Return (tail - head) & (elements.length - 1)
	End Method

	Method Iterator:IIterator<E>()
		Return New TArrayDequeIterator<E>(Self)
	End Method

	Method DescendingIterator:IIterator<E>()
		Return New TArrayDequeDescendingIterator<E>(Self)
	End Method

	Method Equals:Int(o:Object)
		' TODO
	End Method
	
	Method ToArray:E[]()
		Return elements[..] ' fixme
	End Method
	
	Rem
	bbdoc: Returns True if the deque is empty, or False otherwise.
	End Rem
	Method IsEmpty:Int()
		Return head = tail
	End Method
	
	Rem
	bbdoc: Clears out the contents of the deque.
	End Rem
	Method Clear()
		Local h:Int = head
		Local t:Int = tail
		If h <> t Then
			head = 0
			tail = 0
			Local index:Int = h
			Local mask:Int = elements.length - 1
			While index <> t
				elements[index] = Null
				index = (index + 1) & mask
			Wend
		End If
	End Method
	

	Type TArrayDequeIterator<E> Implements IIterator<E>
	
		Field position:Int
		Field last:Int
		Field lastReturned:Int = -1
		
		Field deque:TArrayDeque<E>
	
		Method New(deque:TArrayDeque<E>)
			Self.deque = deque
			position = deque.head
			last = deque.tail
		End Method
		
		Method HasNext:Int()
			Return position <> last
		End Method
		
		Method NextElement:E()
			If position = last Then
				Throw New TNoSuchElementException
			End If
			
			Local elements:E[] = deque.elements
			
			Local element:E = elements[position]
			' TODO handle mods
			
			lastReturned = position
			position = (position + 1) & (elements.length - 1)
			
			Return element
		End Method
		
		Method Remove()
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			If deque.DeleteElement(lastReturned) Then
				position = (position - 1) & (deque.elements.length - 1)
				last = deque.tail
			End If
			
			lastReturned = -1
		End Method
	
	End Type
	

	Type TArrayDequeDescendingIterator<E> Implements IIterator<E>

		Field position:Int
		Field last:Int
		Field lastReturned:Int = -1
		
		Field deque:TArrayDeque<E>
	
		Method New(deque:TArrayDeque<E>)
			Self.deque = deque
			position = deque.tail
			last = deque.head
		End Method
	
		Method HasNext:Int()
			Return position <> last
		End Method
		
		Method NextElement:E()
			If position = last Then
				Throw New TNoSuchElementException
			End If
			
			Local elements:E[] = deque.elements
			
			position = (position - 1) & (elements.length - 1)
	
			Local element:E = elements[position]
			
			' TODO handle mods
			
			lastReturned = position
			
			Return element
		End Method
		
		Method Remove()
			If lastReturned < 0 Then
				Throw New TIllegalStateException
			End If
			
			If deque.DeleteElement(lastReturned) Then
				position = (position + 1) & (deque.elements.length - 1)
				last = deque.head
			End If
			
			lastReturned = -1
		End Method
	
	End Type

End Type

