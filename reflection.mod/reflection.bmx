
SuperStrict

Rem
bbdoc: BASIC/Reflection
End Rem
Module BRL.Reflection

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06"
ModuleInfo "History: Added support for BlitzMax-NG features."
ModuleInfo "History: 1.05"
ModuleInfo "History: Added size_t, UInt and ULong primitives."
ModuleInfo "History: 1.04"
ModuleInfo "History: Added support for interfaces."
ModuleInfo "History: 1.03"
ModuleInfo "History: Added grable enhancements."
ModuleInfo "History: Added support for globals."
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added Brucey's size fix to GetArrayElement()/SetArrayElement()."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Fixed NewArray using temp type name"



Import BRL.LinkedList
Import BRL.Map
Import "reflection.c"



Private

Extern
	Function bbObjectDowncast:Object(o:Object, t:Byte Ptr) = "BBObject* bbObjectDowncast(BBObject*, BBClass*)!"
	Function bbInterfaceDowncast:Object(o:Object, ifc:Byte Ptr) = "BBObject* bbInterfaceDowncast(BBOBJECT , BBINTERFACE)!"
	Function bbObjectRegisteredTypes:Byte Ptr Ptr(count:Int Var) = "BBClass** bbObjectRegisteredTypes(int*)!"
	Function bbObjectRegisteredInterfaces:Byte Ptr Ptr(count:Int Var) = "BBInterface** bbObjectRegisteredInterfaces(int*)!"
	Function bbObjectRegisteredStructs:Byte Ptr Ptr(count:Int Var) = "BBDebugScope** bbObjectRegisteredStructs(int*)!"
	Function bbRefArrayClass:Byte Ptr()
	Function bbRefStringClass:Byte Ptr()
	Function bbRefObjectClass:Byte Ptr()
	
	Function bbObjectNew:Object(class:Byte Ptr) = "BBObject* bbObjectNew(BBClass*)!"
	Function bbObjectNewNC:Object(class:Byte Ptr) = "BBObject* bbObjectNewNC(BBClass*)!"
	Function bbArrayNew1D:Object(typeTag:Byte Ptr, length:Int) = "BBArray* bbArrayNew1D(const char*, int)!"
	Function bbRefArrayCreate:Object(typeTag:Byte Ptr, dims:Int[])
	
	Function bbRefArrayLength:Int(array:Object, dim:Int = 0)
	Function bbRefArrayTypeTag$(array:Object)
	Function bbRefArrayDimensions:Int(array:Object)
	
	Function bbRefFieldPtr:Byte Ptr(obj:Object, index:Int)
	Function bbRefMethodPtr:Byte Ptr(obj:Object, index:Int)
	Function bbRefArrayElementPtr:Byte Ptr(sz:Size_T, _array:Object, index:Int)
	
	Function bbRefGetObject:Object(p:Byte Ptr)
	Function bbRefPushObject(p:Byte Ptr, obj:Object)
	Function bbRefInitObject(p:Byte Ptr, obj:Object)
	Function bbRefAssignObject(p:Byte Ptr, obj:Object)
	
	Function bbRefGetObjectClass:Byte Ptr(obj:Object)
	
	Function bbRefGetSuperClass:Byte Ptr(class:Byte Ptr)
	Function bbStringFromRef:String(ref:Byte Ptr)
	Function bbRefArrayNull:Object()
	
	Function bbInterfaceName:Byte Ptr(ifc:Byte Ptr)
	Function bbInterfaceClass:Byte Ptr(ifc:Byte Ptr)
	Function bbObjectImplementsInterfaces:Int(class:Byte Ptr)
	Function bbObjectImplementedCount:Int(class:Byte Ptr)
	Function bbObjectImplementedInterface:Byte Ptr(class:Byte Ptr, index:Int)
	
	Function bbRefClassSuper:Byte Ptr(clas:Byte Ptr)
	Function bbRefClassDebugScope:Byte Ptr(clas:Byte Ptr)
	Function bbRefClassDebugDecl:Byte Ptr(clas:Byte Ptr)
	Function bbDebugScopeDecl:Byte Ptr(scope:Byte Ptr)
	Function bbRefClassDebugScopeName:Byte Ptr(class:Byte Ptr)
	Function bbDebugScopeName:Byte Ptr(scope:Byte Ptr)
	Function bbDebugDeclKind:Int(decl:Byte Ptr)
	Function bbDebugDeclName:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclType:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclConstValue:String(decl:Byte Ptr)
	Function bbDebugDeclFieldOffset:Int(decl:Byte Ptr)
	Function bbDebugDeclVarAddress:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclStructSize:Size_T(decl:Byte Ptr)
	Function bbDebugDeclReflectionWrapper:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclNext:Byte Ptr(decl:Byte Ptr)
	
	Global DebugScopePtrInt128:Byte Ptr = "debugScopePtrInt128"
	Global DebugScopePtrFloat64:Byte Ptr = "debugScopePtrFloat64"
	Global DebugScopePtrFloat128:Byte Ptr = "debugScopePtrFloat128"
	Global DebugScopePtrDouble128:Byte Ptr = "debugScopePtrDouble128"
End Extern





Type TBoxedStruct Final
	
	Field _dataPtr:Byte Ptr
	Field _typeId:TTypeId
	
	Private
	
	Method New() End Method
	
	Public
	
	Method New(structType:TTypeId)
		_typeId = structType
		_dataPtr = MemAlloc(Size_T _typeId._size)
	End Method
	
	Method New(structType:TTypeId, structPtr:Byte Ptr)
		New(structType)
		MemCopy _dataPtr, structPtr, Size_T _typeId._size
	End Method
	
	Method Delete()
		MemFree _dataPtr
	End Method
	
	Method Unbox(targetStructPtr:Byte Ptr)
		MemCopy targetStructPtr, _dataPtr, Size_T _typeId._size
	End Method
	
	Method ToString:String()
		' forward call to the struct's ToString method if defined
		If _typeId._toString Then Return _typeId._toString(_dataPtr) Else Return Super.ToString()
	End Method
	
End Type





Function _Get:Object(p:Byte Ptr, typeId:TTypeId)
	Select typeId
		Case ByteTypeId   Return String.FromInt   ((Byte   Ptr p)[0])
		Case ShortTypeId  Return String.FromInt   ((Short  Ptr p)[0])
		Case IntTypeId    Return String.FromInt   ((Int    Ptr p)[0])
		Case UIntTypeId   Return String.FromUInt  ((UInt   Ptr p)[0])
		Case LongTypeId   Return String.FromLong  ((Long   Ptr p)[0])
		Case ULongTypeId  Return String.FromULong ((ULong  Ptr p)[0])
		Case SizeTTypeId  Return String.FromSizeT ((Size_T Ptr p)[0])
		Case FloatTypeId  Return String.FromFloat ((Float  Ptr p)[0])
		Case DoubleTypeId Return String.FromDouble((Double Ptr p)[0])
		Default
			Select True
				Case typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(FunctionTypeId)
					Return String.FromSizeT((Size_T Ptr p)[0])
				Case typeId.IsStruct()
					Return New TBoxedStruct(typeId, p)
				Case typeId._class <> Null
					Return bbRefGetObject(p)
				Default
					Throw "Unable to get value of this type"
			End Select
	End Select
End Function


Function _Assign(p:Byte Ptr, typeId:TTypeId, value:Object)
	Select typeId
		Case ByteTypeId   If value Then (Byte Ptr   p)[0] = value.ToString().ToInt()    Else (Byte Ptr   p)[0] = Byte   Null
		Case ShortTypeId  If value Then (Short Ptr  p)[0] = value.ToString().ToInt()    Else (Short Ptr  p)[0] = Short  Null
		Case IntTypeId    If value Then (Int Ptr    p)[0] = value.ToString().ToInt()    Else (Int Ptr    p)[0] = Int    Null
		Case UIntTypeId   If value Then (UInt Ptr   p)[0] = value.ToString().ToUInt()   Else (UInt Ptr   p)[0] = UInt   Null
		Case LongTypeId   If value Then (Long Ptr   p)[0] = value.ToString().ToLong()   Else (Long Ptr   p)[0] = Long   Null
		Case ULongTypeId  If value Then (ULong Ptr  p)[0] = value.ToString().ToULong()  Else (ULong Ptr  p)[0] = ULong  Null
		Case SizeTTypeId  If value Then (Size_T Ptr p)[0] = value.ToString().ToSizeT()  Else (Size_T Ptr p)[0] = Size_T Null
		Case FloatTypeId  If value Then (Float Ptr  p)[0] = value.ToString().ToFloat()  Else (Float Ptr  p)[0] = Float  Null
		Case DoubleTypeId If value Then (Double Ptr p)[0] = value.ToString().ToDouble() Else (Double Ptr p)[0] = Double Null
		Default
			If value
				Select True
					Case typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(FunctionTypeId)
						(Size_T Ptr p)[0] = value.ToString().ToSizeT()
						Return
					Case typeId.IsStruct()
						Local box:TBoxedStruct = TBoxedStruct(value)
						If Not box Or box._typeId <> typeId Then Throw "Unable to assign object of incompatible type"
						box.Unbox p
						Return
					Case typeId.IsInterface()
						If bbInterfaceDowncast(value, typeId._interface) <> value Then Throw "Unable to assign object of incompatible type"
					Default
						If bbObjectDowncast(value, typeId._class) <> value Then Throw "Unable to assign object of incompatible type"
				End Select
			Else
				Select True
					Case typeId.IsStruct()
						Throw "Unable to convert Null object to this type"
					Case typeId.Name().Endswith("]")
						value = bbRefArrayNull()
					Case typeId = StringTypeId
						value = ""
				End Select
			EndIf
			bbRefAssignObject p, value
	End Select
