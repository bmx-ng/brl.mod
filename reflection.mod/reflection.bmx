
SuperStrict

Rem
bbdoc: BASIC/Reflection
End Rem
Module BRL.Reflection

ModuleInfo "Version: 1.12"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.12"
ModuleInfo "History: Metadata keys are now case-insensitive."
ModuleInfo "History: 1.11"
ModuleInfo "History: Fixed longstanding issues and added support for more recent language features (structs, enums, overloading, ...)"
ModuleInfo "History: 1.10"
ModuleInfo "History: Added LongInt and ULongInt primitives."
ModuleInfo "History: 1.09"
ModuleInfo "History: Threading support."
ModuleInfo "History: 1.08"
ModuleInfo "History: Improved metadata retrieval."
ModuleInfo "History: 1.07"
ModuleInfo "History: Primitive field set/get now avoids passing values through String."
ModuleInfo "History: 1.06"
ModuleInfo "History: Cache lower case member names and use map lookup instead of list."
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
Import Collections.PtrMap
Import Collections.StringMap
Import BRL.Threads
Import "reflection.c"



Private

Extern
	Function bbObjectDowncast:Object(o:Object, t:Byte Ptr) = "BBObject* bbObjectDowncast(BBObject*, BBClass*)!"
	Function bbInterfaceDowncast:Object(o:Object, ifc:Byte Ptr) = "BBObject* bbInterfaceDowncast(BBOBJECT , BBINTERFACE)!"
	Function bbObjectRegisteredTypes:Byte Ptr Ptr(count:Int Var) = "BBClass** bbObjectRegisteredTypes(int*)!"
	Function bbObjectRegisteredInterfaces:Byte Ptr Ptr(count:Int Var) = "BBInterface** bbObjectRegisteredInterfaces(int*)!"
	Function bbObjectRegisteredStructs:Byte Ptr Ptr(count:Int Var) = "BBDebugScope** bbObjectRegisteredStructs(int*)!"
	Function bbObjectRegisteredEnums:Byte Ptr Ptr(count:Int Var) = "BBDebugScope** bbObjectRegisteredEnums(int*)!"
	Global bbRefArrayClass:Byte Ptr
	Global bbRefStringClass:Byte Ptr
	Global bbRefObjectClass:Byte Ptr
	
	Function bbObjectNew:Object(class:Byte Ptr) = "BBObject* bbObjectNew(BBClass*)!"
	Function bbObjectNewNC:Object(class:Byte Ptr) = "BBObject* bbObjectNewNC(BBClass*)!"
	Function bbArrayNew1D:Object(typeTag:Byte Ptr, length:Int) = "BBArray* bbArrayNew1D(const char*, int)!"
	Function bbArraySlice:Object( typeTag:Byte Ptr, _array:Object, _start:Int, _end:Int)="BBArray* bbArraySlice(const char *, BBArray*, int, int)!"
	Function bbRefArrayCreate:Object(typeTag:Byte Ptr, dims:Int[])
	
	Function bbRefArrayLength:Int(array:Object, dim:Int = 0)
	Function bbRefArrayTypeTag$(array:Object)
	Function bbRefArrayDimensions:Int(array:Object)
	
	Function bbRefObjectFieldPtr:Byte Ptr(obj:Object, offset:Size_T)
	Function bbRefArrayElementPtr:Byte Ptr(sz:Size_T, _array:Object, index:Int)
	
	Function bbRefGetObject:Object(p:Byte Ptr)
	Function bbRefPushObject(p:Byte Ptr, obj:Object)
	Function bbRefInitObject(p:Byte Ptr, obj:Object)
	Function bbRefAssignObject(p:Byte Ptr, obj:Object)
	
	Function bbStructBoxAlloc:Byte Ptr(size:Size_T)
	Function bbStructBoxFree(p:Byte Ptr)
	
	Function bbRefGetObjectClass:Byte Ptr(obj:Object)
	
	Function bbRefGetSuperClass:Byte Ptr(class:Byte Ptr)
	Function bbStringFromRef:String(ref:Byte Ptr)
	Global bbRefNullObject:Object
	Global bbRefEmptyString:Object
	Global bbRefEmptyArray:Object
	
	Function bbInterfaceName:Byte Ptr(ifc:Byte Ptr)
	Function bbInterfaceClass:Byte Ptr(ifc:Byte Ptr)
	Function bbObjectImplementsInterfaces:Int(class:Byte Ptr)
	Function bbObjectImplementedCount:Int(class:Byte Ptr)
	Function bbObjectImplementedInterface:Byte Ptr(class:Byte Ptr, index:Int)
	Function bbFieldSetEnum(fieldPtr:Byte Ptr, _enum:Byte Ptr, value:String, noEnum:String, invalidEnumType:String)
	Function bbFieldGetEnum:String(fieldPtr:Byte Ptr, _enum:Byte Ptr, noEnum:String, invalidEnumType:String)
	
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
	Function bbDebugDeclFieldOffset:Size_T(decl:Byte Ptr)
	Function bbDebugDeclVarAddress:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclFuncPtr:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclStructSize:Size_T(decl:Byte Ptr)
	Function bbDebugDeclIsFlagsEnum:Byte(decl:Byte Ptr)
	Function bbDebugDeclReflectionWrapper:Byte Ptr(decl:Byte Ptr)
	Function bbDebugDeclNext:Byte Ptr(decl:Byte Ptr)
	?x64
	Global DebugScopePtrInt128:Byte Ptr = "debugScopePtrInt128"
	Global DebugScopePtrFloat64:Byte Ptr = "debugScopePtrFloat64"
	Global DebugScopePtrFloat128:Byte Ptr = "debugScopePtrFloat128"
	Global DebugScopePtrDouble128:Byte Ptr = "debugScopePtrDouble128"
	?
End Extern





Public

Type TBoxedValue Final
	
	Field ReadOnly valuePtr:Byte Ptr
	Field ReadOnly typeId:TTypeId
	
	Private
	
	Field ReadOnly mightContainReferences:Int
	Function MightContainReferences_:Int(typeId:TTypeId)
		Return typeId.IsClass() Or ..
		       typeId.IsInterface() Or ..
		       typeId.IsStruct() Or ..
		       typeId <> VarTypeId And typeId.ExtendsType(VarTypeId) And MightContainReferences_(typeId.ElementType())
	End Function
	
	Method New() End Method
	
	Public
	
	Method New(typeId:TTypeId)
		If Not typeId.IsValueType() Then Throw "Type is not a value type"
		Self.typeId = typeId
		Self.mightContainReferences = MightContainReferences_(typeId)
		If Self.mightContainReferences Then
			Self.valuePtr = bbStructBoxAlloc(typeId.Size())
		Else
			Self.valuePtr = MemAlloc(typeId.Size())
		End If
	End Method
	
	Method New(typeId:TTypeId, valuePtr:Byte Ptr)
		New(typeId)
		MemCopy Self.valuePtr, valuePtr, typeId.Size()
	End Method
	
	Method Delete()
		If mightContainReferences Then
			bbStructBoxFree valuePtr
		Else
			MemFree valuePtr
		End If
	End Method
	
	Method Unbox(targetValuePtr:Byte Ptr)
		MemCopy targetValuePtr, valuePtr, typeId.Size()
	End Method
	
	Method ToString:String() Override
		Return ToString(typeId)
	End Method
	
	Private
	
	Method ToString:String(typeId:TTypeId)
		Select typeId
			Case ByteTypeId   Return String.FromInt   ((Byte   Ptr valuePtr)[0])
			Case ShortTypeId  Return String.FromInt   ((Short  Ptr valuePtr)[0])
			Case IntTypeId    Return String.FromInt   ((Int    Ptr valuePtr)[0])
			Case UIntTypeId   Return String.FromUInt  ((UInt   Ptr valuePtr)[0])
			Case LongTypeId   Return String.FromLong  ((Long   Ptr valuePtr)[0])
			Case ULongTypeId  Return String.FromULong ((ULong  Ptr valuePtr)[0])
			Case SizeTTypeId  Return String.FromSizeT ((Size_T Ptr valuePtr)[0])
			Case FloatTypeId  Return String.FromFloat ((Float  Ptr valuePtr)[0])
			Case DoubleTypeId Return String.FromDouble((Double Ptr valuePtr)[0])
			? Win32
			Case LParamTypeId    Return String.FromLParam ((LParam Ptr valuePtr)[0])
			Case WParamTypeId    Return String.FromWParam ((WParam Ptr valuePtr)[0])
			?
			Case LongIntTypeId   Return String.FromLongInt ((LongInt  Ptr valuePtr)[0])
			Case ULongIntTypeId  Return String.FromULongInt((ULongInt Ptr valuePtr)[0])
		Default
			If typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(VarTypeId) Or typeId.ExtendsType(FunctionTypeId) Then
				Return String (Size_T((Byte Ptr Ptr valuePtr)[0]))
			Else If typeId.IsEnum() Then
				Return ToString(typeId.UnderlyingType())
			Else If typeId._toString Then 
				' forward call to the type's ToString method if it exists
				 Return typeId._toString(valuePtr)
			Else
				Return Super.ToString()
			End If
		End Select
	End Method
