SuperStrict

Framework BRL.GLGraphics
Import BRL.StandardIO

Function Check(ok:Int, message:String)
	If Not ok Then RuntimeError message
End Function

' Preserve the existing default driver and its resource-sharing behaviour.
Local legacyDriver:TGLGraphicsDriver = GLGraphicsDriver()
GLShareContexts()
Local legacy:TGLGraphics = legacyDriver.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER, -1, -1)
Check(legacy <> Null, "Legacy context creation")
SetGraphics(legacy)
Local legacyVersion:String = String.FromCString(glGetString(GL_VERSION))
Print "Legacy: " + legacyVersion
Local legacyTexture:Int
glGenTextures(1, Varptr legacyTexture)
glBindTexture(GL_TEXTURE_2D, legacyTexture)
Local legacyShared:TGLGraphics = legacyDriver.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER, -1, -1)
Check(legacyShared <> Null, "Legacy shared creation")
SetGraphics(legacyShared)
Check(glIsTexture(legacyTexture), "Legacy sharing remains functional")
CloseGraphics(legacyShared)
SetGraphics(legacy)

Local options:TGLContextOptions = TGLContextOptions.Create(3, 3)
Local driver:TGLGraphicsDriver = GLGraphicsDriver(options)
options.major = 99
Local modern:TGLGraphics = driver.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER | GRAPHICS_DEPTHBUFFER, -1, -1)
Local expectedProfile:Int = GL_CONTEXT_CORE
If Not modern
	Print "Core profile unavailable; explicitly testing compatibility instead."
	expectedProfile = GL_CONTEXT_COMPATIBILITY
	driver = GLGraphicsDriver(TGLContextOptions.Create(3, 3, expectedProfile))
	modern = driver.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER | GRAPHICS_DEPTHBUFFER, -1, -1)
End If
Check(modern <> Null, "OpenGL 3.3 explicit request")
Check(modern.Driver() = driver, "Graphics retains its configured driver")
Local drawableWidth:Int
Local drawableHeight:Int
modern.DrawableSize(drawableWidth, drawableHeight)
Check(drawableWidth >= 160 And drawableHeight >= 120, "Drawable size includes display scaling")
SetGraphics(modern)
Print "Explicit context: " + String.FromCString(glGetString(GL_VERSION))
Check(glewInit() = 0 And GL_VERSION_3_3, "GLEW sees OpenGL 3.3")
While glGetError() <> GL_NO_ERROR
Wend
Local mask:Int
Local depth:Int
glGetIntegerv($9126, Varptr mask)
glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, GL_DEPTH, GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE, Varptr depth)
Check((mask & expectedProfile) <> 0 And depth >= 24, "Requested profile and depth buffer")

Local texture:Int
glGenTextures(1, Varptr texture)
glBindTexture(GL_TEXTURE_2D, texture)
Local sharing:TGLContextOptions = TGLContextOptions.Create(3, 3, expectedProfile)
sharing.shareWith = modern
Local sharedDriver:TGLGraphicsDriver = GLGraphicsDriver(sharing)
Local shared:TGLGraphics = sharedDriver.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER, -1, -1)
Check(shared <> Null, "Explicit sharing creation")
SetGraphics(shared)
Check(glIsTexture(texture), "Modern texture sharing")
SetGraphics(modern)
CloseGraphics(shared)
SetGraphics(modern)

Local impossible:TGLGraphicsDriver = GLGraphicsDriver(TGLContextOptions.Create(99, 0))
Local failed:TGLGraphics = impossible.CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER, -1, -1)
Check(failed = Null, "Unsupported request must fail without fallback")
Check(glIsTexture(texture), "Failed creation preserves the current context")
glDeleteTextures(1, Varptr texture)
CloseGraphics(modern)
modern.DrawableSize(drawableWidth, drawableHeight)
Check(drawableWidth = 0 And drawableHeight = 0, "Closed graphics has no drawable")

SetGraphics(legacy)
Check(String.FromCString(glGetString(GL_VERSION)) = legacyVersion, "Legacy context remains usable after modern context")
glDeleteTextures(1, Varptr legacyTexture)
CloseGraphics(legacy)
Check(GLGraphicsDriver() = legacyDriver, "Default driver identity is unchanged")

Local compatibility:TGLGraphics = GLGraphicsDriver(TGLContextOptions.Create(3, 3, GL_CONTEXT_COMPATIBILITY)).CreateGraphics(160, 120, 0, 0, GRAPHICS_BACKBUFFER, -1, -1)
?osx
Check(compatibility = Null, "macOS rejects modern compatibility contexts")
?Not osx
If compatibility
	SetGraphics(compatibility)
	glGetIntegerv($9126, Varptr mask)
	Check((mask & GL_CONTEXT_COMPATIBILITY) <> 0, "Compatibility profile is honoured")
	CloseGraphics(compatibility)
Else
	Print "Compatibility profile unavailable on this driver."
End If
?
Local invalid:Int
Try
	GLGraphicsDriver(TGLContextOptions.Create(2, 1, GL_CONTEXT_CORE))
Catch error:Object
	invalid=True
End Try
Check(invalid, "Reject profiles before OpenGL 3.2")
Print "GLGraphics context tests passed."
