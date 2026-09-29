SuperStrict

Framework BRL.GLGraphics
Import BRL.StandardIO
Import "shader_source.c"

' GLEW's older Byte Ptr Ptr declaration loses C's nested string const qualifiers.
' This small bridge preserves those qualifiers for current strict C compilers.
Extern
	Function bmx_glExampleShaderSource(shader:Int, source:Byte Ptr)
End Extern

' GLGraphics creates the context; Pub.GLEW (imported by GLGraphics) exposes GL APIs.
Local profile:Int = GL_CONTEXT_CORE
Local testMode:Int
For Local arg:String = EachIn AppArgs
	If arg = "--compat" Then profile = GL_CONTEXT_COMPATIBILITY
	If arg = "--test" Then testMode = True
Next
Local options:TGLContextOptions = TGLContextOptions.Create(3, 3, profile)
Local graphics:TGraphics = GLGraphics(800, 600, 0, 60, GRAPHICS_BACKBUFFER, options)
If Not graphics Then RuntimeError "The requested OpenGL 3.3 profile is unavailable."
If glewInit() <> 0 Then RuntimeError "Could not initialise GLEW."
If Not GL_VERSION_3_3 Then RuntimeError "GLEW did not find OpenGL 3.3."
' Some GLEW versions leave a legacy extension-query error in core contexts.
While glGetError() <> GL_NO_ERROR
Wend
Print "OpenGL: " + String.FromCString(glGetString(GL_VERSION))

Local vertexSource:String = "#version 330 core~n" + ..
	"layout(location=0) in vec2 position;~n" + ..
	"void main() { gl_Position=vec4(position,0.0,1.0); }~n"
Local fragmentSource:String = "#version 330 core~n" + ..
	"out vec4 colour;~n" + ..
	"void main() { colour=vec4(0.15,0.7,1.0,1.0); }~n"
Local vertex:Int = CompileShader(GL_VERTEX_SHADER, vertexSource)
Local fragment:Int = CompileShader(GL_FRAGMENT_SHADER, fragmentSource)
Local program:Int = glCreateProgram()
glAttachShader(program, vertex)
glAttachShader(program, fragment)
glLinkProgram(program)
Local linked:Int
glGetProgramiv(program, GL_LINK_STATUS, Varptr linked)
If Not linked
	Local log:Byte[4096]
	glGetProgramInfoLog(program, log.Length, Null, log)
	RuntimeError "Program link failed: " + String.FromCString(log)
End If
glDeleteShader(vertex)
glDeleteShader(fragment)

Local vertices:Float[] = [-0.7, -0.6, 0.7, -0.6, 0.0, 0.7]
Local vao:Int
Local buffer:Int
glGenVertexArrays(1, Varptr vao)
glBindVertexArray(vao)
glGenBuffers(1, Varptr buffer)
glBindBuffer(GL_ARRAY_BUFFER, buffer)
glBufferData(GL_ARRAY_BUFFER, vertices.Length * 4, vertices, GL_STATIC_DRAW)
glVertexAttribPointer(0, 2, GL_FLOAT, False, 0, Null)
glEnableVertexAttribArray(0)

Local frames:Int
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()
	Local pixelWidth:Int
	Local pixelHeight:Int
	TGLGraphics(graphics).DrawableSize(pixelWidth, pixelHeight)
	glViewport(0, 0, pixelWidth, pixelHeight)
	glClearColor(0.04, 0.06, 0.09, 1.0)
	glClear(GL_COLOR_BUFFER_BIT)
	glUseProgram(program)
	glBindVertexArray(vao)
	glDrawArrays(GL_TRIANGLES, 0, 3)
	If frames = 0
		Local pixel:Byte[4]
		glReadPixels(pixelWidth / 2, pixelHeight / 2, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel)
		If pixel[2] < 200 Or pixel[1] < 140 Or pixel[0] > 80 Then RuntimeError "Triangle pixel verification failed."
		If glGetError() <> GL_NO_ERROR Then RuntimeError "OpenGL drawing failed."
		Print "Shader triangle pixel verified."
	End If
	Flip
	frames :+ 1
	If testMode And frames >= 3 Then Exit
Wend

glDeleteBuffers(1, Varptr buffer)
glDeleteVertexArrays(1, Varptr vao)
glDeleteProgram(program)
EndGraphics

Function CompileShader:Int(kind:Int, source:String)
	Local shader:Int = glCreateShader(kind)
	Local utf8:Byte Ptr = source.ToUTF8String()
	bmx_glExampleShaderSource(shader, utf8)
	MemFree(utf8)
	glCompileShader(shader)
	Local compiled:Int
	glGetShaderiv(shader, GL_COMPILE_STATUS, Varptr compiled)
	If Not compiled
		Local log:Byte[4096]
		glGetShaderInfoLog(shader, log.Length, Null, log)
		glDeleteShader(shader)
		RuntimeError "Shader compilation failed: " + String.FromCString(log)
	End If
	Return shader
End Function