End Type

Global ReflectionMutex:TMutex = TMutex.Create()



Private

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
				Case typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(VarTypeId) Or typeId.ExtendsType(FunctionTypeId)
					Return String.FromSizeT((Size_T Ptr p)[0])
				Case typeId.IsStruct()
					Return New TBoxedValue(typeId, p)
				Case typeId._class <> Null
					Return bbRefGetObject(p)
				Case typeId.IsEnum()
					Return _Get(p, typeId.UnderlyingType())
				Default
					Throw "Unable to get value of this type"
			End Select
	End Select
End Function


Function _Assign(p:Byte Ptr, typeId:TTypeId, value:Object)
	Local boxedValue:TBoxedValue = TBoxedValue(value)
	If boxedValue Then
		If boxedValue.typeId.ExtendsType(typeId) Or ..
			(typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(VarTypeId) Or typeId.ExtendsType(FunctionTypeId)) ..
			And ..
			(boxedValue.typeId.ExtendsType(PointerTypeId) Or boxedValue.typeId.ExtendsType(VarTypeId) Or boxedValue.typeId.ExtendsType(FunctionTypeId)) ..
		Then
			boxedValue.Unbox p
		Else
			Throw "Unable to assign object of incompatible type"
		End If
	Else
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
						Case typeId.ExtendsType(PointerTypeId) Or typeId.ExtendsType(VarTypeId) Or typeId.ExtendsType(FunctionTypeId)
							(Size_T Ptr p)[0] = value.ToString().ToSizeT()
							Return
						Case typeId.IsStruct()
							Local box:TBoxedValue = TBoxedValue(value)
							If Not box Or box.typeId <> typeId Then Throw "Unable to assign object of incompatible type"
							box.Unbox p
							Return
						Case typeId.IsInterface()
							If bbInterfaceDowncast(value, typeId._interface) <> value Then Throw "Unable to assign object of incompatible type"
						Case typeId.IsEnum()
							_Assign p, typeId.UnderlyingType(), value
							Return
						Default
							If bbObjectDowncast(value, typeId._class) <> value Then Throw "Unable to assign object of incompatible type"
					End Select
				Else
					Select True
						Case typeId.IsStruct()
							Throw "Unable to convert Null object to this type"
						Case typeId.Name().Endswith("]")
							value = bbRefEmptyArray
						Case typeId = StringTypeId
							value = ""
					End Select
				EndIf
				bbRefAssignObject p, value
		End Select
	End If
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


Function _Invoke:Object(reflectionWrapper(buf:Byte Ptr Ptr), retType:TTypeId, argTypes:TTypeId[], args:Object[], bufferSize:Int, returnBoxedValue:Int = False)
	Local buf:Byte Ptr[bufferSize / (SizeOf Byte Ptr Null)]
	Local bufPtr:Byte Ptr Ptr = Byte Ptr Ptr buf
	
	bufPtr = _AdvanceBufferPointer(bufPtr, retType)
	For Local a:Int = 0 Until argTypes.Length
		_Assign bufPtr, argTypes[a], args[a]
		bufPtr = _AdvanceBufferPointer(bufPtr, argTypes[a])
	Next
	bufPtr = Byte Ptr Ptr buf
	
	reflectionWrapper bufPtr
	
	If retType <> VoidTypeId Then
		If returnBoxedValue Then
			If retType.IsReferenceType() Then
				Return bbRefGetObject(bufPtr)
			Else
				Return New TBoxedValue(retType, bufPtr)
			End If
		Else
			Return _Get(bufPtr, retType)
		End If
	End If
End Function

Public

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
		Case VarTypeId       Return "&"
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
		Case LongIntTypeId   Return "v"
		Case ULongIntTypeId  Return "e"
	End Select
	Select True
		Case id.ExtendsType(ArrayTypeId)
			Return "[]" + TypeTagForId(id._elementType)
		Case id.ExtendsType(PointerTypeId)
			Return "*" + TypeTagForId(id._elementType)
		Case id.ExtendsType(VarTypeId)
			Return "$" + TypeTagForId(id._elementType)
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
		Case id.IsEnum()
			Return "/" + id.Name()
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
		Case "t" Return SizeTTypeId
		Case "f" Return FloatTypeId
		Case "d" Return DoubleTypeId
		Case "$" Return StringTypeId
		Case "*" Return PointerTypeId
		Case "&" Return VarTypeId
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
		Case "v" Return LongIntTypeId
		Case "e" Return ULongIntTypeId
	End Select
	Select True
		Case ty.StartsWith("[") ' array
			Local dims:Int = ty.split(", ").length
			ty = ty[ty.Find("]") + 1..]
			Local id:TTypeId = TypeIdForTag(ty)
			If id Then
				id = id.ArrayType(dims)
			End If
			Return id
		Case ty.StartsWith(":") Or ty.StartsWith("@") Or ty.StartsWith("/") ' class/interface or struct or enum
			ty = ty[1..]
			Local i:Int = ty.FindLast(".")
			If i <> -1 ty = ty[i + 1..]
			Return TTypeId.ForName(ty)
		Case ty.StartsWith("*") ' pointer
			ty = ty[1..]
			Local id:TTypeId = TypeIdForTag(ty)
			If id Then
				id = id.PointerType()
			EndIf
			Return id
		Case ty.StartsWith("&") ' var
			ty = ty[1..]
			Local id:TTypeId = TypeIdForTag(ty)
			If id Then
				id = id.VarType()
			EndIf
			Return id
		Case ty.StartsWith("(") ' function
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

		Case ty.StartsWith("#") ' extern type/interface
			' TODO: extern type/interface support is to be added 
			Return Null
	End Select

	Throw "TypeIdForTag error: ~q" + ty + "~q"
End Function


Enum EModifiers Flags
	IsPrivate
	IsProtected
	IsAbstract
	IsFinal
	IsReadOnly
End Enum

Function ModifiersForTag:EModifiers(modifierString:String)
	Local modifiers:EModifiers
	If modifierString.Contains("P") Then modifiers :| EModifiers.IsPrivate
	If modifierString.Contains("Q") Then modifiers :| EModifiers.IsProtected
	If modifierString.Contains("A") Then modifiers :| EModifiers.IsAbstract
	If modifierString.Contains("F") Then modifiers :| EModifiers.IsFinal
	If modifierString.Contains("R") Then modifiers :| EModifiers.IsReadOnly
	Return modifiers
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

Function NamesAndArgTypesIdentical:Int(f1:TFunction, f2:TFunction)
	Return f1.Name().ToLower() = f2.Name().ToLower() And ArgTypesIdentical(f1, f2)
End Function

Function NamesAndArgTypesIdentical:Int(m1:TMethod, m2:TMethod)
	Return m1.Name().ToLower() = m2.Name().ToLower() And ArgTypesIdentical(m1, m2)
End Function

Function SignaturesIdentical:Int(f1:TFunction, f2:TFunction)
	Return NamesAndArgTypesIdentical(f1, f2) And f1.ReturnType() = f2.ReturnType()
End Function

Function SignaturesIdentical:Int(m1:TMethod, m2:TMethod)
	Return NamesAndArgTypesIdentical(m1, m2) And m1.ReturnType() = m2.ReturnType()
End Function

Private

Function ExtractMetaMap:TStringMap( meta:String )
	If Not meta Then
		Return Null
	End If

	Local map:TStringMap = New TStringMap(False)

	Local key:String
	Local value:String
	
	Local i:Int = 0
	While i < meta.length
		Local e:Int = meta.Find( "=",i )
		If e = -1 Throw "Malformed meta data"
		
		Local key:String = meta[i..e]
		Local value:String
		i = e + 1
		
		If i < meta.length And meta[i]=Asc("~q")
			i:+1
			Local e:Int = meta.Find( "~q",i )
			If e = -1 Throw "Malformed meta data"
			value = meta[i..e]
			i = e + 1
		Else
			Local e:Int = meta.Find( " ",i )
			If e = -1 e = meta.length
			value = meta[i..e]
			i = e
		EndIf

		map.Insert(key, value)
		
		If i < meta.length And meta[i] = Asc(" ") i:+1
	Wend
	
	Return map
End Function

