' Copyright (c) 2018-2020 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Rem
bbdoc: Cross-platform clipboards.
End Rem
Module BRL.Clipboard

ModuleInfo "Version: 1.02"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: libclipboard - Copyright (C) 2016-2019 Jeremy Tan."
ModuleInfo "Copyright: Wrapper - 2018-2020 Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Fixed for Android."
ModuleInfo "History: 1.01"
ModuleInfo "History: Updated to latest libclipboard 1.0.efaa094"
ModuleInfo "History: 1.00 Initial Release"

?win32
ModuleInfo "CC_OPTS: -DLIBCLIPBOARD_BUILD_WIN32"
?linux And Not android
ModuleInfo "CC_OPTS: -DLIBCLIPBOARD_BUILD_X11"
?macos
ModuleInfo "CC_OPTS: -DLIBCLIPBOARD_BUILD_COCOA"
?haiku
ModuleInfo "CC_OPTS: -DLIBCLIPBOARD_BUILD_HAIKU"
?

'
' build notes :
' clipboard_cocoa.c renamed to clipboard_cocoa.m
'
?Not android
Import "common.bmx"
?android
Import SDL.SDL
?

Rem
bbdoc: Options to be passed on instantiation.
End Rem
Type TClipboardOpts Abstract
End Type

Rem
bbdoc: Win32 options
End Rem
Type TWin32ClipboardOpts Extends TClipboardOpts
	Rem
	bbdoc: Max number of retries to try to obtain clipboard lock.
	about: If @maxRetries is zero, the default value will be used. Specify a negative value for zero retries.
	End Rem
	Field maxRetries:Int = 5
	
	Rem
	bbdoc: Delay in ms between retries to obtain clipboard lock.
	about: If @retryDelay is zero, the default value will be used. Specify a negative value for no (zero) delay.
	End Rem
	Field retryDelay:Int = 5
	
End Type

Rem
bbdoc: X11 options.
End Rem
Type TX11ClipboardOpts Extends TClipboardOpts

	Rem
	bbdoc: Max time (ms) to wait for action to complete.
	End Rem
	Field actionTimeout:Int = 1500
	
	Rem
	bbdoc: Transfer size, in bytes. Must be a multiple of 4.
	End Rem
	Field transferSize:Int = 1048576
	
	Rem
	bbdoc: The name of the X11 display (NULL for default - DISPLAY env. var.)
	End Rem
	Field displayName:String

End Type

?Not android
Rem
bbdoc: A clipboard context.
End Rem
Type TClipboard
	
	Field clipboardPtr:Byte Ptr

	Rem
	bbdoc: Creates a new clipboard instance.
	returns: The clipboard instance, or Null on failure.
	End Rem
	Method Create:TClipboard(opts:TClipboardOpts = Null)
		If TWin32ClipboardOpts(opts) Then
			clipboardPtr = bmx_clipboard_new_win32(TWin32ClipboardOpts(opts).maxRetries, TWin32ClipboardOpts(opts).retryDelay)
		Else If TX11ClipboardOpts(opts) Then
			clipboardPtr = bmx_clipboard_new_x11(TX11ClipboardOpts(opts).actionTimeout, TX11ClipboardOpts(opts).transferSize, TX11ClipboardOpts(opts).displayName)
		Else
			clipboardPtr = bmx_clipboard_new()
		End If
		
		If Not clipboardPtr Then
			Return Null
		End If
		
		Return Self
	End Method

	Rem
	bbdoc: Clears the contents of the given clipboard.
	End Rem
	Method Clear(clipboardMode:Int = LCB_CLIPBOARD)
		bmx_clipboard_clear(clipboardPtr, clipboardMode)
	End Method
	
	Rem
	bbdoc: Determines if the clipboard content is currently owned.
	returns: #True if the clipboard data is owned by the provided instance.
	End Rem
	Method HasOwnership:Int(clipboardMode:Int = LCB_CLIPBOARD)
		Return bmx_clipboard_has_ownership(clipboardPtr, clipboardMode)
	End Method
	
	Rem
	bbdoc: Retrieves the text currently held on the clipboard.
	returns: A copy to the retrieved text.
	End Rem
	Method Text:String()
		Return bmx_clipboard_text(clipboardPtr)
	End Method
	
	Rem
	bbdoc: Retrieves the text currently held on the clipboard.
	about: @length returns the length of the retrieved data.
	returns: A copy to the retrieved text.
	End Rem
	Method TextEx:String(length:Int Var, clipboardMode:Int = LCB_CLIPBOARD)
		Return bmx_clipboard_text_ex(clipboardPtr, Varptr length, clipboardMode)
	End Method

	Rem
	bbdoc: Sets the text for the clipboard.
	returns: #True if the clipboard was set (#false on error).
	End Rem
	Method SetText:Int(src:String)
		Return bmx_clipboard_set_text(clipboardPtr, src)
	End Method
	
	Rem
	bbdoc: Sets the text for the clipboard.
	returns: #True if the clipboard was set (#false on error).
	End Rem
	Method SetTextEx:Int(src:String, clipboardMode:Int = LCB_CLIPBOARD)
		Return bmx_clipboard_set_text_ex(clipboardPtr, src, clipboardMode)
	End Method

	Rem
	bbdoc: Frees the clipboard.
	End Rem
	Method Free()
		If clipboardPtr Then
			bmx_clipboard_free(clipboardPtr)
			clipboardPtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method
	
