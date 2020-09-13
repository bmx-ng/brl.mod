SuperStrict

Import "debugger.stdio.glue.c"

NoDebug

?win32
Include "deref_win32.bmx"
?linux
Include "deref_linux.bmx"
?macos
Include "deref_macos.bmx"
?haiku
Include "deref_haiku.bmx"
?


Private

Const derefFailure:String = "{?}"
Const derefSymbol:String = "->"

?Win32
Extern "Win32"
Const SW_SHOW:Int=5
Const SW_RESTORE:Int=9
Function IsIconic:Int( hwnd:Byte Ptr )="WINBOOL IsIconic( HWND )!"
Function GetForegroundWindow:Byte Ptr()="HWND GetForegroundWindow()!"
Function SetForegroundWindow:Int( hwnd:Byte Ptr )="WINBOOL SetForegroundWindow( HWND )!"
Function ShowWindow:Int( hwnd:Byte Ptr,cmdShow:Int )="WINBOOL ShowWindow( HWND ,int )!"
Function GetCurrentThreadId:Int()="DWORD GetCurrentThreadId()!"
End Extern
?

?MacOS
Extern
Function CGDisplayIsCaptured:Int( displayId:Int )
End Extern
?

Extern
	Function bbIsMainThread:Int()="bbIsMainThread"
	Function bbGCValidate:Int( mem:Byte Ptr ) = "int bbGCValidate( void * )!"

	Function DebugScopeName:String( scope:Int Ptr )="bmx_debugger_DebugScopeName"
	Function bmx_debugger_DebugScopeKind:UInt( scope:Int Ptr )
	Function bmx_debugger_DebugScopeDecl:Byte Ptr( scope:Int Ptr )

	Function DebugDeclName:String( decl:Int Ptr )="bmx_debugger_DebugDeclName"
	Function bmx_debugger_DebugDeclType:String( decl:Int Ptr )
	Function bmx_debugger_DebugDeclKind:UInt( decl:Int Ptr )
	Function bmx_debugger_DebugDeclNext:Byte Ptr( decl:Int Ptr )
	Function bmx_debugger_DebugDecl_VarAddress:Byte Ptr( decl:Int Ptr )
	Function bmx_debugger_DebugDecl_ConstValue:String( decl:Int Ptr )
	Function bmx_debugger_DebugDecl_FieldOffset:Byte Ptr(decl:Int Ptr, inst:Byte Ptr)
	Function bmx_debugger_DebugDecl_StringFromAddress:String( addr:Byte Ptr )
	Function bmx_debugger_DebugDeclTypeChar:Int( decl:Int Ptr, index:Int )
	Function bmx_debugger_DebugDecl_ArraySize:Int( decl:Byte Ptr )
	Function bmx_debugger_DebugDecl_ArrayDecl:Byte Ptr(inst:Byte Ptr)
	Function bmx_debugger_DebugDecl_ArrayDeclIndexedPart(decl:Byte Ptr, inst:Byte Ptr, index:Int)
	Function bmx_debugger_DebugDecl_ArrayDeclFree(decl:Byte Ptr)

	Function bmx_debugger_DebugDecl_clas:Byte Ptr( inst:Byte Ptr )
	Function bmx_debugger_DebugDecl_isStringClass:Int( clas:Byte Ptr )
	Function bmx_debugger_DebugDecl_isArrayClass:Int( clas:Byte Ptr )
	Function bmx_debugger_DebugDecl_isBaseObject:Int( clas:Byte Ptr )
	
	Function bmx_debugger_DebugClassSuper:Byte Ptr(clas:Byte Ptr)
	Function bmx_debugger_DebugClassScope:Byte Ptr(clas:Byte Ptr)
	
	Function DebugStmFile:String( stm:Int Ptr )="bmx_debugger_DebugStmFile"
	Function DebugStmLine:Int( stm:Int Ptr )="bmx_debugger_DebugStmLine"
	Function DebugStmChar:Int( stm:Int Ptr )="bmx_debugger_DebugStmChar"

	Function bmx_debugger_ref_bbNullObject:Byte Ptr()
	Function bmx_debugger_ref_bbEmptyArray:Byte Ptr()
	Function bmx_debugger_ref_bbEmptyString:Byte Ptr()
	Function bmx_debugger_ref_brl_blitz_NullFunctionError:Byte Ptr()
	
	Function bbObjectStructInfo:Byte Ptr(name:Byte Ptr)="BBDebugScope * bbObjectStructInfo( char * )!"
	Function bmx_debugger_DebugEnumDeclValue:String(decl:Byte Ptr, val:Byte Ptr)
