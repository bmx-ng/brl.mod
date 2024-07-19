' Copyright (c)2019 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
'
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
'
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
'
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
'
'    3. This notice may not be removed or altered from any source
'    distribution.
'
SuperStrict

Rem
bbdoc: System/ThreadPool 
End Rem
Module BRL.ThreadPool

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Added scheduled pool executor"
ModuleInfo "History: 1.01"
ModuleInfo "History: Added cached pool executor"
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

?threaded

Import BRL.Threads
Import BRL.LinkedList
Import BRL.Time
Import pub.stdc

Rem
bbdoc: An object that is intended to be executed by a thread pool.
End Rem
Type TRunnable Abstract

	Rem
	bbdoc: Called when the object is executed by the thread pool.
	End Rem
	Method run() Abstract

End Type


Type TExecutor Abstract

	Method execute(command:TRunnable) Abstract

End Type

Rem
bbdoc: An executor that executes each submitted task using one of possibly several pooled threads.
End Rem
Type TThreadPoolExecutor Extends TExecutor

	Field keepThreadsAlive:Int
	Field isShutdown:Int

	Field threadCount:Int
	Field maxThreads:Int

	Field threads:TList
	Field threadsLock:TMutex
	Field jobQueue:TJobQueue
	
	Field threadsAlive:Int
	Field threadsWorking:Int
	
	Field countLock:TMutex
	Field threadsIdle:TCondVar
	
	Field maxIdleWait:Int
	
	Rem
	bbdoc: 
	End Rem
	Method New(initial:Int, idleWait:Int = 0)
		maxThreads = initial
		maxIdleWait = idleWait
		
		threadsLock = TMutex.Create()
		jobQueue = New TJobQueue
		
		countLock = TMutex.Create()
		threadsIdle = TCondVar.Create()
		
		threads = New TList
		
		keepThreadsAlive = True
		
		' initialise threads
		If maxThreads > 0 Then
		
			For threadCount = 0 Until maxThreads
				threads.AddLast(New TPooledThread(Self, _processThread))
			Next
		
		End If
	End Method
	
	' thread callback
	Function _processThread:Object( data:Object)
		Local thread:TPooledThread = TPooledThread(data)
		Local pool:TThreadPoolExecutor = thread.pool
		
		Return pool.processThread(thread)
	End Function
	
	Method processThread:Object(thread:TPooledThread)

		countLock.Lock()
		threadsAlive :+ 1
		countLock.Unlock()
		
		While keepThreadsAlive
		
			If maxIdleWait Then
				If jobQueue.TimedWait(maxIdleWait) = 1 Then
					Exit
				End If
			Else
				jobQueue.Wait()
			End If
		
			If keepThreadsAlive Then
			
				countLock.Lock()
				threadsWorking :+ 1
				countLock.Unlock()
				
				jobQueue.Lock()
				Local job:TRunnable = jobQueue.Remove()
				jobQueue.Unlock()
				
				If job Then
				
					job.run()
				
				End If
				
				countLock.Lock()
				threadsWorking :- 1
				
				If Not threadsWorking Then
					threadsIdle.Signal()
				End If
				
				countLock.Unlock()
			
			End If
		
		Wend

		countLock.Lock()
		threadsAlive :- 1
		countLock.Unlock()
		
		threadsLock.Lock()
		threads.Remove(thread)
		threadsLock.Unlock()

		Return Null
	End Method
	

	Rem
	bbdoc: Executes the given command at some time in the future.
	End Rem
	Method execute(command:TRunnable) Override
		If Not isShutdown Then
			doExecute(command)
		End If
	End Method

Private
	Method doExecute(command:TRunnable)
		If maxThreads < 0 Then
			Local newThread:Int
			countLock.Lock()
			If threadsWorking = threadsAlive Then
				newThread = True
			End If
			countLock.Unlock()
			If newThread Then
				threadsLock.Lock()
				threads.AddLast(New TPooledThread(Self, _processThread))
				threadsLock.Unlock()
			End If
		End If
		jobQueue.Lock()
		jobQueue.Add(command)
		jobQueue.Unlock()
	End Method
