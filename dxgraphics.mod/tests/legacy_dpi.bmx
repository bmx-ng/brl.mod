SuperStrict
Framework BRL.D3D9Max2D
Import BRL.StandardIO
Import "legacy_dpi.c"
Extern "C"
 Function brl_test_dpi_aware()
 Function brl_test_client_width:Int(window:Byte Ptr)
End Extern
brl_test_dpi_aware()
Try
 Local canvas:TMax2DGraphics=TMax2DGraphics(Graphics(320,240,0,0))
 If Not canvas Then Throw "Create graphics"
 Local native:TD3D9Graphics=TD3D9Graphics(canvas._backendGraphics)
 Local width:Int=brl_test_client_width(native._hwnd)
 Print "Graphics width="+GraphicsWidth()+", native mouse/client units="+width
 If width<>GraphicsWidth() Then Throw "Legacy drawing and native input coordinates differ"
 canvas.Resize(400,300)
 SetGraphics(canvas)
 If brl_test_client_width(native._hwnd)<>GraphicsWidth() Then Throw "Legacy resized drawing and input coordinates differ"
 EndGraphics()
 Print "BRL.D3D9Max2D DPI compatibility passed"
Catch error:Object
 EndGraphics()
 Print "FAILED: "+error.ToString()
 EndWithCode(1)
End Try
