
Strict

Rem
bbdoc: Graphics/OpenGL Graphics
End Rem
Module BRL.GLGraphics

ModuleInfo "Version: 1.15"
ModuleInfo "Author: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Increased OS X depth buffer size to 24 bits"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Adjusted graphics size after creating window"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Implemented Brucey's linux window title fix"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added GLDrawPixmp"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Trapped Win32 WM_CLOSE"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Added extra check for use of flip sync extensions under Linux"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed MacOS shared context"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Minor maintanance"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Fixed Linux _calchertz"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Changed MacOS DisplayCapture to CaptureAllDisplays"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added SetAcceptsMouseMovedEvents to MacOS windowed mode"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed (removed for now) MacOS atexit issue"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Linux fullscreen fixed"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added AppTitle support"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Added graphics flags handling"

?Win32
Import "glgraphics.win32.c"
Import "source.bmx"
?osx
Import "glgraphics.macos.m"
Import "source.bmx"
Import "-framework CoreVideo"
?Linuxx86
Import "-lX11"
Import "-lXxf86vm"
Import "-lGL"
Import "glgraphics.linux.c"
Import "source.bmx"
?Linuxx64
Import "-lX11"
Import "-lXxf86vm"
Import "-lGL"
Import "glgraphics.linux.c"
Import "source.bmx"
?
