SuperStrict

Import "collection.bmx"
?threaded
Import BRL.threads
Import BRL.Time
?

Rem
bbdoc: A first-in, first-out (FIFO) collection of elements.
about: Implements a queue as a circular array. Elements stored in a #TQueue are inserted at one end and removed from the other.
Use a #TQueue if you need to access the information in the same order that it is stored in the collection.
The capacity of a #TQueue is the number of elements the #TQueue can hold. As elements are added to a #TQueue, the capacity
is automatically increased as required by reallocating the internal array. The capacity can be decreased by calling #TrimExcess.
End Rem
Type TQueue<T> Implements ICollection<T>

Private
	Field initialCapacity:Int
	
	Field data:T[]
	Field head:Int
	Field tail:Int
	Field size:Int
	Field full:Int
Public

	Rem
	bbdoc: Creates a new #TQueue instance.
	End Rem
	Method New(initialCapacity:Int = 16)
		Self.initialCapacity = initialCapacity
		data = New T[initialCapacity]
	End Method

	Rem
	bbdoc: Creates a new #TQueue initialised by @array.
	End Rem
	Method New(array:T[])
		initialCapacity = 16
		If array Then
			initialCapacity = Max(initialCapacity, array.length)
		End If
		data = New T[initialCapacity]
		
		If array Then
			For Local element:T = EachIn array
				Enqueue(element)
			Next
		End If
	End Method

	Rem
	bbdoc: Creates a new #TQueue initialised by @iterable.
	End Rem
	Method New(iterable:IIterable<T>)
		New(16)
		If iterable Then
			For Local value:T = EachIn iterable
				Enqueue(value)
			Next
		End If
	End Method

	Rem
	bbdoc: Returns an iterator that iterates through the #TQueue.
	End Rem
	Method GetIterator:IIterator<T>()
		Return New TQueueIterator<T>(Self)
	End Method
	
	Rem
	bbdoc: Gets the number of elements contained in the #TQueue.
	End Rem
	Method Count:Int()
		Return size
	End Method

	Rem
	bbdoc: Returns #True if the #TQueue is empty, otherwise #False.
	End Rem
	Method IsEmpty:Int() Override
		Return size = 0
	End Method

	Method CopyTo(array:T[], index:Int = 0)
	End Method

	Rem
	bbdoc: Converts a #TQueue to an array.
	returns: An array of elements.
	End Rem
	Method ToArray:T[]()
		Local arr:T[size]
		
		Local i:Int
		For Local element:T = EachIn Self
			arr[i] = element
			i :+ 1
		Next
		
		Return arr
	End Method
	
	Rem
	bbdoc: Removes all elements from the #TQueue.
	End Rem
	Method Clear()
		If size Then
			Local index:Int = head
			Repeat
				data[index] = Null
				index :+ 1
				If index = data.length Then
					index = 0
				End If
			Until index = tail
			
			size = 0
			head = tail
		End If
	End Method
	
	Rem
	bbdoc: Determines whether an element is in the #TQueue.
	End Rem
	Method Contains:Int(element:T)
		If Not size Then
			Return False
		End If
		
		Local index:Int = head
		Repeat
			If element = data[index] Then
				Return True
			End If
			index :+ 1
			If index = data.length Then
				index = 0
			End If
		Until index = tail
		
		Return False
	End Method
	
	Rem
	bbdoc: Removes and returns the element at the beginning of the #TQueue.
	about: Similar to the #Peek method, but #Peek does not modify the #TQueue.
	End Rem
	Method Dequeue:T()
		If Not size Then
			Throw New TInvalidOperationException("The queue is empty")
		End If

		full = False

		Local element:T = data[head]
		head :+ 1
		
		size :- 1

		If head = data.length Then
			head = 0
		End If

		Return element
	End Method
	
	Rem
	bbdoc: Adds an element to the end of the #TQueue.
	about: If #Count already equals the capacity, the capacity of the #TQueue is increased by automatically reallocating
	the internal array, and the existing elements are copied to the new array before the new element is added.
	End Rem
	Method Enqueue(element:T)
		If full Then
			Resize()
		End If
		
		If Not full Then
			data[tail] = element
			tail :+ 1

			size :+ 1

			If tail = data.length Then
				tail = 0
			End If

			If tail = head Then
				full = True
			End If
		End If
	End Method
	
	Rem
	bbdoc: Returns the element at the beginning of the #TQueue without removing it.
	End Rem
	Method Peek:T()
		If Not size Then
			Throw New TInvalidOperationException("The queue is empty")
		End If
		
		Return data[head]
	End Method
	
	Rem
	bbdoc: Can be used to minimize a collection's memory overhead if no new elements will be added to the collection.
	End Rem
	Method TrimExcess()
		Local temp:T[]
		If Not size Then
			temp = temp[..initialCapacity]
		Else If size < data.length Then
			temp = temp[..size]
		End If

		Local tempIndex:Int
		Local dataIndex:Int = head
		Repeat
			temp[tempIndex] = data[dataIndex]
			dataIndex :+ 1
			If dataIndex = data.length Then
				dataIndex = 0
			End If
			tempIndex :+ 1
		Until dataIndex = tail

		head = 0
		data = temp
		tail = 0
		full = size > 0
	End Method
	
	Rem
	bbdoc: Tries to remove and return the element at the beginning of the #TQueue.
	returns: #True if an element was removed and returned from the beginning of the #TQueue successfully; otherwise, #False.
	about: When this method returns, if the operation was successful, @vlaue contains the element removed. If no element was available to be removed, the value is unspecified.
	End Rem
	Method TryDequeue:Int(value:T Var)
		If Not size Then
			Return False
		End If
		
		value = Dequeue()
		Return True
	End Method
	
	Rem
	bbdoc: Tries to return an element from the beginning of the #TQueue without removing it.
	returns: #True if an element was returned successfully; otherwise, #False.
	about: When this method returns, @value contains an element from the beginning of the #TQueue or an unspecified value if the operation failed.
	End Rem
	Method TryPeek:Int(value:T Var)
		If Not size Then
			Return False
		End If
		
		value = data[head]
		Return True
	End Method

	Private
	Method Resize()
		Local temp:T[] = New T[data.length * 2]
		Local tempIndex:Int
		Local dataIndex:Int = head
		Repeat
			temp[tempIndex] = data[dataIndex]
			dataIndex :+ 1
			If dataIndex = data.length Then
				dataIndex = 0
			End If
			tempIndex :+ 1
		Until dataIndex = tail
		
		head = 0
		tail = data.length
		data = temp
		full = False		
	End Method
	Public

