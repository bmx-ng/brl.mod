Private

Global _appLoopFrame:Int()
Global _appLoopOnStop()
Global _appLoopActive:Int
Global _appLoopDispatching:Int

?emscripten
Extern
	Function emscripten_set_main_loop(callback(), fps:Int, simulateInfiniteLoop:Int)
	Function emscripten_cancel_main_loop()
End Extern
?

Function _AppLoopTick()
	Try
		If _appLoopFrame() Then Return
	Catch error:Object
		_AppLoopStop()
		Throw error
	End Try
	_AppLoopStop()
End Function

Function _AppLoopStop()
	If Not _appLoopActive Then Return
	?emscripten
	emscripten_cancel_main_loop()
	?
	_appLoopActive = False
	_appLoopFrame = Null
	Local onStop() = _appLoopOnStop
	_appLoopOnStop = Null
	If onStop Then onStop()
End Function

Public