End Extern

?Not ptr64
Function ToHex$( val:Int )
	Local buf:Short[8]
	For Local k:Int=7 To 0 Step -1
		Local n:Int=(val&15)+Asc("0")
		If n>Asc("9") n=n+(Asc("A")-Asc("9")-1)
		buf[k]=n
		val:Shr 4
	Next
	Return String.FromShorts( buf,8 ).ToLower()
End Function
?ptr64
Function ToHex$( val:Long )
	Local buf:Short[16]
	For Local k:Int=15 To 0 Step -1
		Local n:Int=(val&15)+Asc("0")
		If n>Asc("9") n=n+(Asc("A")-Asc("9")-1)
		buf[k]=n
		val:Shr 4
	Next
	Return String.FromShorts( buf,16 ).ToLower()
End Function
?

Function IsAlpha:Int( ch:Int )
	Return (ch>=Asc("a") And ch<=Asc("z")) Or (ch>=Asc("A") And ch<=Asc("Z"))
End Function

Function IsNumeric:Int( ch:Int )
	Return ch>=Asc("0") And ch<=Asc("9")
End Function

Function IsAlphaNumeric:Int( ch:Int )
	Return IsAlpha(ch) Or IsNumeric(ch)
End Function

Function IsUnderscore:Int( ch:Int )
	Return ch=Asc("_")
End Function

Function Ident$( tag$ Var )
	If Not tag Return ""
	If Not IsAlpha( tag[0] ) And Not IsUnderscore( tag[0] ) Return ""
	Local i:Int=1
	While i<tag.length And (IsAlphaNumeric(tag[i]) Or IsUnderscore(tag[i]))
		i:+1
	Wend
	Local id$=tag[..i]
	tag=tag[i..]
	Return id
End Function

Function TypeName$( tag$ Var )
	
	Local t$=tag[..1]
	tag=tag[1..]

	Select t
	Case "b"
		Return "Byte"
	Case "s"
		Return "Short"
	Case "i"
		Return "Int"
	Case "u"
		Return "UInt"
	Case "l"
		Return "Long"
	Case "y"
		Return "ULong"
	Case "j"
		Return "Int128"
	Case "f"
		Return "Float"
	Case "d"
		Return "Double"
	Case "h"
		Return "Float64"
	Case "k"
		Return "Float128"
	Case "m"
		Return "Double128"
	Case "$"
		Return "String"
	Case "z"
		Return "CString"
	Case "w"
		Return "WString"
	Case "t"
		Return "Size_T"
	Case "W"
		Return "WParam"
	Case "X"
		Return "LParam"
	Case ":","?","#","@","/"
		Local id$=Ident( tag )
		While tag And tag[0]=Asc(".")
			tag=tag[1..]
			id=Ident( tag )
		Wend
		If Not id DebugError "Invalid object typetag"
		Return id
	Case "*"
		Return TypeName( tag )+" Ptr"
	Case "["
		Local length:Int
		While tag[..1]=","
			tag=tag[1..]
			t:+","
		Wend
		While IsNumeric(tag[0])
			length = length * 10 + Int(tag[..1])
			tag=tag[1..]
		Wend
		If tag[..1]<>"]" DebugError "Invalid array typetag"
		tag=tag[1..]
		If length Then
			Return TypeName( tag )+t+length+"]"
		Else
			Return TypeName( tag )+t+"]"
		End If
	Case "("
		If tag[..1]<>")"
			t:+TypeName( tag )
			While tag[..1]=","
				tag=tag[1..]
				t:+","+TypeName( tag )
			Wend
			If tag[..1]<>")" DebugError "Invalid function typetag"
		EndIf
		tag=tag[1..]
		Return TypeName( tag )+t+")"
	End Select

	If Not tag.length Return ""
	DebugError "Invalid debug typetag:"+t

End Function

'int offsets into 12 byte DebugStm struct
'Const DEBUGSTM_FILE=0
'Const DEBUGSTM_LINE=1
'Const DEBUGSTM_CHAR=2

'int offsets into 16 byte DebugDecl struct
'Const DEBUGDECL_KIND=0
'Const DEBUGDECL_NAME=1
'Const DEBUGDECL_TYPE=2
'Const DEBUGDECL_ADDR:Int=3

'DEBUGDECL_KIND values
Const DEBUGDECLKIND_END:Int=0
Const DEBUGDECLKIND_CONST:Int=1
Const DEBUGDECLKIND_LOCAL:Int=2
Const DEBUGDECLKIND_FIELD:Int=3
Const DEBUGDECLKIND_GLOBAL:Int=4
Const DEBUGDECLKIND_VARPARAM:Int=5
Const DEBUGDECLKIND_TYPEMETHOD:Int=6
Const DEBUGDECLKIND_TYPEFUNCTION:Int=7