End Function


Function _GetBufferSize:Int(funcTypeId:TTypeId, selfTypeId:TTypeId = Null)
	Local p:Byte Ptr Ptr = Null
	For Local t:TTypeId = EachIn [funcTypeId._retType, selfTypeId] + funcTypeId._argTypes
		p = _AdvanceBufferPointer(p, t)
	Next
	Return Int(p)
End Function


Function _AdvanceBufferPointer:Byte Ptr Ptr(p:Byte Ptr Ptr, typeId:TTypeId)
	If typeId <> VoidTypeId Then
		If typeId._size <= SizeOf Byte Ptr Null Then
			p :+ 1
		Else
			p :+ typeId._size / (SizeOf Byte Ptr Null) + (typeId._size Mod (SizeOf Byte Ptr Null) <> 0)
		End If
	End If
	Return p
End Function


Function _Invoke:Object(reflectionWrapper(buf:Byte Ptr Ptr), retType:TTypeId, argTypes:TTypeId[], args:Object[], bufferSize:Int)
	Local buf:Byte Ptr[bufferSize / (SizeOf Byte Ptr Null)]
	Local bufPtr:Byte Ptr Ptr = Byte Ptr Ptr buf
	
	bufPtr = _AdvanceBufferPointer(bufPtr, retType)
	For Local a:Int = 0 Until argTypes.Length
		_Assign bufPtr, argTypes[a], args[a]
		bufPtr = _AdvanceBufferPointer(bufPtr, argTypes[a])
	Next
	bufPtr = Byte Ptr Ptr buf
	
	reflectionWrapper bufPtr
	
	If retType <> VoidTypeId Then Return _Get(bufPtr, retType)
End Function


Function TypeTagForId$(id:TTypeId)
	' TODO: extern type tags (#, *#)
	Select id
		Case ByteTypeId      Return "b"
		Case ShortTypeId     Return "s"
		Case IntTypeId       Return "i"
		Case UIntTypeId      Return "u"
		Case LongTypeId      Return "l"
		Case ULongTypeId     Return "y"
		Case SizeTTypeId     Return "t"
		Case FloatTypeId     Return "f"
		Case DoubleTypeId    Return "d"
		Case StringTypeId    Return "$"
		Case PointerTypeId   Return "*"
		Case FunctionTypeId  Return "("
		Case VoidTypeId      Return ""
		? Win32
		Case LParamTypeId    Return "X"
		Case WParamTypeId    Return "W"
		? x64
		Case Int128TypeId    Return "j"
		Case Float64TypeId   Return "h"
		Case Float128TypeId  Return "k"
		Case Double128TypeId Return "m"
		?
	End Select
	Select True
		Case id.ExtendsType(ArrayTypeId)
			Return "[]" + TypeTagForId(id._elementType)
		Case id.ExtendsType(PointerTypeId)
			Return "*" + TypeTagForId(id._elementType)
		Case id.ExtendsType(FunctionTypeId)
			Local s:String
			For Local t:TTypeId = EachIn id._argTypes
				If s Then s :+ ", "
				s :+ TypeTagForId(t)
			Next
			s = "(" + s + ")"
			If id._retType Then s :+ TypeTagForId(id._retType)
			Return s
		Case id.ExtendsType(ObjectTypeId)
			Return ":" + id.Name()
		Case id.IsStruct()
			Return "@" + id.Name()
	End Select
	Throw "TypeTagForId error"
End Function

Function TypeIdForTag:TTypeId(ty$)
	Select ty
		Case "b" Return ByteTypeId
		Case "s" Return ShortTypeId
		Case "i" Return IntTypeId
		Case "u" Return UIntTypeId
		Case "l" Return LongTypeId
		Case "y" Return ULongTypeId
		Case "t" Return SizetTypeId
		Case "f" Return FloatTypeId
		Case "d" Return DoubleTypeId
		Case "$" Return StringTypeId
		Case "*" Return PointerTypeId
		Case "(" Return FunctionTypeId
		Case ""  Return VoidTypeId
		? Win32
		Case "X" Return LParamTypeId
		Case "W" Return WParamTypeId
		? x64
		Case "j" Return Int128TypeId
		Case "h" Return Float64TypeId
		Case "k" Return Float128TypeId
		Case "m" Return Double128TypeId
		?
	End Select
	Select True
		Case ty.StartsWith("[")
			Local dims:Int = ty.split(", ").length
			ty = ty[ty.Find("]") + 1..]
			Local id:TTypeId = TypeIdForTag(ty)
			If id Then
				id._arrayTypes = Null
				id = id.ArrayType(dims)
			End If
			Return id
		Case ty.StartsWith(":") Or ty.StartsWith("@")
			ty = ty[1..]
			Local i:Int = ty.FindLast(".")
			If i <> -1 ty = ty[i + 1..]
			Return TTypeId.ForName(ty)
		Case ty.StartsWith("*")
			ty = ty[1..]
			Local id:TTypeId = TypeIdForTag(ty)
			If id Then
				id._pointerType = Null
				id = id.PointerType()
			EndIf
			Return id
		Case ty.StartsWith("(")
			Local idx:Int
			Local p:Int = 1
			For idx = 1 Until ty.Length
				If ty[idx] = "("[0] Then p :+ 1 Else If ty[idx] = ")"[0] Then p :- 1
				If p = 0 Then Exit
			Next
			Local t:String[] = [ty[1..idx], ty[idx + 1..]]
			Local retType:TTypeId = TypeIdForTag(t[1]), argTypes:TTypeId[]
			If t[0].length > 0 Then
				Local i:Int
				Local b:Int
				Local q:String = t[0]
				Local args:TList = New TList
				While i < q.length
					Select q[i]
						Case Asc(", ")
							args.AddLast q[b..i]
							i :+ 1
							b = i
						Case Asc("[")
							i :+ 1
							While i < q.length And q[i] = Asc(", ")
								i :+ 1
							Wend
						Case Asc("(")
							Local level:Int = 1
							i:+1
							While i < q.Length
								If q[i] = Asc(", ") Then
									If level = 0 Then 
										Exit
									End If
								Else If q[i] = Asc(")") Then
									level :- 1
								Else If q[i] = Asc("(") Then 
									level :+ 1
								EndIf
								i :+ 1
							Wend
						Default
							i :+ 1
					End Select
				Wend
				If b < q.Length Then args.AddLast q[b..]
				
				argTypes = New TTypeId[args.Count()]
				
				i = 0
				For Local s:String = EachIn args
					argTypes[i] = TypeIdForTag(s)
					If Not argTypes[i] Then argTypes[i] = ObjectTypeId
					i :+ 1
				Next
			End If
			If Not retType Then retType = ObjectTypeId
			'retType._functionType = Null
			Return retType.FunctionType(argTypes)
	End Select
	Throw "TypeIdForTag error: ~q" + ty + "~q"
End Function

Const MODIFIER_PROTECTED:Int = $001
Const MODIFIER_PRIVATE:Int   = $002
Const MODIFIER_ABSTRACT:Int  = $010
Const MODIFIER_FINAL:Int     = $020
Const MODIFIER_READ_ONLY:Int = $100

Function ModifiersForTag:Int(modifierString:String)
	Local modifiers:Int
	If modifierString.Contains("P") Then modifiers :| MODIFIER_PRIVATE
	If modifierString.Contains("Q") Then modifiers :| MODIFIER_PROTECTED
	If modifierString.Contains("A") Then modifiers :| MODIFIER_ABSTRACT
	If modifierString.Contains("F") Then modifiers :| MODIFIER_FINAL
	If modifierString.Contains("R") Then modifiers :| MODIFIER_READ_ONLY
	Return modifiers
End Function

Function ExtractMetaData$(meta$, key$)
	If Not key Return meta
	Local i:Int = 0
	While i<meta.length
		Local e:Int = meta.Find(" = ", i)
		If e = -1 Throw "Malformed meta data"
		Local k$ = meta[i..e], v$
		i = e+1
		If i<meta.length And meta[i] = Asc("~q")
			i:+1
			Local e:Int = meta.Find("~q", i)
			If e = -1 Throw "Malformed meta data"
			v = meta[i..e]
			i = e+1
		Else
			Local e:Int = meta.Find(" ", i)
			If e = -1 e = meta.length
			v = meta[i..e]
			i = e
		EndIf
		If k = key Return v
		If i<meta.length And meta[i] = Asc(" ") i:+1
	Wend
End Function

