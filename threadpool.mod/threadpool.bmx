' Copyright (c)2016 Bruce A Henderson
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

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

?threaded

Import BRL.Threads
Import BRL.LinkedList


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
	Field jobQueue:TJobQueue
	
	Field threadsAlive:Int
	Field threadsWorking:Int
	
	Field countLock:TMutex
	Field threadsIdle:TCondVar
	
	Rem
	bbdoc: 
	End Rem
	Method New(initial:Int)
		maxThreads = initial
		
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
		
		Return pool.processThread()
	End Function
	
	Method processThread:Object()

		countLock.Lock()
		threadsAlive :+ 1
		countLock.Unlock()
		
		While keepThreadsAlive
		
			jobQueue.Wait()
		
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

		Return Null
	End Method
	

	Rem
	bbdoc: Executes the given command at some time in the future.
	End Rem
	Method execute(command:TRunnable)
		If Not isShutdown Then
			jobQueue.Lock()
			jobQueue.Add(command)
			jobQueue.Unlock()
		End If
	End Method

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

	Method Lock()
		mutex.Lock()
	End Method
	
	Method Unlock()
		mutex.Unlock()
	End Method
	
	Method Wait()
		hasJobs.Wait()
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