'int offsets into 12+n_decls*4 byte DebugScope struct
'Const DEBUGSCOPE_KIND=0
'Const DEBUGSCOPE_NAME=1
'Const DEBUGSCOPE_DECLS=2

'DEBUGSCOPE_KIND values
Const DEBUGSCOPEKIND_FUNCTION:Int=1
Const DEBUGSCOPEKIND_TYPE:Int=2
Const DEBUGSCOPEKIND_LOCAL:Int=3
Const DEBUGSCOPEKIND_INTERFACE:Int=4
Const DEBUGSCOPEKIND_STRUCT:Int=5

Function DebugError( t$ )
	WriteStderr "Debugger Error:"+t+"~n"
	End
End Function

Function DebugDeclKind$( decl:Int Ptr )
	Select bmx_debugger_DebugDeclKind(decl)
	Case DEBUGDECLKIND_CONST Return "Const"
	Case DEBUGDECLKIND_LOCAL Return "Local"
	Case DEBUGDECLKIND_FIELD Return "Field"
	Case DEBUGDECLKIND_GLOBAL Return "Global"
	Case DEBUGDECLKIND_VARPARAM Return "Local"
	End Select
	DebugError "Invalid decl kind"
End Function

Function DebugDeclType$( decl:Int Ptr )
	Local t$=bmx_debugger_DebugDeclType(decl)
	Local ty$=TypeName( t )
	Return ty
End Function

Function DebugDeclSize:Int( decl:Int Ptr )

	Local tag:Int=bmx_debugger_DebugDeclTypeChar(decl, 0)

	Select tag
	Case Asc("b") Return 1
	Case Asc("s") Return 2
	Case Asc("i") Return 4
	Case Asc("u") Return 4
	Case Asc("f") Return 4
	Case Asc("l") Return 8
	Case Asc("y") Return 8
	Case Asc("d") Return 8
	Case Asc("h") Return 8
	Case Asc("j") Return 16
	Case Asc("k") Return 16
	Case Asc("m") Return 16
	' size_t (t) fall-through to ptr64 size below
	End Select

?Not ptr64
	Return 4
?ptr64
	Return 8
?

End Function

Function DebugEscapeString$( s$ )
	If s.length>4096 s=s[..4096]
	s=s.Replace( "~~","~~~~")
	s=s.Replace( "~0","~~0" )
	s=s.Replace( "~t","~~t" )
	s=s.Replace( "~n","~~n" )
	s=s.Replace( "~r","~~r" )
	s=s.Replace( "~q","~~q" )
	Return "~q"+s+"~q"
End Function

Function DebugDeclValue$( decl:Int Ptr,inst:Byte Ptr )

	If bmx_debugger_DebugDeclKind(decl)=DEBUGDECLKIND_CONST
		Return DebugEscapeString(bmx_debugger_DebugDecl_ConstValue(decl))
	End If

	Local p:Byte Ptr
	Select bmx_debugger_DebugDeclKind(decl)
	Case DEBUGDECLKIND_GLOBAL
		p=bmx_debugger_DebugDecl_VarAddress(decl)
	Case DEBUGDECLKIND_LOCAL
		p=bmx_debugger_DebugDecl_VarAddress(decl)
	Case DEBUGDECLKIND_FIELD
		p=bmx_debugger_DebugDecl_FieldOffset(decl, inst)
	Case DEBUGDECLKIND_VARPARAM
		p=bmx_debugger_DebugDecl_VarAddress(decl)
?Not ptr64
		p=Byte Ptr ( (Int Ptr p)[0] )
?ptr64
		p=Byte Ptr ( (Long Ptr p)[0] )
?
	Default
		DebugError "Invalid decl kind"
	End Select
	
	Local tag:Int=bmx_debugger_DebugDeclTypeChar(decl, 0)
	
	Select tag
	Case Asc("b")
		Return String.FromInt( (Byte Ptr p)[0] )
	Case Asc("s")
		Return String.FromInt( (Short Ptr p)[0] )
	Case Asc("i")
		Return String.FromInt( (Int Ptr p)[0] )
	Case Asc("u")
		Return String.FromUInt( (UInt Ptr p)[0] )
	Case Asc("l")
		Return String.FromLong( (Long Ptr p)[0] )
	Case Asc("y")
		Return String.FromULong( (ULong Ptr p)[0] )
	Case Asc("f")
		Return String.FromFloat( (Float Ptr p)[0] )
	Case Asc("d")
		Return String.FromDouble( (Double Ptr p)[0] )
	Case Asc("t")
		Return String.FromSizet( (Size_T Ptr p)[0] )