End Type

Type TQueueIterator<T> Implements IIterator<T> 
	Private
	Field queue:TQueue<T>
	Field index:Int
	
	Method New(queue:TQueue<T>)
		Self.queue = queue
		index = queue.head - 1
	End Method
	
	Public

	Method Current:T()
		Return queue.data[index]
	End Method
	
	Method MoveNext:Int()
		If Not queue.size Then
			Return False
		End If

		index :+ 1
		
		If index = 0 Then
			Return True
		End If
		
		If index = queue.data.length Then
			index = 0
		End If
		
		Return index <> queue.tail
	End Method
End Type

?threaded

Rem
bbdoc: A thread-safe first-in, first-out (FIFO) collection of elements.
about: Implements a queue as a circular array. Elements stored in a #TBlockingQueue are inserted at one end and removed from the other.
Use a #TBlockingQueue if you need to access the information in the same order that it is stored in the collection and you need to ensure that the collection is thread-safe.
A call to #Dequeue will block if the queue is empty. A call to #Enqueue will block if the queue is full.
The capacity of a #TBlockingQueue is the number of elements the #TBlockingQueue can hold. Once the queue is full, any attempt to add an element will block until space is available.
End Rem
Type TBlockingQueue<T> Extends TQueue<T>

	Private
		Field lock:TMutex
		Field notEmpty:TCondVar
		Field notFull:TCondVar
	Public

	Method New(capacity:Int = 16)
		Super.New(capacity)
		lock = TMutex.Create()
		notEmpty = TCondVar.Create()
		notFull = TCondVar.Create()
	End Method
	
	Method Enqueue(element:T)
		lock.Lock()
		While full
			notFull.Wait(lock)
		Wend
		Super.Enqueue(element)
		notEmpty.Signal()
		lock.Unlock()
	End Method
	
	Rem
	bbdoc: Adds an element to the end of the #TBlockingQueue, waiting up to the specified wait time if necessary for space to become available
	about: If the queue is full, the operation will block until space becomes available or the specified timeout elapses.
	Throws a #TTimeoutException if the operation times out.
	End Rem
	Method Enqueue(element:T, timeout:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
		Local timeoutMs:ULong = TimeUnitToMillis(timeout, unit)
	
		Local startTime:ULong = CurrentUnixTime()
		lock.Lock()
		While full
			Local now:ULong = CurrentUnixTime()
			If timeout > 0 And now - startTime >= timeoutMs
				lock.Unlock()
				Throw New TTimeoutException("The operation timed out after " + timeoutMs + "ms")
			End If
			notFull.TimedWait(lock, Int(timeoutMs - (now - startTime)))
		Wend
		Super.Enqueue(element)
		notEmpty.Signal()
		lock.Unlock()
	End Method
	
	Rem
	bbdoc: Removes and returns the element at the beginning of the #TBlockingQueue, waiting up to the specified wait time if necessary for an element to become available.
	about: If the queue is empty, the operation will block until an element becomes available or the specified timeout elapses.
	Throws a #TTimeoutException if the operation times out.
	End Rem
	Method Dequeue:T(timeout:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
		Local timeoutMs:ULong = TimeUnitToMillis(timeout, unit)
	
		Local startTime:Long = CurrentUnixTime()
		lock.Lock()
		While IsEmpty()
			Local now:ULong = CurrentUnixTime()
			If timeout > 0 And now - startTime >= timeoutMs
				lock.Unlock()
				Throw New TTimeoutException("The operation timed out after " + timeoutMs + "ms")
			End If
			notEmpty.TimedWait(lock, Int(timeoutMs - (now - startTime)))
		Wend
		Local element:T = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return element
	End Method

	Method Dequeue:T()
		lock.Lock()
		While IsEmpty()
			notEmpty.Wait(lock)
		Wend
		Local element:T = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return element
	End Method
	
	Method TryDequeue:Int(value:T Var)
		lock.Lock()
		If IsEmpty()
			lock.Unlock()
			Return False
		End If
		value = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return True
	End Method
	
	Method TryPeek:Int(value:T Var)
		lock.Lock()
		If IsEmpty()
			lock.Unlock()
			Return False
		End If
		value = data[head]
		lock.Unlock()
		Return True
	End Method
	
	Method Clear()
		lock.Lock()
		Super.Clear()
		notFull.Signal()
		lock.Unlock()
	End Method
	
	Method TrimExcess()
		' noop since a blocking queue does not grow beyond its initial capacity
	End Method
	
	Method Resize()
		lock.Lock()
		Super.Resize()
		notFull.Signal()
		lock.Unlock()
	End Method
	
End Type

Rem
bbdoc: A thread-safe first-in, first-out (FIFO) collection of elements that supports the concept of tasks.
about: When a task is complete, the task should call the #TaskDone method to signal that the task is done.
End Rem
Type TBlockingTaskQueue<T> Extends TQueue<T>

	Private
		Field lock:TMutex
		Field notEmpty:TCondVar
		Field notFull:TCondVar
		Field allTasksDone:TCondVar
		Field taskLock:TMutex
		Field unfinishedTasks:Int
	Public

	Method New(capacity:Int = 16)
		Super.New(capacity)
		lock = TMutex.Create()
		notEmpty = TCondVar.Create()
		notFull = TCondVar.Create()
		allTasksDone = TCondVar.Create()
		taskLock = TMutex.Create()
		unfinishedTasks = 0
	End Method
	
	Method Enqueue(element:T)
		lock.Lock()
		While full
			notFull.Wait(lock)
		Wend
		Super.Enqueue(element)
		taskLock.Lock()
		unfinishedTasks :+ 1
		taskLock.Unlock()
		notEmpty.Signal()
		lock.Unlock()
	End Method
	
	Rem
	bbdoc: Adds an element to the end of the #TBlockingTaskQueue, waiting up to the specified wait time if necessary for space to become available
	about: If the queue is full, the operation will block until space becomes available or the specified timeout elapses.
	Throws a #TTimeoutException if the operation times out.
	End Rem
	Method Enqueue(element:T, timeout:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
		Local timeoutMs:ULong = TimeUnitToMillis(timeout, unit)
	
		Local startTime:ULong = CurrentUnixTime()
		lock.Lock()
		While full
			Local now:ULong = CurrentUnixTime()
			If timeout > 0 And now - startTime >= timeoutMs
				lock.Unlock()
				Throw New TTimeoutException("The operation timed out after " + timeoutMs + "ms")
			End If
			notFull.TimedWait(lock, Int(timeoutMs - (now - startTime)))
		Wend
		Super.Enqueue(element)
		taskLock.Lock()
		unfinishedTasks :+ 1
		taskLock.Unlock()
		notEmpty.Signal()
		lock.Unlock()
	End Method
	
	Rem
	bbdoc: Removes and returns the element at the beginning of the #TBlockingTaskQueue, waiting up to the specified wait time if necessary for an element to become available.
	about: If the queue is empty, the operation will block until an element becomes available or the specified timeout elapses.
	Throws a #TTimeoutException if the operation times out.
	End Rem
	Method Dequeue:T(timeout:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
		Local timeoutMs:ULong = TimeUnitToMillis(timeout, unit)
	
		Local startTime:Long = CurrentUnixTime()
		lock.Lock()
		While IsEmpty()
			Local now:ULong = CurrentUnixTime()
			If timeout > 0 And now - startTime >= timeoutMs
				lock.Unlock()
				Throw New TTimeoutException("The operation timed out after " + timeoutMs + "ms")
			End If
			notEmpty.TimedWait(lock, Int(timeoutMs - (now - startTime)))
		Wend
		Local element:T = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return element
	End Method

	Method Dequeue:T()
		lock.Lock()
		While IsEmpty()
			notEmpty.Wait(lock)
		Wend
		Local element:T = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return element
	End Method
	
	Method TryDequeue:Int(value:T Var)
		lock.Lock()
		If IsEmpty()
			lock.Unlock()
			Return False
		End If
		value = Super.Dequeue()
		notFull.Signal()
		lock.Unlock()
		Return True
	End Method
	
	Method TryPeek:Int(value:T Var)
		lock.Lock()
		If IsEmpty()
			lock.Unlock()
			Return False
		End If
		value = data[head]
		lock.Unlock()
		Return True
	End Method
	
	Method Clear()
		lock.Lock()
		Super.Clear()
		taskLock.Lock()
		unfinishedTasks = 0
		allTasksDone.Signal()
		taskLock.Unlock()
		notFull.Signal()
		lock.Unlock()
	End Method
	
	Method TrimExcess()
		' noop since a blocking queue does not grow beyond its initial capacity
	End Method
	
	Method Resize()
		lock.Lock()
		Super.Resize()
		notFull.Signal()
		lock.Unlock()
	End Method

	Rem
	bbdoc: Signals that a task is done.
	End Rem
	Method TaskDone()
		taskLock.Lock()
		If unfinishedTasks > 0 Then
			unfinishedTasks :- 1
			If unfinishedTasks = 0 Then
				allTasksDone.Signal()
			End If
		End If
		taskLock.Unlock()
	End Method

	Rem
	bbdoc: Waits until all tasks are done.
	End Rem
	Method Join()
		taskLock.Lock()
		While unfinishedTasks > 0
			allTasksDone.Wait(taskLock)
		Wend
		taskLock.Unlock()
	End Method
	
End Type
?