Function TypeListsIdentical:Int(a1:TTypeId[], a2:TTypeId[])
	If a1.Length <> a2.Length Then Return False
	For Local i:Int = 0 Until a1.Length
		If a1[i] <> a2[i] Then Return False
	Next
	Return True
End Function

Function ArgTypesIdentical:Int(f1:TFunction, f2:TFunction)
	Return TypeListsIdentical(f1.ArgTypes(), f2.ArgTypes())
End Function

Function ArgTypesIdentical:Int(m1:TMethod, m2:TMethod)
	Return TypeListsIdentical(m1.ArgTypes(), m2.ArgTypes())
End Function

Function NameAndArgTypesIdentical:Int(f1:TFunction, f2:TFunction)
	Return f1.Name().ToLower() = f2.Name().ToLower() And ArgTypesIdentical(f1, f2)
End Function

Function NameAndArgTypesIdentical:Int(m1:TMethod, m2:TMethod)
	Return m1.Name().ToLower() = m2.Name().ToLower() And ArgTypesIdentical(m1, m2)
End Function

Function SignaturesIdentical:Int(f1:TFunction, f2:TFunction)
	Return NameAndArgTypesIdentical(f1, f2) And f1.ReturnType() = f2.ReturnType()
End Function

Function SignaturesIdentical:Int(m1:TMethod, m2:TMethod)
	Return NameAndArgTypesIdentical(m1, m2) And m1.ReturnType() = m2.ReturnType()
End Function



Public

Rem
bbdoc: Primitive Byte type ID
End Rem
Global ByteTypeId:TTypeId = New TTypeId.Init("Byte", SizeOf Byte Null)

Rem
bbdoc: Primitive Short type ID
End Rem
Global ShortTypeId:TTypeId = New TTypeId.Init("Short", SizeOf Short Null)

Rem
bbdoc: Primitive Int type ID
End Rem
Global IntTypeId:TTypeId = New TTypeId.Init("Int", SizeOf Int Null)

Rem
bbdoc: Primitive UInt type ID
End Rem
Global UIntTypeId:TTypeId = New TTypeId.Init("UInt", SizeOf UInt Null)

Rem
bbdoc: Primitive Long type ID
End Rem
Global LongTypeId:TTypeId = New TTypeId.Init("Long", SizeOf Long Null)

Rem
bbdoc: Primitive ULong type ID
End Rem
Global ULongTypeId:TTypeId = New TTypeId.Init("ULong", SizeOf ULong Null)

Rem
bbdoc: Primitive Size_T type ID
End Rem
Global SizeTTypeId:TTypeId = New TTypeId.Init("Size_T", SizeOf Size_T Null)

Rem
bbdoc: Primitive Float type ID
End Rem
Global FloatTypeId:TTypeId = New TTypeId.Init("Float", SizeOf Float Null)

Rem
bbdoc: Primitive Double type ID
End Rem
Global DoubleTypeId:TTypeId = New TTypeId.Init("Double", SizeOf Double Null)

Rem
bbdoc: Object type ID
End Rem
Global ObjectTypeId:TTypeId = New TTypeId.Init("Object", SizeOf Byte Ptr Null, bbRefObjectClass())

Rem
bbdoc: String type ID
End Rem
Global StringTypeId:TTypeId = New TTypeId.Init("String", SizeOf Byte Ptr Null, bbRefStringClass(), ObjectTypeId)

? Win32
Rem
bbdoc: WinAPI LPARAM type ID
about: Only available on Windows.
End Rem
Global LParamTypeId:TTypeId = New TTypeId.Init("LParam", SizeOf LParam Null)

Rem
bbdoc: WinAPI WPARAM type ID
about: Only available on Windows.
End Rem
Global WParamTypeId:TTypeId = New TTypeId.Init("WParam", SizeOf WParam Null)
?

? x64
Rem
bbdoc: Intrinsic Int128 type ID
about: Only available on x64.
End Rem
Global Int128TypeId:TTypeId = New TTypeId.InitStruct(DebugScopePtrInt128)

Rem
bbdoc: Intrinsic Float64 type ID
about: Only available on x64.
End Rem
Global Float64TypeId:TTypeId = New TTypeId.InitStruct(DebugScopePtrFloat64)

Rem
bbdoc: Intrinsic Float128 type ID
about: Only available on x64.
End Rem
Global Float128TypeId:TTypeId = New TTypeId.InitStruct(DebugScopePtrFloat128)

Rem
bbdoc: Intrinsic Double128 type ID
about: Only available on x64.
End Rem
Global Double128TypeId:TTypeId = New TTypeId.InitStruct(DebugScopePtrDouble128)
?

Rem
bbdoc: Primitive void type ID<br>Only used as a function/method return type
End Rem
Global VoidTypeId:TTypeId = New TTypeId.Init("", 0)

Rem
bbdoc: Mock array base type ID
End Rem
Global ArrayTypeId:TTypeId = New TTypeId.Init("Null[]", SizeOf Byte Ptr Null, bbRefArrayClass(), ObjectTypeId)

Rem
bbdoc: Mock pointer base type ID
End Rem
Global PointerTypeId:TTypeId = New TTypeId.Init("Ptr", SizeOf Byte Ptr Null)

Rem
bbdoc: Mock function/method base type ID
End Rem
Global FunctionTypeId:TTypeId = New TTypeId.Init("Null()", SizeOf Byte Ptr Null)



Rem
bbdoc: Type member
about: Common base type of TField, TGlobal, TConstant, TMethod and TFunction
End Rem
Type TMember Abstract
	
	Rem
	bbdoc: Get member name
	End Rem
	Method Name:String()
		Return _name
	End Method
	
	Rem
	bbdoc: Get member type
	End Rem	
	Method TypeId:TTypeId()
		Return _typeId
	End Method
	
	Rem
	bbdoc: Determine if this member has the "Public" access modifier
	End Rem	
	Method IsPublic:Int()
		Return Not (_modifiers & (MODIFIER_PROTECTED | MODIFIER_PRIVATE))
	End Method
	
	Rem
	bbdoc: Determine if this member has the "Protected" access modifier
	End Rem	
	Method IsProtected:Int()
		Return _modifiers & MODIFIER_PROTECTED
	End Method
	
	Rem
	bbdoc: Determine if this member has the "Private" access modifier
	End Rem	
	Method IsPrivate:Int()
		Return _modifiers & MODIFIER_PRIVATE
	End Method
	
	Rem
	bbdoc: Get member meta data
	End Rem
	Method MetaData:String(key:String = "")
		Return ExtractMetaData(_meta, key)
	End Method
	
	Field _name$, _typeId:TTypeId, _meta$, _modifiers%
	
End Type



Rem
bbdoc: Type member constant
EndRem
Type TConstant Extends TMember
	
	Private
	
	Method Init:TConstant(name$, typeId:TTypeId, modifiers%, meta$, str$)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		_meta = meta
		_string = str
		Return Self
	EndMethod
	
	Public
	
	Rem
	bbdoc: Get constant value
	EndRem
	Method Get:Object()
		Return GetString()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @String
	EndRem
	Method GetString:String()
		Return _string
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Int
	EndRem
	Method GetInt:Int()
		Return GetString().ToInt()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Long
	EndRem	
	Method GetLong:Long()
		Return GetString().ToLong()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Size_T
	EndRem	
	Method GetSizeT:Size_T()
		Return GetString().ToSizeT()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Float
	EndRem	
	Method GetFloat:Int()
		Return GetString().ToFloat()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Double
	EndRem	
	Method GetDouble:Int()
		Return GetString().ToDouble()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @{Byte Ptr}
	EndRem
	Method GetPointer:Byte Ptr()
		Return Byte Ptr GetString().ToSizeT()
	EndMethod
	
	Field _string:String
	
EndType