Public

	Rem
	bbdoc: Creates an executor that uses a single worker thread operating off an unbounded queue.
	End Rem
	Function newSingleThreadExecutor:TThreadPoolExecutor()
		Return New TThreadPoolExecutor(1)
	End Function
	
	Rem
	bbdoc: Creates a thread pool that reuses a fixed number of threads operating off a shared unbounded queue.
	about: At any point, at most @threads threads will be active processing tasks. If additional tasks are
	submitted when all threads are active, they will wait in the queue until a thread is available.
	End Rem
	Function newFixedThreadPool:TThreadPoolExecutor(threads:Int)
		Assert threads > 0
		Return New TThreadPoolExecutor(threads)
	End Function
	
	Rem
	bbdoc: 
	End Rem
	Function newCachedThreadPool:TThreadPoolExecutor(idleWait:Int = 60000)
		Return New TThreadPoolExecutor(-1, idleWait)
	End Function

	Rem
	bbdoc: Initiates an orderly shutdown in which previously submitted tasks are executed, but no new tasks will be accepted.
	End Rem
	Method shutdown()

		isShutdown = True
		Local threadsTotal:Int = threadsAlive
	
		' wait for queued jobs to be processed
		While Not jobQueue.jobs.IsEmpty()
			Delay 100
		Wend
	
	
		' threads can shutdown now
		keepThreadsAlive = False
		
		' remove idle threads
		Local time:Int = MilliSecs() & $7FFFFFFF
		Local waiting:Int = 0
		
		While waiting < 1000 And threadsAlive
			jobQueue.PostAll()
			waiting = (MilliSecs() & $7FFFFFFF) - time
		Wend
		
		' poll remaining threads
		While threadsAlive
			jobQueue.PostAll()
			Delay 10
		Wend
		
		' clear down threads
		For Local thread:TPooledThread = EachIn threads
			thread.pool = Null
		Next
		threads.Clear()

	End Method
	
	Rem
	bbdoc: Returns the approximate number of threads that are actively executing tasks.
	end rem
	Method getActiveCount:Int()
		countLock.Lock()
		Local count:Int = threadsWorking
		countLock.unlock()
		return count
	End Method
	
	Method IsQueueEmpty:Int()
		return jobQueue.IsEmpty()
	end method
End Type