Function AddFunctionsToList(tid:TTypeId, list:TList, initialLastLink:TLink, funcNameLower:String = "")
	Local insertPos:TLink = initialLastLink.NextLink()
	If Not insertPos Then insertPos = list._head
	' go through every function defined in the type described by tid
	#AddFunctionsLoop
	For Local func:TFunction = EachIn tid._functions
		' skip it if it has the wrong name
		If funcNameLower And funcNameLower <> func.Name().ToLower() Then Continue
		' check if it's overridden by something that was already in the list
		Local overrideCheckLink:TLink = insertPos
		If overrideCheckLink <> list._head Then 
			While overrideCheckLink
				Local func2:TFunction = TFunction(overrideCheckLink.Value())
				If NamesAndArgTypesIdentical(func, func2) Then Continue AddFunctionsLoop ' if so, skip it
				overrideCheckLink = overrideCheckLink.NextLink()
			Wend
		End If
		list.InsertBeforeLink func, insertPos ' otherwise, add it to the list
	Next
End Function

Function AddMethodsToList(tid:TTypeId, list:TList, initialLastLink:TLink, methNameLower:String = "")
	Local insertPos:TLink = initialLastLink.NextLink()
	If Not insertPos Then insertPos = list._head
	' go through every method defined in the type described by tid
	#AddMethodsLoop
	For Local meth:TMethod = EachIn tid._methods
		' skip it if it has the wrong name
		If methNameLower And methNameLower <> meth.Name().ToLower() Then Continue
		' check if it's overridden by something that was already in the list
		Local overrideCheckLink:TLink = insertPos
		If overrideCheckLink <> list._head Then 
			While overrideCheckLink
				Local meth2:TMethod = TMethod(overrideCheckLink.Value())
				If NamesAndArgTypesIdentical(meth, meth2) Then Continue AddMethodsLoop ' if so, skip it
				overrideCheckLink = overrideCheckLink.NextLink()
			Wend
		End If
		list.InsertBeforeLink meth, insertPos ' otherwise, add it to the list
	Next
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
Global ObjectTypeId:TTypeId = New TTypeId.Init("Object", SizeOf Byte Ptr Null, bbRefObjectClass, , False)

Rem
bbdoc: String type ID
End Rem
Global StringTypeId:TTypeId = New TTypeId.Init("String", SizeOf Byte Ptr Null, bbRefStringClass, ObjectTypeId)

Rem
bbdoc: Primitive longint type
End Rem
?Not ptr64
Global LongIntTypeId:TTypeId=New TTypeId.Init( "LongInt",4 )
?ptr64 And Not win32
Global LongIntTypeId:TTypeId=New TTypeId.Init( "LongInt",8 )
?ptr64 And win32
Global LongIntTypeId:TTypeId=New TTypeId.Init( "LongInt",4 )
?

Rem
bbdoc: Primitive ulongint type
End Rem
?Not ptr64
Global ULongIntTypeId:TTypeId=New TTypeId.Init( "ULongInt",4 )
?ptr64 And Not win32
Global ULongIntTypeId:TTypeId=New TTypeId.Init( "ULongInt",8 )
?ptr64 And win32
Global ULongIntTypeId:TTypeId=New TTypeId.Init( "ULongInt",4 )
?

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
Global ArrayTypeId:TTypeId = New TTypeId.Init("Null[]", SizeOf Byte Ptr Null, bbRefArrayClass, ObjectTypeId, False)

Rem
bbdoc: Mock pointer base type ID
End Rem
Global PointerTypeId:TTypeId = New TTypeId.Init("Ptr", SizeOf Byte Ptr Null, , , False)

Rem
bbdoc: Mock var base type ID
End Rem
Global VarTypeId:TTypeId = New TTypeId.Init("Var", SizeOf Byte Ptr Null, , , False)

Rem
bbdoc: Mock function/method base type ID
End Rem
Global FunctionTypeId:TTypeId = New TTypeId.Init("Null()", SizeOf Byte Ptr Null, , , False)



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
		Return Not (_modifiers & (EModifiers.IsProtected | EModifiers.IsPrivate))
	End Method
	
	Rem
	bbdoc: Determine if this member has the "Protected" access modifier
	End Rem	
	Method IsProtected:Int()
		Return _modifiers & EModifiers.IsProtected <> Null
	End Method
	
	Rem
	bbdoc: Determine if this member has the "Private" access modifier
	End Rem	
	Method IsPrivate:Int()
		Return _modifiers & EModifiers.IsPrivate <> Null
	End Method
	
	Rem
	bbdoc: Get member meta data
	End Rem
	Method MetaData:String(key:String = "")
		If Not _metaMap Or Not key Return _meta
		Return String(_metaMap.ValueForKey(key))
	End Method
	
	Rem
	bbdoc: Returns #True if @key is in the metadata.
	End Rem
	Method HasMetaData:Int( key:String )
		If Not _metaMap Or Not key Return False
		Return _metaMap.Contains(key)
	End Method
	
	Protected
	
	Method InitMeta(meta:String)
		_meta = meta
		_metaMap = ExtractMetaMap(meta)
	End Method
	
	Field _name:String, _typeId:TTypeId, _modifiers:EModifiers
	Field _meta:String, _metaMap:TStringMap
	
End Type