Rem
bbdoc: Type member field
End Rem
Type TField Extends TMember
	
	Private
	
	Method Init:TField(name$, typeId:TTypeId, modifiers%, meta$, index%)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		_meta = meta
		_index = index
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Determine if field is read-only
	End Rem	
	Method IsReadOnly:Int()
		Return _modifiers & MODIFIER_READ_ONLY
	End Method
	
	Rem
	bbdoc: Get field value
	End Rem
	Method Get:Object(obj:Object)
		Return _Get(bbRefFieldPtr(obj, _index), _typeId)
	End Method
	
	Rem
	bbdoc: Get field value as @String
	End Rem
	Method GetString:String(obj:Object)
		Return String(Get(obj))
	End Method
	
	Rem
	bbdoc: Get field value as @Int
	End Rem
	Method GetInt:Int(obj:Object)
		Return GetString(obj).ToInt()
	End Method
	
	Rem
	bbdoc: Get field value as @Long
	End Rem
	Method GetLong:Long(obj:Object)
		Return GetString(obj).ToLong()
	End Method
	
	Rem
	bbdoc: Get field value as @Size_T
	End Rem
	Method GetSizeT:Size_T(obj:Object)
		Return GetString(obj).ToSizeT()
	End Method
	
	Rem
	bbdoc: Get field value as @Float
	End Rem
	Method GetFloat:Float(obj:Object)
		Return GetString(obj).ToFloat()
	End Method
	
	Rem
	bbdoc: Get field value as @Double
	End Rem
	Method GetDouble:Double(obj:Object)
		Return GetString(obj).ToDouble()
	End Method
	
	Rem
	bbdoc: Get field value as @{Byte Ptr}
	EndRem
	Method GetPointer:Byte Ptr(obj:Object)
		Return Byte Ptr GetString(obj).ToSizeT()
	EndMethod
	
	Rem
	bbdoc: Get field value as struct
	about: @targetPtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method GetStruct(obj:Object, targetPtr:Byte Ptr)
		If Not _typeId.IsStruct Then Throw "Field does not have a struct type"
		MemCopy targetPtr, bbRefFieldPtr(obj, _index), Size_T _typeId._size
	EndMethod
	
	Rem
	bbdoc: Set field value
	End Rem
	Method Set(obj:Object, value:Object)
		_Assign bbRefFieldPtr(obj, _index), _typeId, value
	End Method
	
	Rem
	bbdoc: Set field value from @String
	End Rem
	Method SetString(obj:Object, value:String)
		Set obj, value
	End Method
	
	Rem
	bbdoc: Set field value from @Int
	End Rem
	Method SetInt(obj:Object, value:Int)
		SetString obj, String.FromInt(value)
	End Method
	
	Rem
	bbdoc: Set Field value from @Long
	End Rem
	Method SetLong(obj:Object, value:Long)
		SetString obj, String.FromLong(value)
	End Method
		
	Rem
	bbdoc: Set field value from @Size_T
	End Rem
	Method SetSizeT(obj:Object, value:Size_T )
		SetString obj, String.FromSizeT(value)
	End Method
	
	Rem
	bbdoc: Set field value from @Float
	End Rem
	Method SetFloat(obj:Object, value:Float)
		SetString obj, String.FromFloat(value)
	End Method
	
	Rem
	bbdoc: Set field value from @Double
	End Rem
	Method SetDouble(obj:Object, value:Double)
		SetString obj, String.FromDouble(value)
	End Method
	
	Rem
	bbdoc: Set field value from @{Byte Ptr}
	EndRem
	Method SetPointer(obj:Object, value:Byte Ptr)
		SetSizeT obj, Size_T value
	EndMethod
	
	Rem
	bbdoc: Set field value from struct
	about: @valuePtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method SetStruct(obj:Object, structPtr:Byte Ptr)
		If Not _typeId.IsStruct Then Throw "Field does not have a struct type"
		MemCopy bbRefFieldPtr(obj, _index), structPtr, Size_T _typeId._size
	EndMethod
	
	Rem
	bbdoc: Invoke field value
	about: Field type must be a function pointer.
	EndRem	
	Method Invoke:Object(obj:Object, args:Object[] = Null)
		If Not _typeId.ExtendsType(FunctionTypeId) Then Throw "Value type ID is not a function type"
		If args.Length <> _typeId.argTypes.Length Then Throw "Function invoked with wrong number of arguments"
		Throw "Not implemented yet"
		'TODO
'		Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T bbRefFieldPtr(obj, _index))] + args, _invokeBufferSize)
	End Method
	
	Field _index%
	
End Type



Rem
bbdoc: Type member global variable
End Rem
Type TGlobal Extends TMember
	
	Private
	
	Method Init:TGlobal(name$, typeId:TTypeId, modifiers%, meta$, ref:Byte Ptr)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		_meta = meta
		_ref = ref
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Get global value
	End Rem
	Method Get:Object()
		Return _Get(_ref, _typeId)
	End Method
	
	Rem
	bbdoc: Get global value as @String
	End Rem
	Method GetString:String()
		Return String(Get())
	End Method
	
	Rem
	bbdoc: Get global value as @Int
	End Rem
	Method GetInt:Int()
		Return GetString().ToInt()
	End Method
	
	Rem
	bbdoc: Get global value as @Long
	End Rem
	Method GetLong:Long()
		Return GetString().ToLong()
	End Method
	
	Rem
	bbdoc: Get global value as @Size_T
	End Rem
	Method GetSizeT:Size_T()
		Return GetString().ToSizeT()
	End Method
	
	Rem
	bbdoc: Get global value as @Float
	End Rem
	Method GetFloat:Float()
		Return GetString().ToFloat()
	End Method
	
	Rem
	bbdoc: Get global value as @Double
	End Rem
	Method GetDouble:Double()
		Return GetString().ToDouble()
	End Method
	
	Rem
	bbdoc: Get global value as @{Byte Ptr}
	EndRem
	Method GetPointer:Byte Ptr()
		Return Byte Ptr GetString().ToSizeT()
	EndMethod
	
	Rem
	bbdoc: Get global value as struct
	about: @targetPtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method GetStruct(obj:Object, targetPtr:Byte Ptr)
		If Not _typeId.IsStruct Then Throw "Global does not have a struct type"
		MemCopy targetPtr, _ref, Size_T _typeId._size
	EndMethod
	
	Rem
	bbdoc: Set global value
	End Rem
	Method Set(value:Object)
		_Assign _ref, _typeId, value
	End Method
	
	Rem
	bbdoc: Set global value from @String
	End Rem
	Method SetString(value:String)
		Set value
	End Method
	
	Rem
	bbdoc: Set global value from @Int
	End Rem
	Method SetInt(value:Int)
		SetString String.FromInt(value)
	End Method
	
	Rem
	bbdoc: Set global value from @Long
	End Rem
	Method SetLong(value:Long)
		SetString String.FromLong(value)
	End Method
	
	Rem
	bbdoc: Set global value from @Size_T
	End Rem
	Method SetSizeT(value:Size_T)
		SetString String.FromSizeT(value)
	End Method
	
	Rem
	bbdoc: Set global value from @Float
	End Rem
	Method SetFloat(value:Float)
		SetString String.FromFloat(value)
	End Method
	
	Rem
	bbdoc: Set global value from @Double
	End Rem
	Method SetDouble(value:Double)
		SetString String.FromDouble(value)
	End Method
	
	Rem
	bbdoc: Set global value from @{Byte Ptr}
	EndRem
	Method SetPointer(value:Byte Ptr)
		SetSizeT Size_T value
	EndMethod
	
	Rem
	bbdoc: Set field value from struct
	about: @valuePtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method SetStruct(obj:Object, valuePtr:Byte Ptr)
		If Not _typeId.IsStruct Then Throw "Global does not have a struct type"
		MemCopy _ref, valuePtr, Size_T _typeId._size
	EndMethod
	
	Rem
	bbdoc: Invoke global value
	about: Global type must be a function pointer.
	EndRem	
	Method Invoke:Object(args:Object[] = Null)
		If Not _typeId.ExtendsType(FunctionTypeId) Then Throw "Value type ID is not a function type"
		If args.Length <> _typeId.argTypes.Length Then Throw "Function invoked with wrong number of arguments"
		' TODO
		Throw "Not implemented yet"
'		Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T _ref)] + args, _invokeBufferSize)
	End Method
	
	Field _ref:Byte Ptr
	
End Type



Rem
bbdoc: Type member function
EndRem
Type TFunction Extends TMember
	
	Private
	
	Method Init:TFunction(name$, typeId:TTypeId, modifiers%, meta$, ref:Byte Ptr, invokeRef:Byte Ptr)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		_meta = meta
		_ref = ref
		_invokeRef = invokeRef
		_invokeBufferSize = _GetBufferSize(typeId)
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Determine if function is abstract
	End Rem	
	Method IsAbstract:Int()
		Return _modifiers & MODIFIER_ABSTRACT
	End Method
	
	Rem
	bbdoc: Determine if function is final
	End Rem	
	Method IsFinal:Int()
		Return _modifiers & MODIFIER_FINAL
	End Method
	
	Rem
	bbdoc: Get function arg types
	End Rem
	Method ArgTypes:TTypeId[]()
		Return _typeId._argTypes
	End Method
	
	Rem
	bbdoc: Get function return type
	End Rem
	Method ReturnType:TTypeId()
		Return _typeId._retType
	End Method
	
	Rem
	bbdoc: Get function pointer
	EndRem
	Method FunctionPtr:Byte Ptr()
		Return _ref
	End Method
	
	Rem
	bbdoc: Invoke function
	EndRem	
	Method Invoke:Object(args:Object[] = Null)
		If args.Length <> _typeId.argTypes.Length Then Throw "Function invoked with wrong number of arguments"
		Return _Invoke(_invokeRef, _typeId._retType, _typeId._argTypes, args, _invokeBufferSize)
	End Method
	
	Field _ref:Byte Ptr
	Field _invokeRef:Byte Ptr
	Field _invokeBufferSize:Int
	
EndType

