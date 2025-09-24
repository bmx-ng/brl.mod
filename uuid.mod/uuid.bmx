' Copyright (c) 2015-2025 Bruce A Henderson
' All rights reserved.
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
'     * Redistributions of source code must retain the above copyright
'       notice, this list of conditions and the following disclaimer.
'     * Redistributions in binary form must reproduce the above copyright
'       notice, this list of conditions and the following disclaimer in the
'       documentation and/or other materials provided with the distribution.
'     * Neither the name of the author nor the
'       names of its contributors may be used to endorse or promote products
'       derived from this software without specific prior written permission.
'
' THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
' EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
' DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
' (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
' ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
' (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
' SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
SuperStrict

Rem
bbdoc: Generate UUIDs
End Rem
Module BRL.uuid

ModuleInfo "Version: 1.02"
ModuleInfo "License: BSD"
ModuleInfo "Copyright: Wrapper - 2015-2025 Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Changed win32 to use Rpcrt4."
ModuleInfo "History: 1.01"
ModuleInfo "History: Update to util-linux 2.34"
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

?not win32
Import Pub.libuuid
?win32
Import "-lRpcrt4"
Import "win32_glue.c"
?

Rem
bbdoc: Generates a UUID in canonical form, optionally in uppercase.
End Rem
Function uuidGenerate:String(upperCase:Int = False)
	Return uuidToCanonical(uuidGenerateBytes(), upperCase)
End Function

Rem
bbdoc: Generates a UUID Byte array.
End Rem
Function uuidGenerateBytes:Byte[]()
	Local buf:Byte[16]
	uuid_generate(buf)
	Return buf
End Function

Rem
bbdoc: Converts a UUID Byte array into a String, optionally in uppercase.
End Rem
Function uuidToCanonical:String(buf:Byte[], upperCase:Int = False)
	Local out:Byte[100]
	If upperCase Then
		uuid_unparse_upper(buf, out)
	Else
		uuid_unparse(buf, out)
	End If
	Return String.FromBytes(out, Int(strlen(out)))
End Function

?win32
Extern
	Function strlen:Size_T(buf:Byte Ptr)

	Function uuid_generate(buf:Byte Ptr)
	Function uuid_unparse(buf:Byte Ptr, out:Byte Ptr)
	Function uuid_unparse_upper(buf:Byte Ptr, out:Byte Ptr)
End Extern
?