?win32
	Case Asc("W")
		Return String.FromWParam( (WParam Ptr p)[0] )
	Case Asc("X")
		Return String.FromLParam( (LParam Ptr p)[0] )
?
	Case Asc("$")
		p=(Byte Ptr Ptr p)[0]
		Return DebugEscapeString( bmx_debugger_DebugDecl_StringFromAddress(p) )
	Case Asc("z")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		Local s$=String.FromCString( p )
		Return DebugEscapeString( s )
	Case Asc("w")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		Local s$=String.FromWString( Short Ptr p )
		Return DebugEscapeString( s )
	Case Asc("*"),Asc("?"),Asc("#")
		Local deref:String
		If tag = Asc("*") Then deref = DebugDerefPointer(decl, p)
?Not ptr64
		Return "$" + ToHex( (Int Ptr p)[0] ) + deref
?ptr64
		Return "$" + ToHex( (Long Ptr p)[0] ) + deref
?
	Case Asc("(")
		p=(Byte Ptr Ptr p)[0]
		If p=bmx_debugger_ref_brl_blitz_NullFunctionError() Return "Null"
	Case Asc(":")
		p=(Byte Ptr Ptr p)[0]
		If p=bmx_debugger_ref_bbNullObject() Return "Null"
		If p=bmx_debugger_ref_bbEmptyArray() Return "Null[]"
		If p=bmx_debugger_ref_bbEmptyString() Return "Null$"
	Case Asc("[")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		If IsNumeric(bmx_debugger_DebugDeclTypeChar(decl, 1)) Then
			Local index:Int = 1
			Local length:Int
			While IsNumeric(bmx_debugger_DebugDeclTypeChar(decl, index))
				length = length * 10 + Int(Chr(bmx_debugger_DebugDeclTypeChar(decl, index)))
				index :+ 1
			Wend
?Not ptr64
			Return "$"+ToHex( Int p ) + "^" + length
?ptr64
			Return "$"+ToHex( Long p ) + "^" + length
?		
		End If
		If Not bmx_debugger_DebugDecl_ArraySize(p) Return "Null"
	Case Asc("@")
?Not ptr64
		Return "$"+ToHex( Int p ) + "@" + bmx_debugger_DebugDeclType(decl)[1..]
?ptr64
		Return "$"+ToHex( Long p ) + "@" + bmx_debugger_DebugDeclType(decl)[1..]
?
	Case Asc("h")
		Return Float Ptr (Varptr p)[0] + "," + Float Ptr (Varptr p)[1]
	Case Asc("j")
		Return Int Ptr (Varptr p)[0] + "," + Int Ptr (Varptr p)[1] + "," + Int Ptr (Varptr p)[2] + "," + Int Ptr (Varptr p)[3]
	Case Asc("k")
		Return Float Ptr (Varptr p)[0] + "," + Float Ptr (Varptr p)[1] + "," + Float Ptr (Varptr p)[2] + "," + Float Ptr (Varptr p)[3]
	Case Asc("m")
		Return Double Ptr(Varptr p)[0] + "," + Double Ptr (Varptr p)[1]
	Case Asc("/")
		Return bmx_debugger_DebugEnumDeclValue(decl, p)
	Default
		DebugError "Invalid decl typetag:"+Chr(tag)
	End Select
	
?Not ptr64
	Return "$"+ToHex( Int p )
?ptr64
	Return "$"+ToHex( Long p )
?
End Function

Function DebugScopeKind$( scope:Int Ptr )
	Select bmx_debugger_DebugScopeKind(scope)
	Case DEBUGSCOPEKIND_FUNCTION Return "Function"
	Case DEBUGSCOPEKIND_TYPE Return "Type"
	Case DEBUGSCOPEKIND_LOCAL Return "Local"
	Case DEBUGSCOPEKIND_INTERFACE Return "Interface"
	Case DEBUGSCOPEKIND_STRUCT Return "Struct"
	End Select
	DebugError "Invalid scope kind"
End Function

