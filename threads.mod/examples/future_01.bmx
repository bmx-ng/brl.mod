SuperStrict

Framework brl.standardio
Import brl.threads

' Define a function to perform some computation in a background thread
Function ComputeSomethingAsync:Object( data:Object )
	Local future:TFuture<Float> = TFuture<Float>(data)

	' Simulate a time-consuming computation with Delay
	Local result:Float = 0.0
	For Local i:Int = 0 Until 10
		result :+ 0.1
		Print "Computing... " + result
		Delay(500)
	Next
	' Set the result in the future object
	future.SetResult( result )
End Function


' Create a TFuture instance for Float
Local future:TFuture<Float> = New TFuture<Float>

' Start the computation in a background thread
Local thread:TThread = CreateThread( ComputeSomethingAsync, future )

' Simulate doing some other work in the main thread
Print "Main thread is doing other work..."
For Local j:Int = 0 Until 5
	Print "Main work step " + j
	Delay(300)
Next

' Wait for and retrieve the result from the future object
Local result:Float = future.GetResult()
Print "The result of the computation is: " + result

' Wait for the background thread to finish
thread.Wait()