Rem
bbdoc: Type member method
End Rem
Type TMethod Extends TMember
	
	Private
	
	Method Init:TMethod(name$, typeId:TTypeId, modifiers%, meta$, ref:Byte Ptr, invokeRef:Byte Ptr, selfTypeId:TTypeId)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		_meta = meta
		_ref = ref
		_invokeRef = invokeRef
		_invokeBufferSize = _GetBufferSize(typeId, selfTypeId)
		_invokeArgTypes = [selfTypeId]+typeId._argTypes
		_selfTypeId = selfTypeId
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Determine if method is abstract
	End Rem	
	Method IsAbstract:Int()
		Return _modifiers & MODIFIER_ABSTRACT
	End Method
	
	Rem
	bbdoc: Determine if method is final
	End Rem	
	Method IsFinal:Int()
		Return _modifiers & MODIFIER_FINAL
	End Method
	
	Rem
	bbdoc: Get method arg types
	End Rem
	Method ArgTypes:TTypeId[]()
		Return _typeId._argTypes
	End Method
	
	Rem
	bbdoc: Get method return type
	End Rem
	Method ReturnType:TTypeId()
		Return _typeId._retType
	End Method
	
	'Rem
	'bbdoc: Get function pointer
	'EndRem
	Method FunctionPtr:Byte Ptr()
		Return _ref
	End Method
	
	Rem
	bbdoc: Invoke method
	End Rem
	Method Invoke:Object(obj:Object, args:Object[] = Null)
		If Not obj Then Throw "Unable to invoke method on Null object"
		If _selfTypeId._elementType And _selfTypeId._elementType.IsStruct() Then
			Local box:TBoxedStruct = TBoxedStruct(obj)
			If (Not box) Or box._typeId <> _selfTypeId._elementType Then Throw "Unable to invoke method on this object"
			If args.Length <> _typeId.argTypes.Length Then Throw "Method invoked with wrong number of arguments"	
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T box._dataPtr)] + args, _invokeBufferSize)
		Else
			If args.Length <> _typeId.argTypes.Length Then Throw "Method invoked with wrong number of arguments"
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [obj] + args, _invokeBufferSize)
		End If
	End Method
	
	Field _selfTypeId:TTypeId
	Field _ref:Byte Ptr
	Field _invokeRef:Byte Ptr
	Field _invokeBufferSize:Int
	Field _invokeArgTypes:TTypeId[]
	
End Type