Rem
bbdoc: Type member constant
EndRem
Type TConstant Extends TMember
	
	Private
	
	Method Init:TConstant(name$, typeId:TTypeId, modifiers:EModifiers, meta$, str$)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		InitMeta(meta)
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
	bbdoc: Get constant value as @LongInt
	EndRem
	Method GetLongInt:LongInt()
		Return GetString().ToLongInt()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @ULongInt
	EndRem
	Method GetULongInt:ULongInt()
		Return GetString().ToULongInt()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Float
	EndRem	
	Method GetFloat:Float()
		Return GetString().ToFloat()
	EndMethod
	
	Rem
	bbdoc: Get constant value as @Double
	EndRem	
	Method GetDouble:Double()
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
	
	Method Init:TField(name:String, typeId:TTypeId, modifiers:EModifiers, meta:String, offset:Size_T)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		InitMeta(meta)
		_offset = offset
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Determine if field is read-only
	End Rem	
	Method IsReadOnly:Int()
		Return _modifiers & EModifiers.IsReadOnly <> Null
	End Method
	
	Rem
	bbdoc: Get field value
	about:
	For reference types, this returns the object. For structs, it returns a @TBoxedValue.
	For other value types, it returns a string representation of the value.
	End Rem
	Method Get:Object(obj:Object)
		Return _Get(FieldPtr(obj), _typeId)
	End Method
	
	Rem
	bbdoc: Get field value
	about: Like @Get, but always returns a @TBoxedValue for value types instead of converting the value to a string.
	End Rem
	Method GetBoxed:Object(obj:Object)
		Local fieldPtr:Byte Ptr = FieldPtr(obj)
		If _typeId.IsReferenceType() Then
			Return bbRefGetObject(fieldPtr)
		Else
			Return New TBoxedValue(_typeId, fieldPtr)
		End If
	End Method
	
	Rem
	bbdoc: Get field value as @Byte
	End Rem
	Method GetByte:Byte( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @Short
	End Rem
	Method GetShort:Short( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @Int
	End Rem
	Method GetInt:Int( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get field value as @UInt
	End Rem
	Method GetUInt:UInt( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @Long
	End Rem
	Method GetLong:Long( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get field value as @ULong
	End Rem
	Method GetULong:ULong( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @Size_T
	End Rem
	Method GetSizeT:Size_T( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get field value as @Float
	End Rem
	Method GetFloat:Float( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get field value as @Double
	End Rem
	Method GetDouble:Double( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get field value as @LongInt
	End Rem
	Method GetLongInt:LongInt( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @ULongInt
	End Rem
	Method GetULongInt:ULongInt( obj:Object )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method

	Rem
	bbdoc: Get field value as @String
	End Rem
	Method GetString:String( obj:Object )
		Return String( Get( obj ) )
	End Method
	
	Rem
	bbdoc: Get field value as @{Byte Ptr}
	EndRem
	Method GetPointer:Byte Ptr(obj:Object)
		Return Byte Ptr GetSizet(obj)
	EndMethod
	
	Rem
	bbdoc: Get field value as struct
	about: @targetPtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method GetStruct(obj:Object, targetPtr:Byte Ptr)
		If Not _typeId.IsStruct() Then Throw "Field type is not a struct"
		MemCopy targetPtr, FieldPtr(obj), Size_T _typeId._size
	EndMethod

	Rem
	bbdoc: Get enum field value as @String
	about: Returns the name of the enum value. If the field value does not correspond to any enum value, throws an error.
	End Rem
	Method GetEnumAsString:String( obj:Object )
		If Not _typeId.IsEnum() Then Throw "Field type is not an enum"
		IF Not _typeId._enum Then Throw "...No enum provided"

		Return bbFieldGetEnum(FieldPtr(obj), _typeId._enum, "No enum provided", "Invalid enum type")
	End Method
	
	Rem
	bbdoc: Set Field value
	End Rem
	Method Set(obj:Object, value:Object)
		_Assign FieldPtr(obj), _typeId, value
	End Method
	
	Rem
	bbdoc: Set field value from @Byte
	End Rem
	Method Set( obj:Object,value:Byte )
		SetByte(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Short
	End Rem
	Method Set( obj:Object,value:Short )
		SetShort(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Int
	End Rem
	Method Set( obj:Object,value:Int )
		SetInt(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @UInt
	End Rem
	Method Set( obj:Object,value:UInt )
		SetUInt(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Long
	End Rem
	Method Set( obj:Object,value:Long )
		SetLong(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @ULong
	End Rem
	Method Set( obj:Object,value:ULong )
		SetULong(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Size_T
	End Rem
	Method Set( obj:Object,value:Size_T )
		SetSizet(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Float
	End Rem
	Method Set( obj:Object,value:Float )
		SetFloat(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Double
	End Rem
	Method Set( obj:Object,value:Double )
		SetDouble(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @LongInt
	End Rem
	Method Set( obj:Object,value:LongInt )
		SetLongInt(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @ULongInt
	End Rem
	Method Set( obj:Object,value:ULongInt )
		SetULongInt(obj, value)
	End Method

	Rem
	bbdoc: Set field value from @Object
	End Rem
	Method SetObject( obj:Object,value:Object )
		_Assign FieldPtr(obj), _typeId, value
	End Method

	Rem
	bbdoc: Set field value from @Byte
	End Rem
	Method SetByte( obj:Object,value:Byte )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=value
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @Short
	End Rem
	Method SetShort( obj:Object,value:Short )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=value
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @Int
	End Rem
	Method SetInt( obj:Object,value:Int )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=value
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set field value from @UInt
	End Rem
	Method SetUInt( obj:Object,value:UInt )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=value
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromUInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @Long
	End Rem
	Method SetLong( obj:Object,value:Long )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=value
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromLong( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set field value from @ULong
	End Rem
	Method SetULong( obj:Object,value:ULong )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=value
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromULong( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @Size_T
	End Rem
	Method SetSizet( obj:Object,value:Size_T )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=value
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromSizet( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @Float
	End Rem
	Method SetFloat( obj:Object,value:Float )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=value
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromFloat( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set field value from @Double
	End Rem
	Method SetDouble( obj:Object,value:Double )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=value
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set field value from @LongInt
	End Rem
	Method SetLongInt( obj:Object,value:LongInt )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=value
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromLongInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @ULongInt
	End Rem
	Method SetULongInt( obj:Object,value:ULongInt )
		Local p:Byte Ptr = FieldPtr(obj)
		Select _typeId
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=value
			Case StringTypeId
				bbRefAssignObject p,String.FromULongInt( value )
			Default
				If _typeId.ExtendsType(PointerTypeId) Or _typeId.ExtendsType(VarTypeId) Or _typeId.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method

	Rem
	bbdoc: Set field value from @String
	End Rem
	Method SetString( obj:Object,value:String )
		Set obj,value
	End Method
	
	Rem
	bbdoc: Set field value from @{Byte Ptr}
	EndRem
	Method SetPointer(obj:Object, value:Byte Ptr)
		SetSizeT obj, Size_T value
	EndMethod
	
	Rem
	bbdoc: Set field value from struct
	about: @structPtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method SetStruct(obj:Object, structPtr:Byte Ptr)
		If Not _typeId.IsStruct() Then Throw "Field type is not a struct"
		MemCopy FieldPtr(obj), structPtr, Size_T _typeId.Size()
	EndMethod

	Rem
	bbdoc: Set field value from enum name
	about: @value must be a valid name for an enum value of the field's enum type.
	End Rem
	Method SetEnum(obj:Object, value:String)
		If Not _typeId.IsEnum() Then Throw "Field type is not an enum"
		bbFieldSetEnum(FieldPtr(obj), _typeId._enum, value, "No enum provided", "Invalid enum type")
	End Method
	
	Rem
	bbdoc: Get pointer to the field
	EndRem
	Method FieldPtr:Byte Ptr(obj:Object)
		If TBoxedValue(obj) Then
			Return TBoxedValue(obj).valuePtr + _offset
		Else
			Return bbRefObjectFieldPtr(obj, _offset)
		End If
	End Method
	
	Rem
	bbdoc: Invoke field value
	about: Field type must be a function pointer.
	EndRem	
	Method Invoke:Object(obj:Object, args:Object[] = Null)
		If Not _typeId.ExtendsType(FunctionTypeId) Then Throw "Value type ID is not a function type"
		If args.Length <> _typeId.ArgTypes().Length Then Throw "Function invoked with wrong number of arguments"
		Throw "Not implemented yet"
		'TODO
'		Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T GetFieldPtr(obj, _offset))] + args, _invokeBufferSize)
	End Method
	
	Field _offset:Size_T
	
End Type



Rem
bbdoc: Type member global variable
End Rem
Type TGlobal Extends TMember
	
	Private
	
	Method Init:TGlobal(name$, typeId:TTypeId, modifiers:EModifiers, meta$, ref:Byte Ptr)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		InitMeta(meta)
		_ref = ref
		Return Self
	End Method
	
	Public
	
	Rem
	bbdoc: Get global value
	about:
	For reference types, this returns the object. For structs, it returns a @TBoxedValue.
	For other value types, it returns a string representation of the value.
	End Rem
	Method Get:Object()
		Return _Get(_ref, _typeId)
	End Method
	
	Rem
	bbdoc: Get global value
	about: Like @Get, but always returns a @TBoxedValue for value types instead of converting the value to a string.
	End Rem
	Method GetBoxed:Object()
		If _typeId.IsReferenceType() Then
			Return bbRefGetObject(_ref)
		Else
			Return New TBoxedValue(_typeId, _ref)
		End If
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
	Method GetStruct(targetPtr:Byte Ptr)
		If Not _typeId.IsStruct() Then Throw "Global type is not a struct"
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
	about: @structPtr must be a pointer to a variable of the correct struct type.
	EndRem
	Method SetStruct(structPtr:Byte Ptr)
		If Not _typeId.IsStruct() Then Throw "Global type is not a struct"
		MemCopy _ref, structPtr, Size_T _typeId._size
	EndMethod
	
	Rem
	bbdoc: Get pointer to the global
	EndRem
	Method GlobalPtr:Byte Ptr()
		Return _ref
	End Method
	
	Rem
	bbdoc: Invoke global value
	about: Global type must be a function pointer.
	EndRem	
	Method Invoke:Object(args:Object[] = Null)
		If Not _typeId.ExtendsType(FunctionTypeId) Then Throw "Value type ID is not a function type"
		If args.Length <> _typeId.ArgTypes().Length Then Throw "Function invoked with wrong number of arguments"
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
	
	Method Init:TFunction(name$, typeId:TTypeId, modifiers:EModifiers, meta$, ref:Byte Ptr, invokeRef:Byte Ptr)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		InitMeta(meta)
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
		Return _modifiers & EModifiers.IsAbstract <> Null
	End Method
	
	Rem
	bbdoc: Determine if function is final
	End Rem	
	Method IsFinal:Int()
		Return _modifiers & EModifiers.IsFinal <> Null
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
	about:
	If the function return type is a reference type, this returns the object returned by the function.
	If it is a struct, it returns a @TBoxedValue.
	If it is another value type, it returns a string representation of the returned value.
	EndRem	
	Method Invoke:Object(args:Object[] = Null)
		If args.Length <> _typeId.ArgTypes().Length Then Throw "Function invoked with wrong number of arguments"
		Return _Invoke(_invokeRef, _typeId._retType, _typeId._argTypes, args, _invokeBufferSize)
	End Method
	
	Rem
	bbdoc: Invoke function
	about: Like @Invoke, but always returns a @TBoxedValue for value types instead of converting the value to a string.
	EndRem	
	Method InvokeBoxed:Object(args:Object[] = Null)
		If args.Length <> _typeId.ArgTypes().Length Then Throw "Function invoked with wrong number of arguments"
		Return _Invoke(_invokeRef, _typeId._retType, _typeId._argTypes, args, _invokeBufferSize, True)
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
	
	Method Init:TMethod(name$, typeId:TTypeId, modifiers:EModifiers, meta$, ref:Byte Ptr, invokeRef:Byte Ptr, selfTypeId:TTypeId)
		_name = name
		_typeId = typeId
		_modifiers = modifiers
		InitMeta(meta)
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
		Return _modifiers & EModifiers.IsAbstract <> Null
	End Method
	
	Rem
	bbdoc: Determine if method is final
	End Rem	
	Method IsFinal:Int()
		Return _modifiers & EModifiers.IsFinal <> Null
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
	
	Rem
	bbdoc: Get function pointer
	EndRem
	Method FunctionPtr:Byte Ptr()
		Return _ref
	End Method
	
	Rem
	bbdoc: Invoke method
	about:
	If the method return type is a reference type, this returns the object returned by the method.
	If it is a struct, it returns a @TBoxedValue.
	If it is another value type, it returns a string representation of the returned value.
	End Rem
	Method Invoke:Object(obj:Object, args:Object[] = Null)
		If Not obj Then Throw "Unable to invoke method on Null object"
		If _selfTypeId._elementType And _selfTypeId._elementType.IsStruct() Then ' method on struct type
			Local box:TBoxedValue = TBoxedValue(obj)
			If (Not box) Or box.typeId <> _selfTypeId._elementType Then Throw "Unable to invoke method on this object"
			If args.Length <> _typeId.ArgTypes().Length Then Throw "Method invoked with wrong number of arguments"
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T box.valuePtr)] + args, _invokeBufferSize)
		Else
			If args.Length <> _typeId.ArgTypes().Length Then Throw "Method invoked with wrong number of arguments"
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [obj] + args, _invokeBufferSize)
		End If
	End Method
	
	Rem
	bbdoc: Invoke method
	about: Like @Invoke, but always returns a @TBoxedValue for value types instead of converting the value to a string.
	End Rem
	Method InvokeBoxed:Object(obj:Object, args:Object[] = Null)
		If Not obj Then Throw "Unable to invoke method on Null object"
		If _selfTypeId._elementType And _selfTypeId._elementType.IsStruct() Then ' method on struct type
			Local box:TBoxedValue = TBoxedValue(obj)
			If (Not box) Or box.typeId <> _selfTypeId._elementType Then Throw "Unable to invoke method on this object"
			If args.Length <> _typeId.ArgTypes().Length Then Throw "Method invoked with wrong number of arguments"
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [String.FromSizeT(Size_T box.valuePtr)] + args, _invokeBufferSize, True)
		Else
			If args.Length <> _typeId.ArgTypes().Length Then Throw "Method invoked with wrong number of arguments"
			Return _Invoke(_invokeRef, _typeId._retType, _invokeArgTypes, [obj] + args, _invokeBufferSize, True)
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
	about: When called on an interface type ID, this method alwayss returns @Object.
	To get the super interfaces of an interface, use @Interfaces.
	End Rem	
	Method SuperType:TTypeId()
		Return _super
	End Method
	
	Rem
	bbdoc: Get list of implemented interfaces of a class, or super interfaces of an interface.
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
	
	Method TypeHierarchy:TList()
		Local list:TList = New TList
		
		If Self.IsInterface() Then
			list.AddFirst Self
		Else
			Local tid:TTypeId = Self
			While tid
				list.AddFirst tid
				tid = tid.SuperType()
			Wend
		End If
		Local insertPos:TLink = list.FirstLink()
		For Local tid:TTypeId = EachIn Self.Interfaces()
			list.InsertBeforeLink tid, insertPos
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Get underlying type
	about: Returns the underlying integral type of an enum type.
	End Rem	
	Method UnderlyingType:TTypeId()
		If Not IsEnum() Then Throw "Type ID is not an enum type"
		Return _underlyingType
	End Method
	
	Rem
	bbdoc: Get array type with this element type
	End Rem
	Method ArrayType:TTypeId(dims:Int = 1)
		If dims <= 0 Then Throw "Number of array dimensions must be positive"
		
		Try
			ReflectionMutex.Lock
			If _arrayTypes.Length <= dims Then
				_arrayTypes = _arrayTypes[..dims + 1]
			Else If _arrayTypes[dims] Then
				Return _arrayTypes[dims]
			End If
			
			Local commas:String
			For Local i:Int = 1 Until dims
				commas :+ ","
			Next
			Local t:TTypeId = New TTypeId.Init(_name + "[" + commas + "]", ArrayTypeId._size, bbRefArrayClass)
			t._elementType = Self
			t._dimensions = dims
			If _super Then
				t._super = _super.ArrayType()
			Else
				t._super = ArrayTypeId
			End If
			_arrayTypes[dims] = t
			Return t
		Finally
			ReflectionMutex.Unlock
		End Try
	End Method
	
	Rem
	bbdoc: Get element type
	End Rem
	Method ElementType:TTypeId()
		If Not _elementType Then Throw "Type ID is not a valid array, pointer or var type"
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
		Try
			ReflectionMutex.Lock
			If Not _pointerType Then
				Local t:TTypeId = New TTypeId.Init(_name + " Ptr", PointerTypeId._size)
				t._elementType = Self
				t._super = PointerTypeId
				_pointerType = t
			EndIf
			Return _pointerType
		Finally
			ReflectionMutex.Unlock
		End Try
	End Method
	
	Rem
	bbdoc: Get var type with this element type
	End Rem
	Method VarType:TTypeId()
		Try
			ReflectionMutex.Lock
			If Not _varType Then
				Local t:TTypeId = New TTypeId.Init(_name + " Var", VarTypeId._size)
				t._elementType = Self
				t._super = VarTypeId
				_varType = t
			EndIf
			Return _varType
		Finally
			ReflectionMutex.Unlock
		End Try
	End Method
	
	Rem
	bbdoc: Get function type with this return type
	End Rem
	Method FunctionType:TTypeId(argTypes:TTypeId[] = Null)
		Try
			ReflectionMutex.Lock
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
		Finally
			ReflectionMutex.Unlock
		End Try
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
			If _class = bbRefStringClass Then
				Return bbRefEmptyString
			End If
			If _class = bbRefArrayClass Then
				Return bbRefEmptyArray
			End If
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
			Local box:TBoxedValue = New TBoxedValue(Self)
			constructor.Invoke box, args
			Return box
		Else
			If Not _class Then Throw "Unable to create instance of this type"
			If _interface Then Throw "Unable to create instance from interface"
			If _elementType Then Throw "Unable to create array this way"
			If _class = bbRefStringClass or _class = bbRefArrayClass Then
				Throw "Unable to create instance of this type with constructor"
			End If
			' make sure we were actually given a constructor for this class
			If Not constructor Then Throw "Constructor is Null"
			If Not _constructors.Contains(constructor) Then Throw "Method is not a constructor of this type"
			Local o:Object = bbObjectNewNC(_class) ' TODO: bbObjectAtomicNewNC?
			constructor.Invoke o, args
			Return o
		End If
	End Method
	
	Rem
	bbdoc: Determine if type is a reference type
	End Rem
	Method IsReferenceType:Int()
		Return _class <> Null
	End Method
	
	Rem
	bbdoc: Determine if type is a value type
	about: Returns True for Var types
	End Rem
	Method IsValueType:Int()
		Return _class = Null
	End Method
	
	Rem
	bbdoc: Determine if type is a class
	End Rem
	Method IsClass:Int()
		Return _class <> Null And _interface = Null
	End Method
	
	Rem
	bbdoc: Determine if type is an interface
	End Rem
	Method IsInterface:Int()
		Return _interface <> Null
	End Method
	
	Rem
	bbdoc: Determine if type is a struct
	End Rem
	Method IsStruct:Int()
		Return _struct <> Null Or (_class = Null And _enum = Null)
	End Method
	
	Rem
	bbdoc: Determine if type is an enum
	End Rem
	Method IsEnum:Int()
		Return _enum <> Null
	End Method
	
	Rem
	bbdoc: Determine if type is a flags enum
	End Rem
	Method IsFlagsEnum:Int()
		Return _isFlagsEnum
	End Method
	
	Rem
	bbdoc: Determine if type is abstract
	End Rem
	Method IsAbstract:Int()
		Return _modifiers & EModifiers.IsAbstract <> Null
	End Method
	
	Rem
	bbdoc: Determine if type is final
	End Rem
	Method IsFinal:Int()
		Return _modifiers & EModifiers.IsFinal <> Null
	End Method

	Rem
	bbdoc: Determine if type is an array type
	End Rem
	Method IsArrayType:Int()
		Return _elementType <> Null And _class = bbRefArrayClass
	End Method
	
	Rem
	bbdoc: Get list of constants
	about: Only returns constants declared in this type, not in super types.
	End Rem
	Method Constants:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local cons:TConstant = EachIn _consts
			list.AddLast cons
		Next
		
		Return list
	End Method	
	
	Rem
	bbdoc: Get list of fields
	about: Only returns fields declared in this type, not in super types.
	End Rem
	Method Fields:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local fld:TField = EachIn _fields
			list.AddLast fld
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Get list of globals
	about: Only returns globals declared in this type, not in super types.
	End Rem
	Method Globals:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local glob:TGlobal = EachIn _globals
			list.AddLast glob
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Get list of functions
	about: Only returns functions declared in this type, not in super types.
	EndRem
	Method Functions:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local func:TFunction = EachIn _functions
			list.AddLast func
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Get list of methods
	about: Only returns methods declared in this type, not in super types.
	End Rem
	Method Methods:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local meth:TMethod = EachIn _methods
			list.AddLast meth
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Find a constant by name
	about: Searches type hierarchy for a constant called @name.
	End Rem
	Method FindConstant:TConstant(name:String)
		name = name.ToLower()
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local cons:TConstant = EachIn tid._consts
				If cons.Name().ToLower() = name Then Return cons
			Next
		Next
	End Method	
	
	Rem
	bbdoc: Find a field by name
	about: Searches type hierarchy for a field called @name.
	End Rem
	Method FindField:TField(name:String)
		name = name.ToLower()
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local fld:TField = EachIn tid._fields
				If fld.Name().ToLower() = name Then Return fld
			Next
		Next
	End Method
	
	Rem
	bbdoc: Find a global by name
	about: Searches type hierarchy for a global called @name.
	End Rem
	Method FindGlobal:TGlobal(name:String)
		name = name.ToLower()
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local glob:TGlobal = EachIn tid._globals
				If glob.Name().ToLower() = name Then Return glob
			Next
		Next
	End Method
	
	Rem
	bbdoc: Find a function by name
	about: Searches type hierarchy for a function called @name.<br>
	If the function is overloaded, the first overload declared in the most derived type will be returned.
	End Rem
	Method FindFunction:TFunction(name:String)
		name = name.ToLower()
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local func:TFunction = EachIn tid._functions
				If func.Name().ToLower() = name Then Return func
			Next
		Next
	End Method
	
	Rem
	bbdoc: Find a specific overload of a function by name and parameter list
	about: Searches type hierarchy for a function called @name with the specified argument types.<br>
	This can be used to find a specific overload of a function.
	End Rem
	Method FindFunction:TFunction(name:String, argTypes:TTypeId[])
		name = name.ToLower()
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local func:TFunction = EachIn tid._functions
				If func.Name().ToLower() = name And TypeListsIdentical(func.ArgTypes(), argTypes) Then Return func
			Next
		Next
	End Method
	
	Rem
	bbdoc: Find all overloads of a function by name
	about: Searches type hierarchy for a function called @name.<br>
	Same as @FindFunction, except it returns all overloads of the function.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method FindFunctions:TList(name:String, list:TList = Null)
		name = name.ToLower()
		If Not list Then list = New TList
		
		' list might be non-empty => retrieve the last link
		Local initialLastLink:TLink = list.LastLink()
		If Not initialLastLink Then initialLastLink = list._head
		
		' add the functions
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			AddFunctionsToList tid, list, initialLastLink, name
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Find a method by name
	about: Searches type hierarchy for a method called @name.<br>
	If the method is overloaded, the first overload declared in the most derived type will be returned.
	End Rem
	Method FindMethod:TMethod(name:String)
		name = name.ToLower()
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local meth:TMethod = EachIn tid._methods
				If meth.Name().ToLower() = name Then Return meth
			Next
		Next
		Return Null
	End Method
	
	Rem
	bbdoc: Find a specific overload of a method by name and parameter list
	about: Searches type hierarchy for a method called @name with the specified argument types.<br>
	This can be used to find a specific overload of a method.
	End Rem
	Method FindMethod:TMethod(name:String, argTypes:TTypeId[])
		name = name.ToLower()
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			For Local meth:TMethod = EachIn tid._methods
				If meth.Name().ToLower() = name And TypeListsIdentical(meth.ArgTypes(), argTypes) Then Return meth
			Next
		Next
		Return Null
	End Method
	
	Rem
	bbdoc: Find all overloads of a method by name
	about: Searches type hierarchy for a method called @name.<br>
	Same as @FindMethod, except it returns all overloads of the method.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method FindMethods:TList(name:String, list:TList = Null)
		name = name.ToLower()
		If Not list Then list = New TList
		
		' list might be non-empty => retrieve the last link
		Local initialLastLink:TLink = list.LastLink()
		If Not initialLastLink Then initialLastLink = list._head
		
		' add the methods
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			AddMethodsToList tid, list, initialLastLink, name
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all constants
	about: Returns a list of all constants in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumConstants:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy()
			For Local cons:TConstant = EachIn tid._consts
				list.AddLast cons
			Next
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all fields
	about: Returns a list of all fields in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumFields:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy()
			For Local fld:TField = EachIn tid._fields
				list.AddLast fld
			Next
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all globals
	about: Returns a list of all globals in type hierarchy.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumGlobals:TList(list:TList = Null)
		If Not list Then list = New TList
		
		For Local tid:TTypeId = EachIn Self.TypeHierarchy()
			For Local glob:TGlobal = EachIn tid._globals
				list.AddLast glob
			Next
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
		
		' list might be non-empty => retrieve the last link
		Local initialLastLink:TLink = list.LastLink()
		If Not initialLastLink Then initialLastLink = list._head
		
		' add the functions
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			AddFunctionsToList tid, list, initialLastLink
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Enumerate all methods
	about: Returns a list of all methods in type hierarchy, excluding ones that have been overridden. Does not include unimplemented methods from interfaces implemented by this type.<br>
	If an existing list is passed, retains the elements in that list and appends the results to the end. Otherwise, creates a new list.
	End Rem
	Method EnumMethods:TList(list:TList = Null)
		If Not list Then list = New TList
		
		' list might be non-empty => retrieve the last link
		Local initialLastLink:TLink = list.LastLink()
		If Not initialLastLink Then initialLastLink = list._head
		
		' add the methods
		For Local tid:TTypeId = EachIn Self.TypeHierarchy().Reversed()
			AddMethodsToList tid, list, initialLastLink
		Next
		
		Return list
	End Method
	
	Rem
	bbdoc: Get Null value
	about:
	For reference types, this returns the object. For structs, it returns a @TBoxedValue.
	For other value types, it returns a string representation of the value.
	End Rem
	Method NullValue:Object()
		Select Self
			Case ByteTypeId Return "0"
			Case ShortTypeId Return "0"
			Case IntTypeId Return "0"
			Case UIntTypeId Return "0"
			Case LongTypeId Return "0"
			Case ULongTypeId Return "0"
			Case SizetTypeId Return "0"
			Case FloatTypeId Return "0"
			Case DoubleTypeId Return "0"
			Case LongIntTypeId Return "0"
			Case ULongIntTypeId Return "0"
			Case StringTypeId Return bbRefEmptyString
		End Select
		Select True
			Case ExtendsType(ArrayTypeId) Return bbRefEmptyArray
			Case ExtendsType(PointerTypeId) Return "0"
			Case ExtendsType(VarTypeId) Return "0"
			Case ExtendsType(FunctionTypeId) Return String.FromSizeT(Size_T Byte Ptr NullFunctionError) 
			Case IsReferenceType() Return bbRefNullObject
			Case IsStruct() Return NewObject()
			Case IsFlagsEnum() Return "0"
			Case IsEnum() Return TConstant(_consts.First()).Get()
		End Select
		Return Null
	End Method
	
	Rem
	bbdoc: Get Null value
	about: Like @NullValue, but always returns a @TBoxedValue for value types instead of converting the value to a string.
	End Rem
	Method NullValueBoxed:Object()
		Select Self
			Case ByteTypeId     Local n:Byte     Return New TBoxedValue(Self, Varptr n)
			Case ShortTypeId    Local n:Short    Return New TBoxedValue(Self, Varptr n)
			Case IntTypeId      Local n:Int      Return New TBoxedValue(Self, Varptr n)
			Case UIntTypeId     Local n:UInt     Return New TBoxedValue(Self, Varptr n)
			Case LongTypeId     Local n:Long     Return New TBoxedValue(Self, Varptr n)
			Case ULongTypeId    Local n:ULong    Return New TBoxedValue(Self, Varptr n)
			Case SizetTypeId    Local n:Size_T   Return New TBoxedValue(Self, Varptr n)
			Case FloatTypeId    Local n:Float    Return New TBoxedValue(Self, Varptr n)
			Case DoubleTypeId   Local n:Double   Return New TBoxedValue(Self, Varptr n)
			Case LongIntTypeId  Local n:LongInt  Return New TBoxedValue(Self, Varptr n)
			Case ULongIntTypeId Local n:ULongInt Return New TBoxedValue(Self, Varptr n)
			Case StringTypeId Return bbRefEmptyString
		End Select
		Select True
			Case ExtendsType(ArrayTypeId) Return bbRefEmptyArray
			Case ExtendsType(PointerTypeId)  Local n:Byte Ptr Return New TBoxedValue(Self, Varptr n)
			Case ExtendsType(VarTypeId)      Local n:Byte Ptr Return New TBoxedValue(Self, Varptr n)
			Case ExtendsType(FunctionTypeId) Local n()        Return New TBoxedValue(Self, Varptr n)
			Case IsReferenceType() Return bbRefNullObject
			Case IsStruct() Return NewObject()
			Case IsFlagsEnum() Return UnderlyingType().NullValueBoxed()
			Case IsEnum()
				Local v:Object = TConstant(_consts.First()).Get()
				Local b:TBoxedValue = New TBoxedValue(Self)
				_Assign b.valuePtr, Self, v
				Return b
		End Select
		Return Null
	End Method
	
	Rem
	bbdoc: Create a new array
	about: This method should only be called on an array type ID.<br>
	If @dims is not specified, this method will create a one-dimensional array with @length elements.
	Otherwise, @length is ignored and a new array with dimensions as specified by @dims is created.
	The elements of the array are not initialized to valid values.
	End Rem
	Method NewArray:Object(length:Int = 0, dims:Int[] = Null)
		If Self = ArrayTypeId Then Throw "Unable to create array of " + Name() + " type"
		If (Not _elementType) Or (Not _class) Throw "TypeID is not an array type"
		Local tag:Byte Ptr
		Try
			ReflectionMutex.Lock
			tag = _elementType._typeTag
			If Not tag
				tag = TypeTagForId(_elementType).ToCString()
				_elementType._typeTag = tag
			EndIf
		Finally
			ReflectionMutex.Unlock
		End Try
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
	bbdoc: Slice an array
	End Rem
	Method ArraySlice:Object( _array:Object, _start:Int, _end:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local tag:Byte Ptr=_elementType._typeTag
		If Not tag
			tag=TypeTagForId( _elementType ).ToCString()
			_elementType._typeTag=tag
		EndIf
		_array = bbArraySlice(tag, _array, _start, _end)
		Return _array
	End Method
	
	Rem
	bbdoc: Get an array element
	about:
	This method should only be called on the type ID corresponding to the type of the array.
	For arrays of reference types, this returns the object from the array. For structs, it returns a @TBoxedValue.
	For other value types, it returns a string representation of the value.
	End Rem
	Method GetArrayElement:Object(_array:Object, index:Int)
		If (Not _elementType) Or (Not _class) Throw "Type ID is not an array type"
		Local p:Byte Ptr = bbRefArrayElementPtr(_elementType._size, _array, index)
		Return _Get(p, _elementType)
	End Method
	
	Rem
	bbdoc: Get an array element
	about:
	This method should only be called on the type ID corresponding to the type of the array.
	Like @Get, but always returns a @TBoxedValue for arrays of value types instead of converting the value to a string.
	End Rem
	Method GetBoxedArrayElement:Object(_array:Object, index:Int)
		If (Not _elementType) Or (Not _class) Throw "Type ID is not an array type"
		Local p:Byte Ptr = bbRefArrayElementPtr(_elementType._size, _array, index)
		If _elementType.IsReferenceType() Then
			Return bbRefGetObject(p)
		Else
			Return New TBoxedValue(_elementType, p)
		End If
	End Method
	
	Rem
	bbdoc: Get an array element as @String
	about: This method should only be called on the type ID corresponding to the type of the array.
	End Rem
	Method GetStringArrayElement:String( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Return String(_Get( p,_elementType ))
	End Method

	Rem
	bbdoc: Get an array element as enum name @String
	about: This method should only be called on the type ID corresponding to the type of the array.
	End Rem
	Method GetEnumArrayElementAsString:String( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		If Not _elementType.IsEnum() Then Throw "Element type is not an enum type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Return bbFieldGetEnum(p, _elementType._enum, "No enum provided", "Invalid enum type")
	End Method
	
	Rem
	bbdoc: Get an array element as @Byte
	End Rem
	Method GetByteArrayElement:Byte( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Short
	End Rem
	Method GetShortArrayElement:Short( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Int
	End Rem
	Method GetIntArrayElement:Int( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @UInt
	End Rem
	Method GetUIntArrayElement:UInt( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Long
	End Rem
	Method GetLongArrayElement:Long( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @ULong
	End Rem
	Method GetULongArrayElement:ULong( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Size_T
	End Rem
	Method GetSizeTArrayElement:Size_T( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Float
	End Rem
	Method GetFloatArrayElement:Float( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @Double
	End Rem
	Method GetDoubleArrayElement:Double( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @LongInt
	End Rem
	Method GetLongIntArrayElement:LongInt( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
	End Method
	
	Rem
	bbdoc: Get an array element as @ULongInt
	End Rem
	Method GetULongIntArrayElement:ULongInt( _array:Object,index:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				Return (Byte Ptr p)[0]
			Case ShortTypeId
				Return (Short Ptr p)[0]
			Case IntTypeId
				Return (Int Ptr p)[0]
			Case UIntTypeId
				Return (UInt Ptr p)[0]
			Case LongTypeId
				Return (Long Ptr p)[0]
			Case ULongTypeId
				Return (ULong Ptr p)[0]
			Case SizetTypeId
				Return (Size_T Ptr p)[0]
			Case FloatTypeId
				Return (Float Ptr p)[0]
			Case DoubleTypeId
				Return (Double Ptr p)[0]
			Case LongIntTypeId
				Return (LongInt Ptr p)[0]
			Case ULongIntTypeId
				Return (ULongInt Ptr p)[0]
		End Select
		If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then Return (Size_T Ptr p)[0]
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
	bbdoc: Set an array element from @Byte
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Byte )
		SetByteArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Short
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Short )
		SetShortArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Int
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Int )
		SetIntArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @UInt
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:UInt )
		SetUIntArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Long
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Long )
		SetLongArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @ULong
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:ULong )
		SetULongArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Size_T
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Size_T )
		SetSizeTArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Float
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Float )
		SetFloatArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @Double
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:Double )
		SetDoubleArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Set an array element from @LongInt
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:LongInt )
		SetLongIntArrayElement(_array, index, value)
	End Method
	
	Rem
	bbdoc: Set an array element from @ULongInt
	End Rem
	Method SetArrayElement( _array:Object,index:Int,value:ULongInt )
		SetULongIntArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Set an enum array element from @String
	End Rem
	Method SetEnumArrayElement( _array:Object,index:Int,value:String )
		If Not _elementType Throw "TypeID is not an array type"
		If Not _elementType.IsEnum() Then Throw "Element type is not an enum type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		bbFieldSetEnum(p, _elementType._enum, value, "No enum provided", "Invalid enum value")
	End Method
	
	Rem
	bbdoc: Set an array element from @Byte
	End Rem
	Method SetByteArrayElement( _array:Object,index:Int,value:Byte )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=value
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Short
	End Rem
	Method SetShortArrayElement( _array:Object,index:Int,value:Short )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=value
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Int
	End Rem
	Method SetIntArrayElement( _array:Object,index:Int,value:Int )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=value
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @UInt
	End Rem
	Method SetUIntArrayElement( _array:Object,index:Int,value:UInt )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=value
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromUInt(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Long
	End Rem
	Method SetLongArrayElement( _array:Object,index:Int,value:Long )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=value
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromLong(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @ULong
	End Rem
	Method SetULongArrayElement( _array:Object,index:Int,value:ULong )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=value
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromULong(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Size_T
	End Rem
	Method SetSizeTArrayElement( _array:Object,index:Int,value:Size_T )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=value
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromSizeT(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Float
	End Rem
	Method SetFloatArrayElement( _array:Object,index:Int,value:Float )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=value
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromFloat(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @Double
	End Rem
	Method SetDoubleArrayElement( _array:Object,index:Int,value:Double )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=value
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @LongInt
	End Rem
	Method SetLongIntArrayElement( _array:Object,index:Int,value:LongInt )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=value
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=ULongInt(value)
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @ULongInt
	End Rem
	Method SetULongIntArrayElement( _array:Object,index:Int,value:ULongInt )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Select _elementType
			Case ByteTypeId
				(Byte Ptr p)[0]=Byte(value)
			Case ShortTypeId
				(Short Ptr p)[0]=Short(value)
			Case IntTypeId
				(Int Ptr p)[0]=Int(value)
			Case UIntTypeId
				(UInt Ptr p)[0]=UInt(value)
			Case LongTypeId
				(Long Ptr p)[0]=Long(value)
			Case ULongTypeId
				(ULong Ptr p)[0]=ULong(value)
			Case SizetTypeId
				(Size_T Ptr p)[0]=Size_T(value)
			Case FloatTypeId
				(Float Ptr p)[0]=Float(value)
			Case DoubleTypeId
				(Double Ptr p)[0]=Double(value)
			Case LongIntTypeId
				(LongInt Ptr p)[0]=LongInt(value)
			Case ULongIntTypeId
				(ULongInt Ptr p)[0]=value
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble(value)
			Default
				If _elementType.ExtendsType(PointerTypeId) Or _elementType.ExtendsType(VarTypeId) Or _elementType.ExtendsType(FunctionTypeId) Then
					(Size_T Ptr p)[0]=Size_T(value)
				Else
					Throw "Unable to assign value of incompatible type"
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Set an array element from @String
	End Rem
	Method SetStringArrayElement( _array:Object,index:Int,value:String )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		_Assign p,_elementType,value
	End Method
	
	Rem
	bbdoc: Size of the type in bytes
	about: For reference types such as classes and interfaces, this function will return the size of the reference (equal to the size of PointerTypeId), not the size of the pointed to instance.
	End Rem
	Method Size:Size_T()
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
			Else If name.EndsWith(" ptr")
				Local baseType:TTypeId = ForName_(name[..name.length-4])
				' check for valid pointer base types
				If baseType And Not (baseType._class Or baseType = VoidTypeId Or baseType = FunctionTypeId Or baseType = PointerTypeId) Then
					Return baseType.PointerType()
				Else
					Return Null
				End If
			' vars
			Else If name.EndsWith(" var")
				Local baseType:TTypeId = ForName_(name[..name.length-4])
				Return baseType.VarType()
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
		Local box:TBoxedValue = TBoxedValue(obj)
		If box Then Return box.typeId
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
	
	Rem
	bbdoc: Get a list of all enum types
	End Rem
	Function EnumEnums:TList()
		_Update
		Local list:TList = New TList
		For Local t:TTypeId = EachIn _enumMap.Values()
			list.AddFirst t
		Next
		Return list
	End Function
	
	Private
	
	Method Init:TTypeId(name$, size:Size_T, class:Byte Ptr = Null, supor:TTypeId = Null, isFinal:Int = True)
		_name = name
		_size = size
		_class = class
		_super = supor
		If isFinal Then _modifiers = EModifiers.IsFinal Else _modifiers = Null
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
		Local name:String = String.FromCString(bbRefClassDebugScopeName(class))
		Local modifierString:String
		Local meta:String
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		i = name.Find("'")
		If i<>-1
			modifierString = name[i+1..]
			name = name[..i]
		EndIf
		_name = name
		_modifiers = ModifiersForTag(modifierString)
		InitMeta(meta)
		_class = class
		_size = SizeOf Byte Ptr Null
		
		_nameMap.Insert _name.ToLower(), Self
		_classMap.Insert class, Self
		Return Self
	End Method
	
	Method InitInterface:TTypeId(ifc:Byte Ptr) ' BBInterface*
		Local name:String = String.FromCString(bbInterfaceName(ifc))
		Local modifierString:String
		Local meta:String
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		i = name.Find("'")
		If i<>-1
			modifierString = name[i+1..]
			name = name[..i]
		EndIf
		_name = name
		_modifiers = ModifiersForTag(modifierString)
		InitMeta(meta)
		_interface = ifc
		_class = bbInterfaceClass(ifc)
		_size = SizeOf Byte Ptr Null
		
		_nameMap.Insert _name.ToLower(), Self
		_interfaceMap.Insert ifc, Self
		_interfaceClassMap.Insert _class, Self
		Return Self
	End Method
	
	Method InitStruct:TTypeId(scope:Byte Ptr) ' BBDebugScope*
		Local name:String = String.FromCString(bbDebugScopeName(scope))
		Local modifierString:String
		Local meta:String
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		i = name.Find("'")
		If i<>-1
			modifierString = name[i+1..]
			name = name[..i]
		EndIf
		_name = name
		_modifiers = ModifiersForTag(modifierString) | EModifiers.IsFinal
		InitMeta(meta)
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
	
	Method InitEnum:TTypeId(scope:Byte Ptr) ' BBDebugScope*
		Local name:String = String.FromCString(bbDebugScopeName(scope))
		Local modifierString:String
		Local meta:String
		Local i% = name.Find("{")
		If i<>-1
			meta = name[i+1..name.length-1]
			name = name[..i]
		EndIf
		i = name.Find("'")
		If i<>-1
			modifierString = name[i+1..]
			name = name[..i]
		EndIf
		_name = name
		_modifiers = ModifiersForTag(modifierString) | EModifiers.IsFinal
		InitMeta(meta)
		_enum = scope
		
		Local p:Byte Ptr = bbDebugScopeDecl(scope)
		While bbDebugDeclKind(p)
			p = bbDebugDeclNext(p)
		Wend
		_underlyingType = TypeIdForTag(String.FromCString(bbDebugDeclType(p)))
		'TODO: if enums support more than just primitives, then
		'      _underlyingType must be checked against Null (unsupported
		'      tag variant found) 
		_size = _underlyingType._size
		_isFlagsEnum = bbDebugDeclIsFlagsEnum(p)
		
		_nameMap.Insert _name.ToLower(), Self
		_enumMap.Insert scope, Self
		Return Self
	End Method

	Global _inited:Int = False

	Function _Initialize()
		_Update(True)
	End Function
	
	Function _Update()
		_Update(False)
	End Function

	Function _Update(complete:Int)
		If _inited Then Return
		If complete Then
			_inited = True
		End If
		Try
			ReflectionMutex.Lock
			Local ccount:Int
			Local icount:Int
			Local scount:Int
			Local ecount:Int
			Local classArray    :Byte Ptr Ptr = bbObjectRegisteredTypes(ccount)      ' BBClass**
			Local interfaceArray:Byte Ptr Ptr = bbObjectRegisteredInterfaces(icount) ' BBInterface**
			Local structArray   :Byte Ptr Ptr = bbObjectRegisteredStructs(scount)    ' BBDebugScope**
			Local enumArray     :Byte Ptr Ptr = bbObjectRegisteredEnums(ecount)      ' BBDebugScope**
			If ccount = _ccount And icount = _icount And scount = _scount And ecount = _ecount Then Return
			
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
			For Local i:Int = _ecount Until ecount
				list.AddLast New TTypeId.InitEnum(enumArray[i])
			Next
			
			_ccount = ccount
			_icount = icount
			_scount = scount
			_ecount = ecount
			For Local t:TTypeId = EachIn list
				t._Resolve
			Next
		Finally
			ReflectionMutex.Unlock
		End Try
	End Function
	
	Method _Resolve()
		If _fields Then Return
		If Not (_class Or _struct Or _enum) Then Return
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
		Else If _enum Then
			p = bbDebugScopeDecl(_enum)
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
			i = ty.Find("'")
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
						Local meth:TMethod = New TMethod.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclFuncPtr(p), bbDebugDeclReflectionWrapper(p), selfTypeId)
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
						Local func:TFunction = New TFunction.Init(id, typeId, ModifiersForTag(modifierString), meta, bbDebugDeclFuncPtr(p), bbDebugDeclReflectionWrapper(p))
						_functions.AddLast func
					End If
			End Select
			p = bbDebugDeclNext(p)
		Wend
		
		If Not (_struct Or _enum) Then
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
	Field _enum:Byte Ptr ' BBDebugScope*
	
	Field _size:Size_T
	
	Field _consts:TList
	Field _fields:TList
	Field _globals:TList
	Field _functions:TList
	Field _methods:TList
	Field _constructors:TList
	Field _defaultConstructor:TMethod
	Field _toString:String(valuePtr:Byte Ptr)
	Field _interfaces:TList
	Field _super:TTypeId
	Field _derived:TList
	Field _typeTag:Byte Ptr
	
	Field _arrayTypes:TTypeId[]
	Field _pointerType:TTypeId
	Field _varType:TTypeId
	Field _functionTypes:TList[]
	Field _elementType:TTypeId
	Field _dimensions:Int
	Field _argTypes:TTypeId[]
	Field _retType:TTypeId
	Field _underlyingType:TTypeId
	Field _isFlagsEnum:Byte
	
	Global _nameMap:TMap = New TMap
	Global _ccount:Int, _classMap:TPtrMap = New TPtrMap
	Global _icount:Int, _interfaceMap:TPtrMap = New TPtrMap, _interfaceClassMap:TPtrMap = New TPtrMap
	Global _scount:Int, _structMap:TPtrMap = New TPtrMap
	Global _ecount:Int, _enumMap:TPtrMap = New TPtrMap
	
End Type

' Initialize reflection system
AtStart(TTypeId._Initialize, $FFFFFF)