Function DebugDerefPointer:String(decl:Int Ptr, pointer:Byte Ptr)
	Const derefFailure:String = "{?}"
	Const derefSymbol:String = "->"
	
	Local declType:String = DebugDeclType(decl)
	Local dataType:String = declType
	Local ptrDepth:Int = 0
	While dataType.EndsWith(" Ptr")
		dataType = dataType[..dataType.length - " Ptr".length]
		ptrDepth :+ 1
	Wend
	
	Local result:String = ""
	
	Local dataSize:Size_T
	Select dataType
 		Case "Byte"      dataSize = SizeOf(Byte Null)
		Case "Short"     dataSize = SizeOf(Short Null)
		Case "Int"       dataSize = SizeOf(Int Null)
		Case "UInt"      dataSize = SizeOf(UInt Null)
		Case "Long"      dataSize = SizeOf(Long Null)
		Case "ULong"     dataSize = SizeOf(ULong Null)
		Case "Size_T"    dataSize = SizeOf(Size_T Null)
		Case "Float"     dataSize = SizeOf(Float Null)
		Case "Double"    dataSize = SizeOf(Double Null)
	? Ptr64
		Case "Float64"   dataSize = SizeOf(Float64 Null)
		Case "Float128"  dataSize = SizeOf(Float128 Null)
		Case "Double128" dataSize = SizeOf(Double128 Null)
		Case "Int128"    dataSize = SizeOf(Int128 Null)
	? Win32	
		Case "WParam"    dataSize = SizeOf(WParam Null)
		Case "LParam"    dataSize = SizeOf(LParam Null)
	?
		Default          dataSize = 0 ' cannot dereference this
	EndSelect

	Local buffer:Byte Ptr = MemAlloc(Size_T(Max(dataSize, SizeOf(Byte Ptr Null))))
	(Byte Ptr Ptr buffer)[0] = Null
	
	Local res:Int
	?win32
	result = DebugDerefPointerWin32(dataSize, ptrDepth, pointer, buffer, res)
	?linux
	result = DebugDerefPointerLinux(dataSize, ptrDepth, pointer, buffer, res)
	?macos
	result = DebugDerefPointerMacos(dataSize, ptrDepth, pointer, buffer, res)
	?haiku
	result = DebugDerefPointerHaiku(dataSize, ptrDepth, pointer, buffer, res)
	?

	If Not res Then
		Return result
	End If

	Local value:String
	Select dataType
 		Case "Byte"      value = String((Byte   Ptr buffer)[0])
		Case "Short"     value = String((Short  Ptr buffer)[0])
		Case "Int"       value = String((Int    Ptr buffer)[0])
		Case "UInt"      value = String((UInt   Ptr buffer)[0])
		Case "Long"      value = String((Long   Ptr buffer)[0])
		Case "ULong"     value = String((ULong  Ptr buffer)[0])
		Case "Size_T"    value = String((Size_T Ptr buffer)[0])
		Case "Float"     value = String((Float  Ptr buffer)[0])
		Case "Double"    value = String((Double Ptr buffer)[0])
	? Ptr64
		Case "Float64"   value = String((Float  Ptr buffer)[0]) + "," + ..
		                         String((Float  Ptr buffer)[1])
		Case "Float128"  value = String((Float  Ptr buffer)[0]) + "," + ..
		                         String((Float  Ptr buffer)[1]) + "," + ..
		                         String((Float  Ptr buffer)[2]) + "," + ..
		                         String((Float  Ptr buffer)[3])
		Case "Double128" value = String((Double Ptr buffer)[0]) + "," + ..
		                         String((Double Ptr buffer)[1])
		Case "Int128"    value = String((Int    Ptr buffer)[0]) + "," + ..
		                         String((Int    Ptr buffer)[1]) + "," + ..
		                         String((Int    Ptr buffer)[2]) + "," + ..
		                         String((Int    Ptr buffer)[3])
	? Win32	
		Case "WParam"    value = String((WParam Ptr buffer)[0])
		Case "LParam"    value = String((LParam Ptr buffer)[0])
	?
		Default
			MemFree buffer
			result :+ derefSymbol + derefFailure
			Return result
	EndSelect
	MemFree buffer
	result :+ derefSymbol + "{" + value + "}"
	?
	
	Return result
EndFunction

'Function DebugScopeDecls:Int Ptr[]( scope:Int Ptr )
'	Local n,p:Int Ptr=scope+DEBUGSCOPE_DECLS
'	While p[n]<>DEBUGDECLKIND_END
'		n:+1
'	Wend
'	Local decls:Int Ptr[n]
'	For Local i=0 Until n
'		decls[i]=p+i*4
'	Next
'	Return decls
'End Function

'Function DebugObjectScope:Int Ptr( inst:Byte Ptr )
'	Local clas:Int Ptr Ptr=(Int Ptr Ptr Ptr inst)[0]
'	Return clas[2]
'End Function

