SuperStrict

Framework brl.standardio
Import brl.maxunit
Import brl.collections


New TTestSuite.run()

Type TQueueTest Extends TTest

	Method TestEnqueueDequeue() { test }
		Local queue:TQueue<Int> = New TQueue<Int>
		
		Local value:Int
		Local count:Int
		For Local i:Int = 0 Until 10
			queue.Enqueue(i)
			assertEquals(value, queue.Peek())
			count :+ 1
			assertEquals(count, queue.size)
		Next
		
		For Local i:Int = 0 Until 10
			assertEquals(count, queue.size)
			assertEquals(value, queue.Peek())
			
			assertEquals(value, queue.Dequeue())
			count :- 1
			value :+ 1

			assertEquals(count, queue.size)
		Next
		
		assertEquals(0, queue.size)
		assertTrue(queue.head = queue.tail)
	
	End Method

	Method TestClear() { test }
		Local queue:TQueue<Int> = New TQueue<Int>

		Local value:Int
		Local count:Int
		For Local i:Int = 0 Until 10
			queue.Enqueue(i)
			count :+ 1
		Next
		
		queue.Clear()
		assertEquals(0, queue.size)
		assertTrue(queue.head = queue.tail)
		
	End Method

End Type
