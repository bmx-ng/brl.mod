
'Make sure to have 'Threaded build' enabled!
'
SuperStrict

' a simple queue
Global queue:String[100],put:Int,get:Int

' a counter semaphore
Global counter:TSemaphore=CreateSemaphore( 0 )

Function MyThread:Object( data:Object )

	' process 100 items
	For Local item:Int = 1 To 100
	
		' add an item to the queue
		queue[put]="Item "+item
		put:+1
		
		' increment semaphore count.
		PostSemaphore counter
	
	Next
		
End Function

' create worker thread
Local thread:TThread=CreateThread( MyThread,Null )

' receive 100 items
For Local i:Int = 1 To 100

	' Wait for semaphore count to be non-0, then decrement.
	WaitSemaphore counter
	
	' Get an item from the queue
	Local item:String = queue[get]
	get:+1
	
	Print item

Next