End Type
?android
Const LCB_CLIPBOARD:Int = 0
Const LCB_PRIMARY:Int = 1
Const LCB_SECONDARY:Int = 2
Type TClipboard
	
	Method Create:TClipboard(opts:TClipboardOpts = Null)
		Return Self
	End Method

	Method Clear(clipboardMode:Int = LCB_CLIPBOARD)
		SDLSetClipboardText("")
	End Method
	
	Method HasOwnership:Int(clipboardMode:Int = LCB_CLIPBOARD)
		Return True
	End Method
	
	Method Text:String()
		Return SDLGetClipboardText()
	End Method
	
	Method TextEx:String(length:Int Var, clipboardMode:Int = LCB_CLIPBOARD)
		Local txt:String = SDLGetClipboardText()
		length = txt.length
		Return txt
	End Method

	Method SetText:Int(src:String)
		Return SDLSetClipboardText(src)
	End Method
	
	Method SetTextEx:Int(src:String, clipboardMode:Int = LCB_CLIPBOARD)
		Return SDLSetClipboardText(src)
	End Method
	
End Type
?



Rem
bbdoc: Creates a new clipboard instance.
returns: The clipboard instance, or Null on failure.
End Rem
Function CreateClipboard:TClipboard(opts:TClipboardOpts = Null)
	Return New TClipboard.Create( opts )
End Function


Rem
bbdoc: Clears the contents of the given clipboard.
End Rem
Function ClearClipboard(clipboard:TClipboard, clipboardMode:Int = LCB_CLIPBOARD)
	clipboard.Clear( clipboardMode )
End Function
	

Rem
bbdoc: Determines if the clipboard content is currently owned.
returns: #True if the clipboard data is owned by the provided instance.
End Rem
Function ClipboardHasOwnership:Int(clipboard:TClipboard, clipboardMode:Int = LCB_CLIPBOARD)
	Return clipboard.HasOwnership(clipboardMode)
End Function
	

Rem
bbdoc: Retrieves the text currently held on the clipboard.
returns: A copy to the retrieved text.
End Rem
Function ClipboardText:String(clipboard:TClipboard)
	Return clipboard.Text()
End Function
	

Rem
bbdoc: Retrieves the text currently held on the clipboard.
about: @length returns the length of the retrieved data.
returns: A copy to the retrieved text.
End Rem
Function ClipboardTextEx:String(clipboard:TClipboard, length:Int Var, clipboardMode:Int = LCB_CLIPBOARD)
	Return clipboard.TextEx(length, clipboardMode)
End Function


Rem
bbdoc: Sets the text for the clipboard.
returns: #True if the clipboard was set (#false on error).
End Rem
Function ClipboardSetText:Int(clipboard:TClipboard, src:String)
	Return clipboard.SetText(src)
End Function
	

Rem
bbdoc: Sets the text for the clipboard.
returns: #True if the clipboard was set (#false on error).
End Rem
Function ClipboardSetTextEx:Int(clipboard:TClipboard, src:String, clipboardMode:Int = LCB_CLIPBOARD)
	Return clipboard.SetTextEx(src, clipboardMode)
End Function
