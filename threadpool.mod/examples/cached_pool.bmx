SuperStrict

Framework BRL.Standardio
Import BRL.ThreadPool
Import brl.glmax2d

Local pool:TThreadPoolExecutor = TThreadPoolExecutor.newCachedThreadPool(5000)

Graphics 800, 600, 0

Local tick:Int

While Not KeyDown(key_escape)
	Cls
	
	tick :+ 1

	DrawText "Threads Alive   : " + pool.threadsAlive, 50, 50
	DrawText "Threads Working : " + pool.threadsWorking, 50, 80
	
	If KeyHit(key_space) Then
		pool.execute(New TTask)
	End If
	
	Flip
Wend


Type TTask Extends TRunnable

	Method run()
		Delay 10000
	End Method
	
End Type