Rem
bbdoc: An executor that can be used to schedule commands to run after a given delay, or to execute commands periodically.
End Rem
Type TScheduledThreadPoolExecutor Extends TThreadPoolExecutor

	Field tasks:TScheduledTask

	Field taskMutex:TMutex
	Field taskCond:TCondVar

	Field schedulerThread:TThread

	Method New(initial:Int, idleWait:Int = 0)
		Super.New(initial, idleWait)
		taskMutex = TMutex.Create()
		taskCond = TCondVar.Create()

		schedulerThread = CreateThread(taskScheduler, Self)
	End Method

	Method schedule(command:TRunnable, delay_:Int, unit:ETimeUnit = ETimeUnit.Milliseconds)
		schedule(command, ULong(delay_), 0, unit)
	End Method

	Method schedule(command:TRunnable, initialDelay:Int, period:Int, unit:ETimeUnit = ETimeUnit.Milliseconds)
		schedule(command, ULong(initialDelay), ULong(period), unit)
	End Method
	
	Rem
	bbdoc: Schedules a one-shot command to run after a given delay.
	End Rem
	Method schedule(command:TRunnable, delay_:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
		schedule(command, delay_, 0, unit)
	End Method

	Rem
	bbdoc: Schedules a recurring command to run after a given initial delay, and subsequently with the given period.
	End Rem
	Method schedule(command:TRunnable, initialDelay:ULong, period:ULong, unit:ETimeUnit = ETimeUnit.Milliseconds)
			Local now:ULong = CurrentUnixTime()

		Local newTask:TScheduledTask = New TScheduledTask

		Local delayMs:ULong = initialDelay
		Local periodMs:ULong = period
		Select unit
			Case ETimeUnit.Seconds
				delayMs :* 1000
				periodMs :* 1000
			Case ETimeUnit.Minutes
				delayMs :* 60000
				periodMs :* 60000
			Case ETimeUnit.Hours
				delayMs :* 3600000
				periodMs :* 3600000
			Case ETimeUnit.Days
				delayMs :* 86400000
				periodMs :* 86400000
		End Select

		newTask.executeAt = now + delayMs
		newTask.intervalMs = periodMs
		newTask.command = command
		
		taskMutex.Lock()
		
		insertTask(newTask)

		taskMutex.Unlock()
		
	End Method

	Rem
	bbdoc: Initiates an orderly shutdown in which previously submitted tasks are executed, but no new tasks will be accepted.
	End Rem
	Method shutdown() Override
		isShutdown = True
		schedulerThread.Wait()
		Super.shutdown()
	End Method

Private
	Method insertTask(newTask:TScheduledTask)
		Local headChanged:Int = False
		If Not tasks Or newTask.executeAt < tasks.executeAt Then
			newTask.nextTask = tasks
			tasks = newTask
			headChanged = True
		Else
			Local current:TScheduledTask = tasks
			While current.nextTask And current.nextTask.executeAt < newTask.executeAt
				current = current.nextTask
			Wend
			newTask.nextTask = current.nextTask
			current.nextTask = newTask
		End If

		If headChanged Then
			taskCond.Signal()
		End If
	End Method

	Function taskScheduler:Object( data:Object )
		Local exec:TScheduledThreadPoolExecutor = TScheduledThreadPoolExecutor(data)

		While True

			exec.taskMutex.Lock()

			While Not exec.tasks
				
				If exec.isShutdown Then
					exec.taskMutex.Unlock()
					Return Null
				End If

				exec.taskCond.Wait(exec.taskMutex)
			Wend

			Local now:ULong = CurrentUnixTime()

			If now < exec.tasks.executeAt Then
				' Wait until the next task is due or a new task is scheduled
				exec.taskCond.TimedWait(exec.taskMutex, Int(exec.tasks.executeAt - now))
			End If

			now = CurrentUnixTime()

			While exec.tasks And exec.tasks.executeAt <= now
				Local task:TScheduledTask = exec.tasks

				exec.doExecute(task.command)

				If task.intervalMs And Not exec.isShutdown Then
					' If the task is recurring, reschedule it, unless the executor is shutting down
					task.executeAt = now + task.intervalMs
					exec.tasks = task.nextTask
					exec.insertTask(task)
				Else
					' Otherwise, remove it from the list
					exec.tasks = task.nextTask
				End If
			Wend

			exec.taskMutex.Unlock()
		Wend
	End Function
Public

Rem
	bbdoc: Creates an executor that uses a single worker thread operating off an unbounded queue.
	End Rem
	Function newSingleThreadExecutor:TScheduledThreadPoolExecutor()
		Return New TScheduledThreadPoolExecutor(1)
	End Function
	
	Rem
	bbdoc: Creates a thread pool that reuses a fixed number of threads operating off a shared unbounded queue.
	about: At any point, at most @threads threads will be active processing tasks. If additional tasks are
	submitted when all threads are active, they will wait in the queue until a thread is available.
	End Rem
	Function newFixedThreadPool:TScheduledThreadPoolExecutor(threads:Int)
		Assert threads > 0
		Return New TScheduledThreadPoolExecutor(threads)
	End Function
	
	Rem
	bbdoc: Creates a thread pool that creates new threads as needed, but will reuse previously constructed threads when they are available.
	about: These pools will typically improve the performance of programs that execute many short-lived asynchronous tasks.
	Threads that remain idle for more than the specified @idleWait time will be terminated and removed from the pool.
	End Rem
	Function newCachedThreadPool:TScheduledThreadPoolExecutor(idleWait:Int = 60000)
		Return New TScheduledThreadPoolExecutor(-1, idleWait)
	End Function
End Type

Type TScheduledTask
	Field executeAt:Long ' the time to execute the task, in ms since the epoch
	Field command:TRunnable
	
	Field intervalMs:ULong ' zero for one-shot tasks

	Field nextTask:TScheduledTask
End Type

Private

Type TBinarySemaphore

	Field mutex:TMutex
	Field cond:TCondVar
	Field value:Int
	
	Method New(value:Int)
		Init(value)
	End Method
	
	Method Init(value:Int)
		If value = 0 Or value = 1 Then
			mutex = TMutex.Create()
			cond = TCondVar.Create()
			Self.value = value
		End If
	End Method
	
	Method Wait()
		mutex.lock()
		While value <> 1
			cond.Wait(mutex)
		Wend
		value = 0
		mutex.Unlock()
	End Method

	Method TimedWait:Int(millis:Int)
		mutex.lock()
		While value <> 1
			Local res:Int = cond.TimedWait(mutex, millis)
			If res = 1 Then
				value = 0
				mutex.Unlock()
				Return res
			End If
		Wend
		value = 0
		mutex.Unlock()
	End Method
	
	Method Post()
		mutex.Lock()
		value = 1
		cond.Signal()
		mutex.Unlock()
	End Method
	
	Method PostAll()
		mutex.Lock()
		value = 1
		cond.Broadcast()
		mutex.Unlock()
	End Method
	
	Method Reset()
		cond.Close()
		mutex.Close()
		Init(0)
	End Method

End Type

Type TJobQueue

	Field mutex:TMutex
	Field hasJobs:TBinarySemaphore
	
	Field jobs:TList

	Method New()
		hasJobs = New TBinarySemaphore(0)
		mutex = TMutex.Create()
		jobs = New TList
	End Method
	
	Method Add(job:TRunnable)
		jobs.AddLast(job)
		hasJobs.Post()
	End Method
	
	Method Remove:TRunnable()
		Local job:TRunnable
		
		If Not jobs.IsEmpty() Then
			job = TRunnable(jobs.RemoveFirst())
			hasJobs.Post()
		End If
		
		Return job
	End Method

	Method IsEmpty:Int()
		Lock()
		Local empty:Int = jobs.IsEmpty()
		UnLock()
		return empty
	End Method

	Method Lock()
		mutex.Lock()
	End Method
	
	Method Unlock()
		mutex.Unlock()
	End Method
	
	Method Wait()
		hasJobs.Wait()
	End Method

	Method TimedWait:Int(millis:Int)
		Return hasJobs.TimedWait(millis)
	End Method
	
	Method PostAll()
		hasJobs.PostAll()
	End Method

End Type

Type TPooledThread Extends TThread

	Field pool:TThreadPoolExecutor
	Field id:Int

	Method New(pool:TThreadPoolExecutor, entry:Object( data:Object))
		Self.pool = pool
		_entry=entry
		_data=Self
		_running=True
		_handle=threads_CreateThread( _EntryStub, Self )
	End Method

End Type

Extern
	Function threads_CreateThread:Byte Ptr( entry:Object( data:Object ),data:Object )
End Extern

?
