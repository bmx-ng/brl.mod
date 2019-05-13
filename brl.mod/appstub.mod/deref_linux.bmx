
Extern
	Function bmx_process_vm_readv:Size_T(dataSize:Size_T, pointer:Byte Ptr, buffer:Byte Ptr)
End Extern

Function DebugDerefPointerLinux:String(dataSize:Size_T, ptrDepth:Int, pointer:Byte Ptr, buffer:Byte Ptr, res:Int Var)
	Local result:String

	pointer = (Byte Ptr Ptr pointer)[0]
	For Local i:Int = 1 To ptrDepth - 1

		Local success:Size_T = bmx_process_vm_readv(Size_T(SizeOf(Byte Ptr Null)), pointer, buffer)

		If success < 0 Then
			MemFree buffer
			result :+ derefSymbol + derefFailure
			Return result
		End If

		pointer = (Byte Ptr Ptr buffer)[0]
	? Not Ptr64
		result :+ derefSymbol + "$" + ToHex(Int pointer)
	? Ptr64
		result :+ derefSymbol + "$" + ToHex(Long pointer)
	?
	Next

	Local success:Size_T
	If dataSize > 0 Then
		success = bmx_process_vm_readv(dataSize, pointer, buffer)
	Else
		success = -1
	End If
	
	If success < 0 Then
		MemFree buffer
		result :+ derefSymbol + derefFailure
		Return result
	Else
		res = True
	End If

	Return result
	
End Function