Extern
Global bbOnDebugStop()="void bbOnDebugStop()!"
Global bbOnDebugLog( message$ )="void bbOnDebugLog( BBString * )!"
Global bbOnDebugEnterStm( stm:Int Ptr )="void bbOnDebugEnterStm( BBDebugStm * )!"
Global bbOnDebugEnterScope( scope:Int Ptr)="void bbOnDebugEnterScope( BBDebugScope * )!"
Global bbOnDebugLeaveScope()="void bbOnDebugLeaveScope()!"
Global bbOnDebugPushExState()="void bbOnDebugPushExState()!"
Global bbOnDebugPopExState()="void bbOnDebugPopExState()!"
Global bbOnDebugUnhandledEx( ex:Object )="void bbOnDebugUnhandledEx( BBObject * )!"
End Extern

bbOnDebugStop=OnDebugStop
bbOnDebugLog=OnDebugLog
bbOnDebugEnterStm=OnDebugEnterStm
bbOnDebugEnterScope=OnDebugEnterScope
bbOnDebugLeaveScope=OnDebugLeaveScope
bbOnDebugPushExState=OnDebugPushExState
bbOnDebugPopExState=OnDebugPopExState
bbOnDebugUnhandledEx=OnDebugUnhandledEx

?Win32
Global _ideHwnd:Byte Ptr=GetForegroundWindow();
Global _appHwnd:Byte Ptr
?

'********** Debugger code here **********

Const MODE_RUN:Int=0
Const MODE_STEP:Int=1
Const MODE_STEPIN:Int=2
Const MODE_STEPOUT:Int=3

Type TScope
	Field scope:Int Ptr,inst:Byte Ptr,stm:Int Ptr
End Type

Type TExState
	Field scopeStackTop:Int
End Type

Type TDbgState
	Field Mode:Int,debugLevel:Int,funcLevel:Int
	Field currentScope:TScope=New TScope
	Field scopeStack:TScope[],scopeStackTop:Int
	Field exStateStack:TExState[],exStateStackTop:Int
End Type

?Threaded
Extern
Function bbThreadAllocData:Int()
Function bbThreadSetData( index:Int,data:Object )
Function bbThreadGetData:TDbgState( index:Int )="BBObject* bbThreadGetData(int )!"
End Extern
?

Function GetDbgState:TDbgState()
	Global dbgStateMain:TDbgState=New TDbgState
?Threaded
	If bbIsMainThread() Return dbgStateMain
	Global dbgStateId:Int=bbThreadAllocData()
	Local dbgState:TDbgState=bbThreadGetData( dbgStateId )
	If Not dbgState
		dbgState = New TDbgState
		bbThreadSetData( dbgStateId,dbgState )
	End If
	Return dbgState
?Not Threaded
	Return dbgStateMain
?
End Function

Function ReadDebug$()
	Return ReadStdin()
End Function

Function WriteDebug( t$ )
	WriteStderr "~~>"+t
End Function

Function DumpScope( scope:Byte Ptr, inst:Byte Ptr )
	Local decl:Byte Ptr=bmx_debugger_DebugScopeDecl(scope)
	Local kind$=DebugScopeKind( scope )
	Local name$=DebugScopeName( scope )
	
	If Not name name="<local>"
	
	WriteDebug kind+" "+name+"~n"
	While bmx_debugger_DebugDeclKind(decl)<>DEBUGDECLKIND_END
		Select bmx_debugger_DebugDeclKind(decl)
		Case DEBUGDECLKIND_TYPEMETHOD,DEBUGDECLKIND_TYPEFUNCTION
			decl = bmx_debugger_DebugDeclNext(decl)
			Continue
		End Select
		Local kind$=DebugDeclKind( decl )
		Local name$=DebugDeclname( decl )
		Local tipe$=DebugDeclType( decl )
		Local value$=DebugDeclValue( decl, inst )
		WriteDebug kind+" "+name+":"+tipe+"="+value+"~n"

		decl = bmx_debugger_DebugDeclNext(decl)
	Wend
End Function

Function DumpClassScope( clas:Int Ptr,inst:Byte Ptr )

	Local supa:Int Ptr = bmx_debugger_DebugClassSuper(clas)
	
	If Not supa Return
	
	DumpClassScope supa,inst
	
	DumpScope bmx_debugger_DebugClassScope(clas),inst

End Function