Rem
bbdoc: Type ID
about: Represents a type. Type IDs can be compared for equality to find out if two types are equal.
End Rem
Type TTypeId Extends TMember
	
	Rem
	bbdoc: Get super type
	about: When called on an interface type ID, this method will always return @Object.
	To get the super interfaces extended by an interface, use @Interfaces.
	End Rem	
	Method SuperType:TTypeId()
		Return _super
	End Method
	
	Rem
	bbdoc: Get list of implemented interfaces (of a class) or super interfaces (of an interface).
	End Rem
	Method Interfaces:TList(list:TList = Null)
		If Not list Then list = New TList
		If _interfaces Then
			For Local i:TTypeId = EachIn _interfaces
				list.AddLast i
			Next
		End If
		Return list
	End Method
	
	Rem
	bbdoc: Get array type with this element type
	End Rem
	Method ArrayType:TTypeId(dims:Int = 1)
		If dims <= 0 Then Throw "Number of array dimensions must be positive"
		' TODO: thread safety
		If _arrayTypes.Length <= dims Then
			_arrayTypes = _arrayTypes[..dims + 1]
		Else If _arrayTypes[dims] Then
			Return _arrayTypes[dims]
		End If
		
		Local commas:String
		For Local i:Int = 1 Until dims
			commas :+ ","
		Next
		Local t:TTypeId = New TTypeId.Init(_name + "[" + commas + "]", ArrayTypeId._size, bbRefArrayClass())
		t._elementType = Self
		t._dimensions = dims
		If _super Then
			t._super = _super.ArrayType()
		Else
			t._super = ArrayTypeId
		End If
		_arrayTypes[dims] = t
		Return t
	End Method
	
	Rem
	bbdoc: Get element type
	End Rem
	Method ElementType:TTypeId()
		If Not _elementType Then Throw "Type ID is not an array or pointer type"
		Return _elementType
	End Method
	
	Rem
	bbdoc: Get number of array dimensions
	End Rem
	Method Dimensions:Int()
		If (Not _elementType) Or (Not _class) Throw "Type ID is not an array type"
		Return _dimensions
	End Method
	
	Rem
	bbdoc: Get pointer type with this element type
	End Rem
	Method PointerType:TTypeId()
		' TODO: thread safety
		If Not _pointerType Then
			Local t:TTypeId = New TTypeId.Init(_name + " Ptr", PointerTypeId._size)
			t._elementType = Self
			If _super Then
				t._super = _super.PointerType()
			Else
				t._super = PointerTypeId
			EndIf
			_pointerType = t
		EndIf
		Return _pointerType
	End Method
	
	Rem
	bbdoc: Get function type with this return type
	End Rem
	Method FunctionType:TTypeId(argTypes:TTypeId[] = Null)
		' TODO: thread safety
		If _functionTypes.Length <= argTypes.Length Then
			_functionTypes = _functionTypes[..argTypes.Length + 1]
		Else If _functionTypes[argTypes.Length] Then
			#FindFunctionType
			For Local t:TTypeId = EachIn _functionTypes[argTypes.Length]
				For Local a:Int = 0 Until argTypes.Length
					If t._argTypes[a] <> argTypes[a] Then Continue FindFunctionType
				Next
				Return t
			Next
		End If
		
		Local argsStr:String
		For Local arg:TTypeId = EachIn argTypes
			If argsStr Then argsStr :+ ", "
			argsStr :+ arg.Name()
		Next
		Local t:TTypeId = New TTypeId.Init(_name + "(" + argsStr + ")", FunctionTypeId._size)
		t._retType = Self
		t._argTypes = argTypes
		'If _super Then
		'	t._super = _super.FunctionType(argTypes)
		'Else
			t._super = FunctionTypeId
		'EndIf
		If Not _functionTypes[argTypes.Length] Then _functionTypes[argTypes.Length] = New TList
		_functionTypes[argTypes.Length].AddLast t
		Return t
	End Method
	
	Rem
	bbdoc: Get function return type
	End Rem
	Method ReturnType:TTypeId()
		If Not _retType Then Throw "Type ID is not a function type"
		Return _retType
	End Method
		
	Rem
	bbdoc: Get function argument types
	End Rem
	Method ArgTypes:TTypeId[]()
		If Not _retType Then Throw "Type ID is not a function type"
		Return _argTypes
	End Method		
	
	Rem
	bbdoc: Determine if this type extends, implements, or equals another type
	End Rem
	Method ExtendsType:Int(typeId:TTypeId)
		If Self = typeId Then Return True
		If _interfaces Then
			For Local ifc:TTypeId = EachIn _interfaces
				If ifc = typeId Then Return True
			Next
		End If
		Local superType:TTypeId = _super
		While superType
			If superType = typeId Then Return True
			superType = superType._super
		Wend
		Return False
	End Method
	
	Rem
	bbdoc: Get list of derived types
	End Rem
	Method DerivedTypes:TList(list:TList = Null)
		If Not list Then list = New TList
		If _derived Then
			For Local d:TTypeId = EachIn _derived
				list.AddLast d
			Next
		End If
		Return list
	End Method

	Rem
	bbdoc: Create a new object
	about: Creates a new instance of this type with the default constructor.
	Can be used to create objects and struct instances.
	This method can not be used on array type IDs. To create an array, use @NewArray instead.
	End Rem	
	Method NewObject:Object()
		If _struct Then
			Return NewObject(_defaultConstructor, Null)
		Else
			If Not _class Then Throw "Unable to create instance of this type"
			If _interface Then Throw "Unable to create instance from interface"
			If _elementType Then Throw "Unable to create array this way"
			Return bbObjectNew(_class)
		End If
	End Method
	
	Rem
	bbdoc: Create a new object with the given constructor
	about: Creates a new instance of this type by calling @constructor, which must be one of the constructors for this type.
	To get a list of available constructors, use FindMethods("New").
	Can be used to create objects and struct instances.
	This method can not be used on array type IDs. To create an array, use @NewArray instead.<br>
	End Rem	
	Method NewObject:Object(constructor:TMethod, args:Object[])
		If _struct Then
			Local box:TBoxedStruct = New TBoxedStruct(Self)
			constructor.Invoke box, args
			Return box
		Else
			If Not _class Then Throw "Unable to create instance of this type"
			If _interface Then Throw "Unable to create instance from interface"
			If _elementType Then Throw "Unable to create array this way"
			' make sure we were actually given a constructor for this class
			If Not constructor Then Throw "Constructor is Null"
			If Not _constructors.Contains(constructor) Then Throw "Method is not a constructor of this type"
			Local o:Object = bbObjectNewNC(_class)
			constructor.Invoke o, args
			Return o
		End If
	End Method
	
	Rem
	bbdoc: Create an object from a struct instance
	about: @structPtr must be a pointer to an instance of the struct type referred to be this type ID.
	returns: A copy of the struct instance, wrapped in an object.
	End Rem
	Method StructToObject:Object(structPtr:Byte Ptr)
		If Not _struct Then Throw "Type ID is not a struct type"
		Return New TBoxedStruct(Self, structPtr)
	End Method
	
	Rem
	bbdoc: Retrieve a struct instance from an object
	about: @targetPtr must be a pointer to a variable of, and @obj contain an instance of, the struct type referred to be this type ID.
	returns: A copy of the struct instance, wrapped in an object.
	End Rem
	Method StructFromObject(targetPtr:Byte Ptr, obj:Object)
		If Not _struct Then Throw "Type ID is not a struct type"
		Local box:TBoxedStruct = TBoxedStruct(obj)
		If Not box Then Throw "Object does not contain a struct instance"
		If box._typeID <> Self Then Throw "Struct instance in object does not match type ID"
		box.Unbox targetPtr
	End Method
	
	Rem
	bbdoc: Determine if this TypeId represents a class.
	End Rem
	Method IsClass:Int()
		Return _class <> Null And _interface = Null
	End Method
	
	Rem
	bbdoc: Determine if this TypeId represents an interface.
	End Rem
	Method IsInterface:Int()
		Return _interface <> Null
	End Method
	
	Rem
	bbdoc: Determine if this TypeId represents a structure.
	End Rem
	Method IsStruct:Int()
		Return _struct <> Null
	End Method
	
	Rem
	bbdoc: Get list of constants
	about: Only returns constants declared in this type, not in super types.
	End Rem
	Method Constants:TList(list:TList = Null)
		If Not list Then list = New TList
		For Local c:TConstant = EachIn _consts
			list.AddLast c
		Next
		Return list
	End Method	
	
	Rem
	bbdoc: Get list of fields
	about: Only returns fields declared in this type, not in super types.
	End Rem
	Method Fields:TList(list:TList = Null)
		If Not list Then list = New TList
		For Local f:TField = EachIn _fields
			list.AddLast f
		Next
		Return list
	End Method
	
	Rem
	bbdoc: Get list of globals
	about: Only returns globals declared in this type, not in super types.
	End Rem
	Method Globals:TList(list:TList = Null)
		If Not list Then list = New TList
		For Local g:TGlobal = EachIn _globals
			list.AddLast g
		Next
		Return list
	End Method

	Rem
	bbdoc: Get list of functions
	about: Only returns functions declared in this type, not in super types.
	EndRem
	Method Functions:TList(list:TList = Null)
		If Not list Then list = New TList
		
		If IsInterface() Or IsStruct() Then
			' nothing to see here, move along
		Else
			For Local func:TFunction = EachIn _functions
				list.AddLast func
			Next
		End If
		
		Return list
	End Method	
	
	Rem
	bbdoc: Get list of methods
	about: Only returns methods declared in this type, not in super types.
	End Rem
	Method Methods:TList(list:TList = Null)
		If Not list Then list = New TList
		
		If IsInterface() Then
			Local superIfcMethods:TList = New TList
			#AddMethods
			For Local meth:TMethod = EachIn _methods
				' do not add the method to the result list if it comes from one of the super interfaces
				For Local superIfc:TTypeId = EachIn _interfaces
					For Local superIfcMeth:TMethod = EachIn superIfc._methods
						If meth._ref = superIfcMeth._ref Then Continue AddMethods
					Next
				Next
				list.AddLast meth
			Next
		Else
			For Local meth:TMethod = EachIn _methods
				list.AddLast meth
			Next
		End If
		
		Return list
	End Method
	
	Rem
	bbdoc: Find a constant by name
	about: Searches type hierarchy for a constant called @name.
	End Rem
	Method FindConstant:TConstant(name:String)
		name = name.ToLower()
		For Local t:TConstant = EachIn _consts
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindConstant(name)
	End Method	
	
	Rem
	bbdoc: Find a field by name
	about: Searches type hierarchy for a field called @name.
	End Rem
	Method FindField:TField(name:String)
		name = name.ToLower()
		For Local t:TField = EachIn _fields
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindField(name)
	End Method
	
	Rem
	bbdoc: Find a global by name
	about: Searches type hierarchy for a global called @name.
	End Rem
	Method FindGlobal:TGlobal(name:String)
		name = name.ToLower()
		For Local t:TGlobal = EachIn _globals
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindGlobal(name)
	End Method
	
	Rem
	bbdoc: Find a function by name
	about: Searches type hierarchy for a function called @name.<br>
	In the case of a tie between multiple overloads of the function, the one declared in the most derived type will be returned. If there is still a tie, the overload declared first in code will be returned.
	EndRem
	Method FindFunction:TFunction(name:String)
		name = name.ToLower()
		For Local t:TFunction = EachIn _functions
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindFunction(name)
	End Method
	
	Rem
	bbdoc: Find a specific overload of a function by name and parameter list
	about: Searches type hierarchy for a function called @name with the specified argument types.<br>
	This can be used to find a specific overload of a function.
	EndRem
	Method FindFunction:TFunction(name:String, argTypes:TTypeId[])
		name = name.ToLower()
		For Local t:TFunction = EachIn _functions
			If t.Name().ToLower() = name And TypeListsIdentical(t.ArgTypes(), argTypes) Return t
		Next
		If _super Return _super.FindFunction(name)
	End Method
	
	Rem
	bbdoc: Find all overloads of a function by name
	about: Searches type hierarchy for a function called @name.<br>
	Same as @FindFunction, except it returns all overloads of the function.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method FindFunctions:TList(name:String, list:TList = Null)
		If Not list Then list = New TList
		
		name = name.ToLower()
		If IsInterface() Or IsStruct() Then
			' nothing to see here, move along
		Else
			Local initialLastLinkL:TLink = list.LastLink()
			If Not initialLastLinkL Then initialLastLinkL = list._head
			' start by looking at this type
			Local tid:TTypeId = Self
			Repeat
				Local firstNewLinkL:TLink = initialLastLinkL.NextLink()
				Local link:TLink = tid._functions.LastLink()
				#AddFunctions
				While link
					' go through every function defined in the type
					Local func:TFunction = TFunction(link.Value())
					link = link.PrevLink()
					
					' check name
					If func.Name().ToLower() <> name Then Continue AddFunctions
					
					' check if it's overridden by something we already added to the result list
					Local linkL:TLink = firstNewLinkL
					While linkL
						Local funcL:TFunction = TFunction(linkL.Value())
						linkL = linkL.NextLink()
						If ArgTypesIdentical(func, funcL) Then Continue AddFunctions ' if so, skip it
					Wend
					
					list.InsertAfterLink func, initialLastLinkL ' otherwise, add it to the result list
				Wend
				
				' repeat with super type
				If (Not tid._super) Or tid._super = tid Then Exit
				tid = tid._super
			Forever
		End If
		
		Return list
	End Method
	
	Rem
	bbdoc: Find a method by name
	about: Searches type hierarchy for a method called @name.<br>
	In the case of a tie between multiple overloads of the method, the one declared in the most derived type will be returned. If there is still a tie, the overload declared first in code will be returned.
	End Rem
	Method FindMethod:TMethod(name:String)
		name = name.ToLower()
		For Local t:TMethod = EachIn _methods
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindMethod(name)
	End Method
	
	Rem
	bbdoc: Find a specific overload of a method by name and parameter list
	about: Searches type hierarchy for a method called @name with the specified argument types.<br>
	This can be used to find a specific overload of a method.
	EndRem
	Method FindMethod:TMethod(name:String, argTypes:TTypeId[])
		name = name.ToLower()
		For Local t:TMethod = EachIn _methods
			If t.Name().ToLower() = name And TypeListsIdentical(t.ArgTypes(), argTypes) Return t
		Next
		If _super Return _super.FindMethod(name)
	End Method
	
	Rem
	bbdoc: Find all overloads of a method by name
	about: Searches type hierarchy for a method called @name.<br>
	Same as @FindMethod, except it returns all overloads of the method.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method FindMethods:TList(name:String, list:TList = Null)
		If Not list Then list = New TList
		
		name = name.ToLower()
		If IsInterface() Or IsStruct() Then
			For Local meth:TMethod = EachIn _methods
				If meth.Name().ToLower() = name Then list.AddLast meth
			Next
		Else
			Local initialLastLinkL:TLink = list.LastLink()
			If Not initialLastLinkL Then initialLastLinkL = list._head
			' start by looking at this type
			Local tid:TTypeId = Self
			Repeat
				Local firstNewLinkL:TLink = initialLastLinkL.NextLink()
				Local link:TLink = tid._methods.LastLink()
				#AddMethods
				While link
					' go through every method defined in the type
					Local meth:TMethod = TMethod(link.Value())
					link = link.PrevLink()
					
					' check name
					If meth.Name().ToLower() <> name Then Continue AddMethods
					
					' check if it's overridden by something we already added to the result list
					Local linkL:TLink = firstNewLinkL
					While linkL
						Local methL:TMethod = TMethod(linkL.Value())
						linkL = linkL.NextLink()
						If ArgTypesIdentical(meth, methL) Then Continue AddMethods ' if so, skip it
					Wend
					list.InsertAfterLink meth, initialLastLinkL ' otherwise, add it to the result list
				Wend
				
				' repeat with super type
				If (Not tid._super) Or tid._super = tid Then Exit
				tid = tid._super
			Forever
		End If
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all constants
	about: Returns a list of all constants in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumConstants:TList(list:TList = Null)
		If Not list Then list = New TList
		For Local i:TTypeId = EachIn _interfaces
			i.EnumConstants list
		Next
		If _super Then _super.EnumConstants list
		For Local t:TConstant = EachIn _consts
			list.AddLast t
		Next
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all fields
	about: Returns a list of all fields in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumFields:TList(list:TList = Null)
		If Not list list = New TList
		If _super _super.EnumFields list
		For Local t:TField = EachIn _fields
			list.AddLast t
		Next
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all globals
	about: Returns a list of all globals in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumGlobals:TList(list:TList = Null)
		If Not list list = New TList
		If _super _super.EnumGlobals list
		For Local t:TField = EachIn _globals
			list.AddLast t
		Next
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all functions
	about: Returns a list of all functions in type hierarchy, excluding ones that have been overridden.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumFunctions:TList(list:TList = Null)
		If Not list Then list = New TList
		
		If IsInterface() Or IsStruct() Then
			' nothing to see here, move along
		Else
			Local initialLastLinkL:TLink = list.LastLink()
			If Not initialLastLinkL Then initialLastLinkL = list._head
			' start by looking at this type
			Local tid:TTypeId = Self
			Repeat
				Local firstNewLinkL:TLink = initialLastLinkL.NextLink()
				Local link:TLink = tid._functions.LastLink()
				#AddFunctions
				While link
					' go through every function defined in the type
					Local func:TFunction = TFunction(link.Value())
					link = link.PrevLink()
					
					' check if it's overridden by something we already added to the result list
					Local linkL:TLink = firstNewLinkL
					While linkL
						Local funcL:TFunction = TFunction(linkL.Value())
						linkL = linkL.NextLink()
						If NameAndArgTypesIdentical(func, funcL) Then Continue AddFunctions ' if so, skip it
					Wend
					
					list.InsertAfterLink func, initialLastLinkL ' otherwise, add it to the result list
				Wend
				
				' repeat with super type
				If (Not tid._super) Or tid._super = tid Then Exit
				tid = tid._super
			Forever
		End If
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all methods
	about: Returns a list of all methods in type hierarchy, excluding ones that have been overridden. Does not include unimplemented methods from interfaces implemented by this type.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumMethods:TList(list:TList = Null)
		If Not list Then list = New TList
		
		If IsInterface() Or IsStruct() Then
			For Local meth:TMethod = EachIn _methods
				list.AddLast meth
			Next
		Else
			Local initialLastLinkL:TLink = list.LastLink()
			If Not initialLastLinkL Then initialLastLinkL = list._head
			' start by looking at this type
			Local tid:TTypeId = Self
			Repeat
				Local firstNewLinkL:TLink = initialLastLinkL.NextLink()
				Local link:TLink = tid._methods.LastLink()
				#AddMethods
				While link
					' go through every method defined in the type
					Local meth:TMethod = TMethod(link.Value())
					link = link.PrevLink()
					
					' check if it's overridden by something we already added to the result list
					Local linkL:TLink = firstNewLinkL
					While linkL
						Local methL:TMethod = TMethod(linkL.Value())
						linkL = linkL.NextLink()
						If NameAndArgTypesIdentical(meth, methL) Then Continue AddMethods ' if so, skip it
					Wend
					list.InsertAfterLink meth, initialLastLinkL ' otherwise, add it to the result list
				Wend
				
				' repeat with super type
				If (Not tid._super) Or tid._super = tid Then Exit
				tid = tid._super
			Forever
		End If
		
		Return list
	End Method
	
	Rem
	bbdoc: Create a new array
	about: This method should only be called on an array type ID.<br>
	If @dims is not specified, this method will create a one-dimensional array with @length elements.
	Otherwise, @length is ignored and a new array with dimensions as specified by @dims is created.
	End Rem
	Method NewArray:Object(length:Int = 0, dims:Int[] = Null)
		If Self = ArrayTypeId Then Throw "Unable to create array of " + Name() + " type"
		If (Not _elementType) Or (Not _class) Throw "TypeID is not an array type"
		Local tag:Byte Ptr = _elementType._typeTag
		If Not tag
			tag = TypeTagForId(_elementType).ToCString()
			_elementType._typeTag = tag
		EndIf
		If Not dims Then
			If _dimensions <> 1 Then Throw "Array dimensions do not match type"
			Return bbArrayNew1D(tag, length)
		Else
			If _dimensions <> dims.Length Then Throw "Array dimensions do not match type"
			Return bbRefArrayCreate(tag, dims)
		End If
	End Method
	
	Rem
	bbdoc: Get length of an array
	End Rem
	Function ArrayLength:Int(_array:Object, dim:Int = 0)
		Return bbRefArrayLength(_array, dim)
	End Function
	
	Rem
	bbdoc: Get the number of dimensions of an array
	End Rem
	Function ArrayDimensions:Int(_array:Object)
		Return bbRefArrayDimensions(_array)
	End Function
	
	Rem
	bbdoc: Get an array element
	about: This method should only be called on the type ID corresponding to the type of the array.
	End Rem
	Method GetArrayElement:Object(_array:Object, index:Int)
		If (Not _elementType) Or (Not _class) Throw "Type ID is not an array type"
		Local p:Byte Ptr = bbRefArrayElementPtr(Size_T _elementType._size, _array, index)
		Return _Get(p, _elementType)
	End Method
	
	Rem
	bbdoc: Set an array element
	about: This method should only be called on the type ID corresponding to the type of the array.
	End Rem
	Method SetArrayElement(_array:Object, index:Int, value:Object)
		If (Not _elementType) Or (Not _class) Throw "Type ID is not an array type"
		Local p:Byte Ptr = bbRefArrayElementPtr(Size_T _elementType._size, _array, index)
		_Assign p, _elementType, value
	End Method
	
	Rem
	bbdoc: Size of the type in bytes
	about: For reference types, such as classes and interfaces, this function will return the size of the reference (equal to the size of PointerTypeId), not that of the underlying type.
	End Rem
	Method Size:Int()
		Return _size
	End Method
	
	Rem
	bbdoc: Get type by name
	End Rem
	Function ForName:TTypeId(name:String)
		_Update
		Return ForName_(name.ToLower())
		
		Function ForName_:TTypeId(name:String)
			name = name.Trim()
			If Not name Then
				Return VoidTypeId
			Else If name.EndsWith("]")
				Local b:Int = name.FindLast("[")
				Local sp:String[] = name[b + 1..name.Length - 1].Split(", ")
				For Local s:String = EachIn sp
					If s.Trim() Then Return Null
				Next
				Local baseType:TTypeId = ForName_(name[..b])
				' check for valid array base types
				If baseType And Not (baseType = ArrayTypeId Or baseType = VoidTypeId Or baseType = FunctionTypeId Or baseType = PointerTypeId) Then
					Return baseType.ArrayType(sp.Length)
				Else
					Return Null
				End If
			' pointers
			Else If name.EndsWith("ptr")
				Local baseType:TTypeId = ForName_(name[..name.length-4])
				' check for valid pointer base types
				If baseType And Not (baseType._class Or baseType = VoidTypeId Or baseType = FunctionTypeId Or baseType = PointerTypeId) Then
					Return baseType.PointerType()
				Else
					Return Null
				End If
			' function pointers
			Else If name.EndsWith(")")
				Local i:Int
				Local depth:Int = 1
				For i = name.Length - 2 To 0 Step -1
					Select name[i]
						Case ")"[0] depth :+ 1 
						Case "("[0] depth :- 1
					End Select
					If depth = 0 Then Exit
				Next
				If depth <> 0 Then Return Null ' unbalanced parentheses
				
				Local retStr:String = name[..i]
				Local returnType:TTypeId
				If Not retStr.Trim() Then returnType = VoidTypeId Else returnType = ForName_(retStr)
				If returnType Then
					Local argListStr:String = name[i + 1..name.Length - 1].Trim()
					If argListStr Then
						' split parameter list
						Local argsStr:String[]' = argListStr.Split(", ")
						Local depthP:Int = 0
						Local depthB:Int = 0
						Local i:Int = 0
						For Local j:Int = 0 Until argListStr.Length
							Select argListStr[j]
								Case "("[0] depthP :+ 1
								Case ")"[0] depthP :- 1
								Case "["[0] depthB :+ 1
								Case "]"[0] depthB :- 1
								Case ", "[0] If depthP = 0 And depthB = 0 Then argsStr :+ [argListStr[i..j]]; i = j + 1
							End Select
						Next
						If depthP <> 0 Or depthB <> 0 Then Return Null ' unbalanced parentheses
						argsStr :+ [argListStr[i..]]
						
						Local argTypes:TTypeId[argsStr.Length]
						For Local a:Int = 0 Until argsStr.Length
							argTypes[a] = ForName_(argsStr[a])
							If Not argTypes[a] Then Return Null
						Next
						
						'returnType._functionType = Null
						Return returnType.FunctionType(argTypes)
					Else
						Return returnType.FunctionType(Null)
					End If
				Else 
					Return Null
				EndIf
			Else
				Return TTypeId(_nameMap.ValueForKey(name))
			EndIf
		End Function
	End Function
	
	Rem
	bbdoc: Get type by object
	End Rem	
	Function ForObject:TTypeId(obj:Object)
		_Update
		Local box:TBoxedStruct = TBoxedStruct(obj)
		If box Then Return box._typeId
		Local class:Byte Ptr = bbRefGetObjectClass(obj)
		If class = ArrayTypeId._class
			If Not bbRefArrayLength(obj) Return ArrayTypeId
			Return TypeIdForTag(bbRefArrayTypeTag(obj)).ArrayType(bbRefArrayDimensions(obj))
		Else
			Return TTypeId(_classMap.ValueForKey(class))
		EndIf
	End Function
	
	Rem
	bbdoc: Get list of all data types currently used in this program
	End Rem
	Function EnumTypes:TList()
		_Update
		Local list:TList = New TList
		For Local t:TTypeId = EachIn _nameMap.Values()
			list.AddLast t
		Next
		Return list
	End Function
	
	Rem
	bbdoc: Get a list of all class types
	about: Does not include array types.
	End Rem
	Function EnumClasses:TList()
		_Update
		Local list:TList = New TList
		For Local t:TTypeId = EachIn _classMap.Values()
			If t._super = ArrayTypeId Then Continue	' filter out Object[]
			list.AddFirst t
		Next
		Return list
	End Function
	
	Rem
	bbdoc: Get a list of all interface types
	End Rem
	Function EnumInterfaces:TList()
		_Update
		Local list:TList = New TList
		For Local t:TTypeId = EachIn _interfaceMap.Values()
			list.AddFirst t
		Next
		Return list
	End Function
	
	Rem
	bbdoc: Get a list of all struct types
	End Rem
	Function EnumStructs:TList()
		_Update
		Local list:TList = New TList
		For Local t:TTypeId = EachIn _structMap.Values()
			list.AddFirst t
		Next
		Return list
	End Function
	
	Private
	
	Method Init:TTypeId(name$, size:Int, class:Byte Ptr = Null, supor:TTypeId = Null)
		_name = name
		_size = size
		_class = class
		_super = supor
		_consts = New TList
		_fields = New TList
		_globals = New TList
		_functions = New TList
		_methods = New TList
		_nameMap.Insert _name.ToLower(), Self
		If class _classMap.Insert class, Self
		Return Self
	End Method
	
	Method InitClass:TTypeId(class:Byte Ptr) ' BBClass*
		Local name$ = String.FromCString(bbRefClassDebugScopeName(class))
		Local meta$
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		_name = name
		_meta = meta
		_class = class
		
		_nameMap.Insert _name.ToLower(), Self
		_classMap.Insert class, Self
		Return Self
	End Method
	
	Method InitInterface:TTypeId(ifc:Byte Ptr) ' BBInterface*
		Local name:String = String.FromCString(bbInterfaceName(ifc))
		Local meta$
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		_name = name
		_meta = meta
		_interface = ifc
		_class = bbInterfaceClass(ifc)
		
		_nameMap.Insert _name.ToLower(), Self
		_interfaceMap.Insert ifc, Self
		_interfaceClassMap.Insert _class, Self
		Return Self
	End Method
	
	Method InitStruct:TTypeId(scope:Byte Ptr) ' BBDebugScope*
		Local name:String = String.FromCString(bbDebugScopeName(scope))
		Local meta$
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		_name = name
		_meta = meta
		_struct = scope
		
		Local p:Byte Ptr = bbDebugScopeDecl(scope)
		While bbDebugDeclKind(p)
			p = bbDebugDeclNext(p)
		Wend
		_size = bbDebugDeclStructSize(p)
		
		_nameMap.Insert _name.ToLower(), Self
		_structMap.Insert scope, Self
		Return Self
	End Method
	
	Function _Update()
		Local ccount:Int
		Local icount:Int
		Local scount:Int
		Local classArray    :Byte Ptr Ptr = bbObjectRegisteredTypes(ccount)      ' BBClass**
		Local interfaceArray:Byte Ptr Ptr = bbObjectRegisteredInterfaces(icount) ' BBInterface**
		Local structArray   :Byte Ptr Ptr = bbObjectRegisteredStructs(scount)    ' BBDebugScope**
		If ccount = _ccount And icount = _icount And scount = _scount Then Return
		
		Local list:TList = New TList
		For Local i:Int = _ccount Until ccount
			list.AddLast New TTypeId.InitClass(classArray[i])
		Next
		For Local i:Int = _icount Until icount
			list.AddLast New TTypeId.InitInterface(interfaceArray[i])
		Next
		For Local i:Int = _scount Until scount
			list.AddLast New TTypeId.InitStruct(structArray[i])
		Next
		
		_ccount = ccount
		_icount = icount
		_scount = scount
		For Local t:TTypeId = EachIn list
			t._Resolve
		Next
	End Function
	
	Method _Resolve()
		If _fields Or ((Not _class) And (Not _struct)) Then Return
		_consts = New TList
		_fields = New TList
		_globals = New TList
		_functions = New TList
		_methods = New TList
		_constructors = New TList
		_interfaces = New TList
		
		Local p:Byte Ptr
		
		If _struct Then
			p = bbDebugScopeDecl(_struct)
		Else
			_super = TTypeId(_classMap.ValueForKey(bbRefClassSuper(_class)))
			If Not _super Then _super = ObjectTypeId
			If Not _super._derived Then _super._derived = New TList
			_super._derived.AddLast Self
			
			p = bbRefClassDebugDecl(_class)
		End If
		
		While bbDebugDeclKind(p)
			Local id$ = String.FromCString(bbDebugDeclName(p))
			Local ty$ = String.FromCString(bbDebugDeclType(p))
			Local meta$
			Local modifierString$
			Local i% = ty.Find("{")
			If i<>-1
				meta = ty[i+1..ty.length-1]
				ty = ty[..i]
			EndIf
			i = ty.Find("|")
			If i<>-1
				modifierString = ty[i+1..ty.length]
				ty = ty[..i]
			EndIf
			
			Select bbDebugDeclKind(p)
				Case 1 ' const
					Local typeId:TTypeId = TypeIdForTag(ty)
					If typeId Then _consts.AddLast New TConstant.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclConstValue(p))
				Case 3 ' field
					Local typeId:TTypeId = TypeIdForTag(ty)
					If typeId Then _fields.AddLast New TField.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclFieldOffset(p))
				Case 4 ' global
					Local typeId:TTypeId = TypeIdForTag(ty)
					If typeId Then _globals.AddLast New TGlobal.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclVarAddress(p))
				Case 6 ' method
					Local typeId:TTypeId = TypeIdForTag(ty)
					If typeId Then
						Local selfTypeId:TTypeId = Self
						If selfTypeId.IsStruct() Then selfTypeId = selfTypeId.PointerType()
						Local meth:TMethod = New TMethod.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclVarAddress(p), bbDebugDeclReflectionWrapper(p), selfTypeId)
						_methods.AddLast meth
						If id = "New" Then
							_constructors.AddLast meth
							If Not typeId._argTypes Then _defaultConstructor = meth
						Else If id.ToLower() = "tostring" And typeId = StringTypeId.FunctionType() Then
							_toString = meth._ref
						End If
					End If
				Case 7 ' function
					Local typeId:TTypeId = TypeIdForTag(ty)
					If typeId Then
						Local func:TFunction = New TFunction.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclVarAddress(p), bbDebugDeclReflectionWrapper(p))
						_functions.AddLast func
					End If
			End Select
			p = bbDebugDeclNext(p)
		Wend
		
		If Not _struct Then
			' implemented interfaces ?
			Local impInt:Int = bbObjectImplementsInterfaces(_class)
			If impInt Then
				Local imps:Int = bbObjectImplementedCount(_class)
				If imps > 0 Then
					For Local i:Int = 0 Until imps
						_interfaces.AddLast(_interfaceMap.ValueForKey(bbObjectImplementedInterface(_class, i)))
					Next
				End If
			End If
		End If
	End Method
	
	Field _class:Byte Ptr ' BBClass*
	Field _interface:Byte Ptr ' BBInterface*
	Field _struct:Byte Ptr ' BBDebugScope*
	
	Field _size:Int = SizeOf Byte Ptr Null ' size of the object reference, not the actual object
	
	Field _consts:TList
	Field _fields:TList
	Field _globals:TList
	Field _functions:TList
	Field _methods:TList
	Field _constructors:TList
	Field _defaultConstructor:TMethod
	Field _toString:String(structPtr:Byte Ptr)
	Field _interfaces:TList
	Field _super:TTypeId
	Field _derived:TList
	Field _typeTag:Byte Ptr
	
	Field _arrayTypes:TTypeId[]
	Field _pointerType:TTypeId
	Field _functionTypes:TList[]
	Field _elementType:TTypeId
	Field _dimensions:Int
	Field _argTypes:TTypeId[]
	Field _retType:TTypeId
	
	Global _nameMap:TMap = New TMap
	Global _ccount:Int, _classMap:TPtrMap = New TPtrMap
	Global _icount:Int, _interfaceMap:TPtrMap = New TPtrMap, _interfaceClassMap:TPtrMap = New TPtrMap
	Global _scount:Int, _structMap:TPtrMap = New TPtrMap
	
End Type


