
Extern "Win32"
	Function GetCurrentProcess:Byte Ptr() = "HANDLE GetCurrentProcess(void)!"
	Function ReadProcessMemory:Int(hProcess:Byte Ptr, lpBaseAddress:Byte Ptr, lpBuffer:Byte Ptr, nSize:Size_T, lpNumberOfBytesRead:Size_T Ptr) = "BOOL ReadProcessMemory(HANDLE, LPCVOID, LPVOID, SIZE_T, SIZE_T*)!"
End Extern

Function DebugDerefPointerWin32:String(dataSize:Size_T, ptrDepth:Int, pointer:Byte Ptr, buffer:Byte Ptr, res:Int Var)

	Local result:String

	Local processHandle:Byte Ptr = GetCurrentProcess()
	
	pointer = (Byte Ptr Ptr pointer)[0]
	For Local i:Int = 1 To ptrDepth - 1
		Local success:Int = ReadProcessMemory(processHandle, pointer, buffer, Size_T SizeOf(Byte Ptr Null), Null)
		If Not success Then
			MemFree buffer
			result :+ derefSymbol + derefFailure
			Return result
		End If
		pointer = (Byte Ptr Ptr buffer)[0]
	? Not Ptr64
		result :+ derefSymbol + "$" + ToHex(Int pointer)
	? Ptr64
		result :+ derefSymbol + "$" + ToHex(Long pointer)
	Next
	
	Local success:Int
	If dataSize > 0 Then
		success = ReadProcessMemory(processHandle, pointer, buffer, dataSize, Null)
	Else
		success = False
	End If
	res = success
	If Not success Then
		MemFree buffer
		result :+ derefSymbol + derefFailure
		Return result
	End If

	Return result
End Function