Function DumpObject( inst:Byte Ptr,index:Int )

	Local clas:Byte Ptr=bmx_debugger_DebugDecl_clas(inst)
	
	If bmx_debugger_DebugDecl_isStringClass(clas)

		WriteDebug DebugEscapeString(bmx_debugger_DebugDecl_StringFromAddress(inst))+"~n"

		Return

	Else If bmx_debugger_DebugDecl_isArrayClass(clas)

		Local length:Int=bmx_debugger_DebugDecl_ArraySize(inst)

		If Not length Return
		
		Local decl:Byte Ptr = bmx_debugger_DebugDecl_ArrayDecl(inst)

		For Local i:Int=1 To 10

			If index>=length Exit
			
			bmx_debugger_DebugDecl_ArrayDeclIndexedPart(decl, inst, index)
		
			Local value$=DebugDeclValue( decl,inst )
			
			WriteDebug "["+index+"]="+value+"~n"
			
			index:+1
			
		Next

		bmx_debugger_DebugDecl_ArrayDeclFree(decl)
		
		If index<length

			WriteDebug "...=$"+ToHex(Int inst)+":"+index+"~n"
	
		EndIf
		
	Else
			
		If bmx_debugger_DebugDecl_isBaseObject(clas) Then
			WriteDebug "Object~n"
			Return
		EndIf
	
		DumpClassScope clas,inst
	
	EndIf
	
End Function

Function DumpStruct( inst:Byte Ptr,index:Int,structName:String )
	Local s:Byte Ptr = structName.ToCString()
	Local scope:Byte Ptr = bbObjectStructInfo(s)
	If scope Then
		DumpScope scope,inst
	End If
	MemFree s
End Function

Function DumpScopeStack()
	Local dbgState:TDbgState = GetDbgState()
	For Local i:Int=Max(dbgState.scopeStackTop-100,0) Until dbgState.scopeStackTop
		Local t:TScope=dbgState.scopeStack[i]
		Local stm:Int Ptr=t.stm
		If Not stm Continue
		WriteDebug "@"+DebugStmFile(stm)+"<"+DebugStmLine(stm)+","+DebugStmChar(stm)+">~n"
		DumpScope t.scope, t.inst
	Next
End Function

Function UpdateDebug( msg$ )
	Global indebug:Int
	If indebug Return
	indebug=True
	
	Local dbgState:TDbgState = GetDbgState()
	
?Win32
	_appHwnd=GetForegroundWindow();
	'SetForegroundWindow( _ideHwnd );
?
?MacOs
	'fullscreen debug too hard in MacOS!
	If CGDisplayIsCaptured( 0 )
		WriteStdout msg
		End
	EndIf
?
	WriteDebug msg
	Repeat
		WriteDebug "~n"
		Local line$=ReadDebug()

		Select line[..1].ToLower()
		Case "r"
			dbgState.Mode=MODE_RUN
			Exit
		Case "s"
			dbgState.Mode=MODE_STEP
			dbgState.debugLevel=dbgState.funcLevel
			Exit
		Case "e"
			dbgState.Mode=MODE_STEPIN
			Exit
		Case "l"
			dbgState.Mode=MODE_STEPOUT
			dbgState.debugLevel=dbgState.scopeStackTop-1
			Exit
		Case "t"
			WriteDebug "StackTrace{~n"
			DumpScopeStack
			WriteDebug "}~n"
		Case "d"
			Local t$=line[1..].Trim()
			Local index:Int
			Local i:Int=t.Find(":")
			If i<>-1
				index=Int( t[i+1..] )
				t=t[..i]
			EndIf
			
			Local structType:String
			Local saLength:Int
			Local n:Int = t.Find("@")
			If n <> -1 Then
				structType = t[n+1..]
				t = t[..n]
			Else
				n = t.Find("^")
				If n <> -1 Then
					saLength = Int(t[n+1..])
					t = t[..n]
				Else
					If t[..1]="$" t=t[1..].Trim()
					If t[..2].ToLower()="0x" t=t[2..].Trim()
				End If
			End If

?Not ptr64
			Local pointer:Int = Int( "$"+t )
?ptr64
			Local pointer:Long = Long( "$"+t )
?
			If Not structType And Not (pointer And bbGCValidate(Byte Ptr(pointer))) Then Continue
			If saLength Continue
?Not ptr64
			Local inst:Int Ptr=Int Ptr pointer
			Local cmd$="ObjectDump@"+ToHex( Int inst )
?ptr64
			Local inst:Long Ptr=Long Ptr pointer
			Local cmd$="ObjectDump@"+ToHex( Long inst )
?			
			If structType Then
				cmd :+ "@" + structType
			End If
			If i<>-1 cmd:+":"+index
			WriteDebug cmd$+"{~n"

			If structType Then
				DumpStruct inst,index,structType
			Else
				DumpObject inst,index
			End If
			WriteDebug "}~n"
		Case "h"
			WriteDebug "T - Stack trace~n"
			WriteDebug "R - Run from here~n"
			WriteDebug "S - Step through source code~n"
			WriteDebug "E - Step into function call~n"
			WriteDebug "L - Leave function or local block~n"
			WriteDebug "Q - Quit~n"
			WriteDebug "H - This text~n"
			WriteDebug "Dxxxxxxxx - Dump object at hex address xxxxxxxx~n"
		Case "q"
			End
		End Select
	Forever

?Win32
	If _appHwnd And _appHwnd<>_ideHwnd 
		If IsIconic(_apphwnd)
			ShowWindow _appHwnd,SW_RESTORE
		Else
			ShowWindow _appHwnd,SW_SHOW
		EndIf		
		_apphwnd=0
	EndIf
?
	indebug=False
End Function

Function OnDebugStop()
	UpdateDebug "DebugStop:~n"
End Function

Function OnDebugLog( message$ )
	WriteStdout "DebugLog:"+message+"~n"
End Function

Function OnDebugEnterStm( stm:Int Ptr )
	Local dbgState:TDbgState = GetDbgState()
	dbgState.currentScope.stm=stm
	
	Select dbgState.Mode
	Case MODE_RUN
		Return
	Case MODE_STEP
		If dbgState.funcLevel>dbgState.debugLevel 
			Return
		EndIf
	Case MODE_STEPOUT
		If dbgState.scopeStackTop>dbgState.debugLevel
			Return
		EndIf
	End Select
	
	UpdateDebug "Debug:~n"
End Function

Function OnDebugEnterScope( scope:Int Ptr)',inst:Byte Ptr )
	Local dbgState:TDbgState = GetDbgState()
	GCSuspend

	If dbgState.scopeStackTop=dbgState.scopeStack.length 
		dbgState.scopeStack=dbgState.scopeStack[..dbgState.scopeStackTop * 2 + 32]
		For Local i:Int=dbgState.scopeStackTop Until dbgState.scopeStack.length
			dbgState.scopeStack[i]=New TScope
		Next
	EndIf
	
	dbgState.currentScope=dbgState.scopeStack[dbgState.scopeStackTop]

	dbgState.currentScope.scope=scope
	dbgState.currentScope.inst=0

	dbgState.scopeStackTop:+1

	If bmx_debugger_DebugScopeKind(dbgState.currentScope.scope)=DEBUGSCOPEKIND_FUNCTION dbgState.funcLevel:+1

	GCResume	
End Function

Function OnDebugLeaveScope()
	Local dbgState:TDbgState = GetDbgState()
	GCSuspend

	If Not dbgState.scopeStackTop DebugError "scope stack underflow"

	If bmx_debugger_DebugScopeKind(dbgState.currentScope.scope)=DEBUGSCOPEKIND_FUNCTION dbgState.funcLevel:-1
	
	dbgState.scopeStackTop:-1

	If dbgState.scopeStackTop
		dbgState.currentScope=dbgState.scopeStack[dbgState.scopeStackTop-1]
	Else
		dbgState.currentScope=Null
	EndIf

	GCResume	
End Function

Function OnDebugPushExState()

	Local dbgState:TDbgState = GetDbgState()
	GCSuspend

	If dbgState.exStateStackTop=dbgState.exStateStack.length 
		dbgState.exStateStack=dbgState.exStateStack[..dbgState.exStateStackTop * 2 + 32]
		For Local i:Int=dbgState.exStateStackTop Until dbgState.exStateStack.length
			dbgState.exStateStack[i]=New TExState
		Next
	EndIf
	
	dbgState.exStateStack[dbgState.exStateStackTop].scopeStackTop=dbgState.scopeStackTop
	
	dbgState.exStateStackTop:+1

	GCResume	
End Function

Function OnDebugPopExState()

	Local dbgState:TDbgState = GetDbgState()
	GCSuspend

	If Not dbgState.exStateStackTop DebugError "exception stack underflow"

	dbgState.exStateStackTop:-1

	dbgState.scopeStackTop=dbgState.exStateStack[dbgState.exStateStackTop].scopeStackTop
	
	If dbgState.scopeStackTop
		dbgState.currentScope=dbgState.scopeStack[dbgState.scopeStackTop-1]
	Else
		dbgState.currentScope=Null
	EndIf

	GCResume	
End Function

Function OnDebugUnhandledEx( ex:Object )

	GCSuspend
	
	UpdateDebug "Unhandled Exception:"+ex.ToString()+"~n"

	GCResume	
End Function
