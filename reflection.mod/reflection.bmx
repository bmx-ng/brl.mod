
Strict

Rem
bbdoc: BASIC/Reflection
End Rem
Module BRL.Reflection

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09"
ModuleInfo "History: Threading support."
ModuleInfo "History: 1.08"
ModuleInfo "History: Improved metadata retrieval."
ModuleInfo "History: 1.07"
ModuleInfo "History: Primitive field set/get now avoids passing values through String."
ModuleInfo "History: 1.06"
ModuleInfo "History: Cache lower case memmber names and use map lookup instead of list."
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
Import BRL.Threads
Import BRL.StringBuilder

Import "reflection.c"

Private

Extern

Function bbObjectNew:Object( class:Byte Ptr )="BBObject * bbObjectNew(BBClass *)!"
?Not ptr64
Function bbObjectRegisteredTypes:Int Ptr( count Var )="BBClass** bbObjectRegisteredTypes(int *)!"
Function bbObjectRegisteredInterfaces:Int Ptr( count Var )="BBInterface** bbObjectRegisteredInterfaces(int *)!"
?ptr64
Function bbObjectRegisteredTypes:Long Ptr( count Var )="BBClass** bbObjectRegisteredTypes(int *)!"
Function bbObjectRegisteredInterfaces:Long Ptr( count Var )="BBInterface** bbObjectRegisteredInterfaces(int *)!"
?

Function bbArrayNew1D:Object( typeTag:Byte Ptr,length )="BBArray* bbArrayNew1D(const char *,int )!"
Function bbArraySlice:Object( typeTag:Byte Ptr, _array:Object, _start:Int, _end:Int)="BBArray* bbArraySlice(const char *, BBArray*, int, int)!"


Function bbRefArrayClass:Byte Ptr()
Function bbRefStringClass:Byte Ptr()
Function bbRefObjectClass:Byte Ptr()

Function bbRefArrayLength( _array:Object, dim:Int = 0 )
Function bbRefArrayTypeTag$( _array:Object )
Function bbRefArrayDimensions:Int( _array:Object )
Function bbRefArrayCreate:Object( typeTag:Byte Ptr,dims:Int[] )

Function bbRefFieldPtr:Byte Ptr( obj:Object,index )
Function bbRefMethodPtr:Byte Ptr( obj:Object,index )
Function bbRefArrayElementPtr:Byte Ptr( sz,_array:Object,index )

Function bbRefGetObject:Object( p:Byte Ptr )
Function bbRefPushObject( p:Byte Ptr,obj:Object )
Function bbRefInitObject( p:Byte Ptr,obj:Object )
Function bbRefAssignObject( p:Byte Ptr,obj:Object )

Function bbRefGetObjectClass:Byte Ptr( obj:Object )

Function bbRefGetSuperClass:Byte Ptr( class:Byte Ptr )
Function bbStringFromRef:String( ref:Byte Ptr )
Function bbRefArrayNull:Object()

Function bbInterfaceName:Byte Ptr(ifc:Byte Ptr)
Function bbInterfaceClass:Byte Ptr(ifc:Byte Ptr)
Function bbObjectImplementsInterfaces:Int(class:Byte Ptr)
Function bbObjectImplementedCount:Int(class:Byte Ptr)
Function bbObjectImplementedInterface:Byte Ptr(class:Byte Ptr, index:Int)

Function bbRefClassSuper:Byte Ptr(clas:Byte Ptr)
Function bbRefClassDebugScope:Byte Ptr(clas:Byte Ptr)
Function bbRefClassDebugDecl:Byte Ptr(clas:Byte Ptr)
Function bbRefClassDebugScopeName:Byte Ptr(class:Byte Ptr)
Function bbDebugDeclKind:Int(decl:Byte Ptr)
Function bbDebugDeclName:Byte Ptr(decl:Byte Ptr)
Function bbDebugDeclType:Byte Ptr(decl:Byte Ptr)
Function bbDebugDeclConstValue:String(decl:Byte Ptr)
Function bbDebugDeclFieldOffset:Int(decl:Byte Ptr)
Function bbDebugDeclVarAddress:Byte Ptr(decl:Byte Ptr)
Function bbDebugDeclNext:Byte Ptr(decl:Byte Ptr)

End Extern

Global _guard:TMutex = TMutex.Create()

Function _Get:Object( p:Byte Ptr,typeId:TTypeId )
	Select typeId
	Case ByteTypeId
		Return String.FromInt( (Byte Ptr p)[0] )
	Case ShortTypeId
		Return String.FromInt( (Short Ptr p)[0] )
	Case IntTypeId
		Return String.FromInt( (Int Ptr p)[0] )
	Case UIntTypeId
		Return String.FromUInt( (UInt Ptr p)[0] )
	Case LongTypeId
		Return String.FromLong( (Long Ptr p)[0] )
	Case ULongTypeId
		Return String.FromULong( (ULong Ptr p)[0] )
	Case SizetTypeId
		Return String.FromSizet( (Size_T Ptr p)[0] )
	Case FloatTypeId
		Return String.FromFloat( (Float Ptr p)[0] )
	Case DoubleTypeId
		Return String.FromDouble( (Double Ptr p)[0] )
	Default
		If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not ptr64
			Return String.FromInt( (Int Ptr p)[0] )
?ptr64
			Return String.FromLong( (Long Ptr p)[0] )
?
		EndIf
		Return bbRefGetObject( p )
	End Select
End Function

Function _Push:Byte Ptr( sp:Byte Ptr,typeId:TTypeId,value:Object )
	Select typeId
	Case ByteTypeId,ShortTypeId,IntTypeId
		(Int Ptr sp)[0]=value.ToString().ToInt()
		Return sp+4
	Case UIntTypeId
		(UInt Ptr sp)[0]=value.ToString().ToUInt()
		Return sp+4
	Case LongTypeId
		(Long Ptr sp)[0]=value.ToString().ToLong()
		Return sp+8
	Case ULongTypeId
		(ULong Ptr sp)[0]=value.ToString().ToULong()
		Return sp+8
	Case SizetTypeId
		(Size_T Ptr sp)[0]=value.ToString().ToSizet()
?Not ptr64
		Return sp+4
?ptr64
		Return sp+8
?
	Case FloatTypeId
		(Float Ptr sp)[0]=value.ToString().ToFloat()
		Return sp+4
	Case DoubleTypeId
		(Double Ptr sp)[0]=value.ToString().ToDouble()
		Return sp+8
	Case StringTypeId
		If Not value value=""
		bbRefPushObject sp,value
		Return sp+4
	Default
		If value
			If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not ptr64
				(Int Ptr sp)[0]=value.ToString().ToInt()
				Return sp+4
?ptr64
				(Long Ptr sp)[0]=value.ToString().ToLong()
				Return sp+8
?
			EndIf

			Local c:Byte Ptr=typeId._class
			Local t:Byte Ptr=bbRefGetObjectClass( value )
			While t And t<>c
				t=bbRefGetSuperClass( t )
			Wend
			If Not t Throw "ERROR"
		EndIf
		bbRefPushObject sp,value
		Return sp+4
	End Select
End Function

Function _Assign( p:Byte Ptr,typeId:TTypeId,value:Object )
	Select typeId
	Case ByteTypeId
		(Byte Ptr p)[0]=value.ToString().ToInt()
	Case ShortTypeId
		(Short Ptr p)[0]=value.ToString().ToInt()
	Case IntTypeId
		(Int Ptr p)[0]=value.ToString().ToInt()
	Case UIntTypeId
		(UInt Ptr p)[0]=value.ToString().ToUInt()
	Case LongTypeId
		(Long Ptr p)[0]=value.ToString().ToLong()
	Case ULongTypeId
		(ULong Ptr p)[0]=value.ToString().ToULong()
	Case SizetTypeId
		(Size_T Ptr p)[0]=value.ToString().ToSizet()
	Case FloatTypeId
		(Float Ptr p)[0]=value.ToString().ToFloat()
	Case DoubleTypeId
		(Double Ptr p)[0]=value.ToString().ToDouble()
	Case StringTypeId
		If Not value value=""
		bbRefAssignObject p,value
	Default
		If value
			If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not ptr64
				(Int Ptr p)[0]=value.ToString().ToInt()
?ptr64
				(Long Ptr p)[0]=value.ToString().ToLong()
?
				Return
			EndIf

			Local c:Byte Ptr=typeId._class
			Local t:Byte Ptr=bbRefGetObjectClass( value )
			While t And t<>c
				t=bbRefGetSuperClass( t )
			Wend
			If Not t Throw "ERROR"
		Else
			If typeId.Name().Endswith("]") Then
				value = bbRefArrayNull()
			EndIf
		EndIf
		bbRefAssignObject p,value
	End Select
End Function

Function _CallFunction:Object( p:Byte Ptr,typeId:TTypeId,args:Object[],argTypes:TTypeId[] )
	Local q:Byte Ptr[10]
	If args Then
		For Local i=0 Until args.length
			_Push( Varptr q[i],argTypes[i],args[i] )
		Next
	End If

	Select typeId
	Case ByteTypeId,ShortTypeId,IntTypeId
		Select argTypes.length
			Case 0
				Local f:Int()=p
				Return String.FromInt( f() )
			Case 1
				Local f:Int(p0:Byte Ptr)=p
				Return String.FromInt( f(q[0]) )
			Case 2
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1]) )
			Case 3
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2]) )
			Case 4
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Int(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromInt( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Int(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromInt( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
?Not ptr64
	Case UIntTypeId,SizetTypeId
?ptr64
	Case UIntTypeId
?
		Select argTypes.length
			Case 0
				Local f:UInt()=p
				Return String.FromUInt( f() )
			Case 1
				Local f:UInt(p0:Byte Ptr)=p
				Return String.FromUInt( f(q[0]) )
			Case 2
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1]) )
			Case 3
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2]) )
			Case 4
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:UInt(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromUInt( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:UInt(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromUInt( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case LongTypeId
		Select argTypes.length
			Case 0
				Local f:Long()=p
				Return String.Fromlong( f() )
			Case 1
				Local f:Long(p0:Byte Ptr)=p
				Return String.Fromlong( f(q[0]) )
			Case 2
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1]) )
			Case 3
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2]) )
			Case 4
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Long(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.Fromlong( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Long(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.Fromlong( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
?Not ptr64
	Case ULongTypeId
?ptr64
	Case ULongTypeId,SizetTypeId
?
		Select argTypes.length
			Case 0
				Local f:ULong()=p
				Return String.FromULong( f() )
			Case 1
				Local f:ULong(p0:Byte Ptr)=p
				Return String.FromULong( f(q[0]) )
			Case 2
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1]) )
			Case 3
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2]) )
			Case 4
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:ULong(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromULong( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:ULong(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromULong( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case FloatTypeId
		Select argTypes.length
			Case 0
				Local f:Float()=p
				Return String.FromFloat( f() )
			Case 1
				Local f:Float(p0:Byte Ptr)=p
				Return String.FromFloat( f(q[0]) )
			Case 2
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1]) )
			Case 3
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2]) )
			Case 4
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Float(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromFloat( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Float(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromFloat( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case DoubleTypeId
		Select argTypes.length
			Case 0
				Local f:Double()=p
				Return String.FromDouble( f() )
			Case 1
				Local f:Double(p0:Byte Ptr)=p
				Return String.FromDouble( f(q[0]) )
			Case 2
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1]) )
			Case 3
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2]) )
			Case 4
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Double(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromDouble( f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Double(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromDouble( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case VoidTypeId
		Select argTypes.length
			Case 0
				Local f()=p
				f()
			Case 1
				Local f(p0:Byte Ptr)=p
				f(q[0])
			Case 2
				Local f(p0:Byte Ptr, p1:Byte Ptr)=p
				f(q[0], q[1])
			Case 3
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				f(q[0], q[1], q[2])
			Case 4
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				f(q[0], q[1], q[2], q[3])
			Case 5
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				f(q[0], q[1], q[2], q[3], q[4])
			Case 6
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				f(q[0], q[1], q[2], q[3], q[4], q[5])
			Case 7
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				f(q[0], q[1], q[2], q[3], q[4], q[5], q[6])
			Case 8
				Local f(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7])
			Default
				Local f(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] )
		End Select
	Default
		If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not ptr64
			Select argTypes.length
				Case 0
					Local f:Byte Ptr()=p
					Return String.FromInt(Int f())
				Case 1
					Local f:Byte Ptr(p0:Byte Ptr)=p
					Return String.FromInt(Int f(q[0]))
				Case 2
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1]))
				Case 3
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2]))
				Case 4
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2], q[3]))
				Case 5
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2], q[3], q[4]))
				Case 6
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2], q[3], q[4], q[5]))
				Case 7
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]))
				Case 8
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return String.FromInt(Int f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]))
				Default
					Local f:Byte Ptr(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return String.FromInt(Int f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ))
			End Select
?ptr64
			Select argTypes.length
				Case 0
					Local f:Byte Ptr()=p
					Return String.Fromlong(Long f())
				Case 1
					Local f:Byte Ptr(p0:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0]))
				Case 2
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1]))
				Case 3
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2]))
				Case 4
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2], q[3]))
				Case 5
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2], q[3], q[4]))
				Case 6
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2], q[3], q[4], q[5]))
				Case 7
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2], q[3], q[4], q[5], q[6]))
				Case 8
					Local f:Byte Ptr(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return String.Fromlong(Long f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]))
				Default
					Local f:Byte Ptr(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return String.Fromlong(Long f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ))
			End Select
?
		Else
			Select argTypes.length
				Case 0
					Local f:Object()=p
					Return f()
				Case 1
					Local f:Object(p0:Byte Ptr)=p
					Return f(q[0])
				Case 2
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr)=p
					Return f(q[0], q[1])
				Case 3
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return f(q[0], q[1], q[2])
				Case 4
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return f(q[0], q[1], q[2], q[3])
				Case 5
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return f(q[0], q[1], q[2], q[3], q[4])
				Case 6
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return f(q[0], q[1], q[2], q[3], q[4], q[5])
				Case 7
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return f(q[0], q[1], q[2], q[3], q[4], q[5], q[6])
				Case 8
					Local f:Object(p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return f(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7])
				Default
					Local f:Object(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] )
			End Select
		End If
	End Select
End Function

Function _CallMethod:Object( p:Byte Ptr,typeId:TTypeId,obj:Object,args:Object[],argTypes:TTypeId[] )
	Local q:Byte Ptr[10]',sp:Byte Ptr=q
	'bbRefPushObject sp,obj
	'sp:+4
	'If typeId=LongTypeId sp:+8
	If args Then
		For Local i=0 Until args.length
			'If Int Ptr(sp)>=Int Ptr(q)+8 Throw "ERROR"
			_Push( Varptr q[i],argTypes[i],args[i] )
		Next
	End If
	'If Int Ptr(sp)>Int Ptr(q)+8 Throw "ERROR"
	Local retType:TTypeId = typeId._retType
	Select retType
	Case ByteTypeId,ShortTypeId,IntTypeId
		Select argTypes.length
			Case 0
				Local f:Int(m:Object)=p
				Return String.FromInt( f(obj) )
			Case 1
				Local f:Int(m:Object, p0:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0]) )
			Case 2
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1]) )
			Case 3
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Int(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Int(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromInt( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
?Not ptr64
	Case UIntTypeId,SizetTypeId
?ptr64
	Case UIntTypeId
?
		Select argTypes.length
			Case 0
				Local f:UInt(m:Object)=p
				Return String.FromUInt( f(obj) )
			Case 1
				Local f:UInt(m:Object, p0:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0]) )
			Case 2
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1]) )
			Case 3
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:UInt(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromUInt( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:UInt(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromUInt( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case LongTypeId
		Select argTypes.length
			Case 0
				Local f:Long(m:Object)=p
				Return String.Fromlong( f(obj) )
			Case 1
				Local f:Long(m:Object, p0:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0]) )
			Case 2
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1]) )
			Case 3
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Long(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.Fromlong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Long(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.Fromlong( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
?Not ptr64
	Case ULongTypeId
?ptr64
	Case ULongTypeId,SizetTypeId
?
		Select argTypes.length
			Case 0
				Local f:ULong(m:Object)=p
				Return String.FromULong( f(obj) )
			Case 1
				Local f:ULong(m:Object, p0:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0]) )
			Case 2
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1]) )
			Case 3
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:ULong(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromULong( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:ULong(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromULong( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case FloatTypeId
		Select argTypes.length
			Case 0
				Local f:Float(m:Object)=p
				Return String.FromFloat( f(obj) )
			Case 1
				Local f:Float(m:Object, p0:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0]) )
			Case 2
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1]) )
			Case 3
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Float(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromFloat( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Float(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromFloat( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case DoubleTypeId
		Select argTypes.length
			Case 0
				Local f:Double(m:Object)=p
				Return String.FromDouble( f(obj) )
			Case 1
				Local f:Double(m:Object, p0:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0]) )
			Case 2
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1]) )
			Case 3
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2]) )
			Case 4
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2], q[3]) )
			Case 5
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2], q[3], q[4]) )
			Case 6
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2], q[3], q[4], q[5]) )
			Case 7
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]) )
			Case 8
				Local f:Double(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				Return String.FromDouble( f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]) )
			Default
				Local f:Double(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				Return String.FromDouble( f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ) )
		End Select
	Case VoidTypeId
		Select argTypes.length
			Case 0
				Local f(m:Object)=p
				f(obj)
			Case 1
				Local f(m:Object, p0:Byte Ptr)=p
				f(obj, q[0])
			Case 2
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
				f(obj, q[0], q[1])
			Case 3
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
				f(obj, q[0], q[1], q[2])
			Case 4
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
				f(obj, q[0], q[1], q[2], q[3])
			Case 5
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
				f(obj, q[0], q[1], q[2], q[3], q[4])
			Case 6
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
				f(obj, q[0], q[1], q[2], q[3], q[4], q[5])
			Case 7
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
				f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6])
			Case 8
				Local f(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
				f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7])
			Default
				Local f(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
				f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] )
		End Select
	Default
		If retType.ExtendsType(PointerTypeId) Or retType.ExtendsType(FunctionTypeId) Then
?Not ptr64
			Select argTypes.length
				Case 0
					Local f:Byte Ptr(m:Object)=p
					Return String.FromInt(Int f(obj))
				Case 1
					Local f:Byte Ptr(m:Object, p0:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0]))
				Case 2
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1]))
				Case 3
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2]))
				Case 4
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2], q[3]))
				Case 5
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2], q[3], q[4]))
				Case 6
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2], q[3], q[4], q[5]))
				Case 7
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]))
				Case 8
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return String.FromInt(Int f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]))
				Default
					Local f:Byte Ptr(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return String.FromInt(Int f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ))
			End Select
?ptr64
			Select argTypes.length
				Case 0
					Local f:Byte Ptr(m:Object)=p
					Return String.FromLong(Long f(obj))
				Case 1
					Local f:Byte Ptr(m:Object, p0:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0]))
				Case 2
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1]))
				Case 3
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2]))
				Case 4
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2], q[3]))
				Case 5
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2], q[3], q[4]))
				Case 6
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2], q[3], q[4], q[5]))
				Case 7
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6]))
				Case 8
					Local f:Byte Ptr(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return String.FromLong(Long f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]))
				Default
					Local f:Byte Ptr(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return String.FromLong(Long f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] ))
			End Select
?
		Else
			Select argTypes.length
				Case 0
					Local f:Object(m:Object)=p
					Return f(obj)
				Case 1
					Local f:Object(m:Object, p0:Byte Ptr)=p
					Return f(obj, q[0])
				Case 2
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr)=p
					Return f(obj, q[0], q[1])
				Case 3
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2])
				Case 4
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2], q[3])
				Case 5
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2], q[3], q[4])
				Case 6
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2], q[3], q[4], q[5])
				Case 7
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6])
				Case 8
					Local f:Object(m:Object, p0:Byte Ptr, p1:Byte Ptr, p2:Byte Ptr, p3:Byte Ptr, p4:Byte Ptr, p5:Byte Ptr, p6:Byte Ptr, p7:Byte Ptr)=p
					Return f(obj, q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7])
				Default
					Local f:Object(p0:Byte Ptr,p1:Byte Ptr,p2:Byte Ptr,p3:Byte Ptr,p4:Byte Ptr,p5:Byte Ptr,p6:Byte Ptr,p7:Byte Ptr)=p
					Return f( q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7] )
			End Select
		End If
	End Select
End Function

Function TypeTagForId$( id:TTypeId )
	If id.ExtendsType( ArrayTypeId )
		Return "[]"+TypeTagForId( id.ElementType() )
	EndIf
	If id.ExtendsType( PointerTypeId )
		Return "*"+TypeTagForId(id._elementType)
	EndIf
	If id.ExtendsType( FunctionTypeId )
		Local s:String
		For Local t:TTypeId = EachIn id._argTypes
			If s Then s :+ ","
			s :+ TypeTagForId(t)
		Next
		s = "(" + s + ")"
		If id._retType Then s :+ TypeTagForId(id._retType)
		Return s
	EndIf
	Select id
	Case ByteTypeId Return "b"
	Case ShortTypeId Return "s"
	Case IntTypeId Return "i"
	Case UIntTypeId Return "u"
	Case LongTypeId Return "l"
	Case ULongTypeId Return "y"
	Case SizetTypeId Return "t"
	Case FloatTypeId Return "f"
	Case DoubleTypeId Return "d"
	Case StringTypeId Return "$"
	Case PointerTypeId Return "*"
	Case FunctionTypeId Return "("
	End Select
	If id.ExtendsType( ObjectTypeId )
		Return ":"+id.Name()
	EndIf
	Throw "ERROR"
End Function

Public
Function TypeIdForTag:TTypeId( ty$ )
	If ty.StartsWith( "[" )
		Local dims:Int = ty.split(",").length
		ty=ty[ty.Find("]")+1..]
		Local id:TTypeId = TypeIdForTag( ty )
		If id Then
			id=id.ArrayType(dims)
		End If
		Return id
	EndIf
	If ty.StartsWith( ":" )
		ty=ty[1..]
		Local i=ty.FindLast( "." )
		If i<>-1 ty=ty[i+1..]
		Return TTypeId.ForName( ty )
	EndIf
	If ty.StartsWith( "*" ) Then
		ty = ty[1..]
		Local id:TTypeId = TypeIdForTag( ty )
		If id Then
			id = id.PointerType()
		EndIf
		Return id
	EndIf
	If ty.StartsWith( "(" ) Then
		Local t:String[]
		Local idx:Int = ty.FindLast(")")
		If idx > 0 Then
			t = [ ty[1..idx], ty[idx+1..] ]
		Else
			t = [ ty[1..], "" ]
		EndIf
		Local retType:TTypeId=TypeIdForTag( t[1] ), argTypes:TTypeId[]
		If t[0].length>0 Then
			Local i:Int,b:Int,q$=t[0], args:TList=New TList
			While i < q.length
				Select q[i]
				Case Asc( "," )
					args.AddLast q[b..i]
					i:+1
					b=i
				Case Asc( "[" )
					i:+1
					While i<q.length And q[i]=Asc(",")
						i:+1
					Wend
				Case Asc( "(" )
					Local level:Int = 1
					i:+1
					While i < q.Length
						If q[i] = Asc(",") Then
							If level = 0 Then
								Exit
							End If
						ElseIf q[i] = Asc(")") Then
							level :- 1
						ElseIf q[i] = Asc("(") Then
							level :+ 1
						EndIf
						i:+1
					Wend
				Default
					i:+1
				End Select
			Wend
			If b < q.Length Then args.AddLast q[b..]

			argTypes=New TTypeId[args.Count()]

			i=0
			For Local s:String = EachIn args
				argTypes[i]=TypeIdForTag( s )
				If Not argTypes[i] Then argTypes[i] = ObjectTypeId
				i:+1
			Next
		EndIf
		If Not retType Then retType = ObjectTypeId
		Return retType.FunctionType(argTypes)
	EndIf
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
	Case "" Return VoidTypeId
	End Select
End Function
Private
Function ExtractMetaMap:TStringMap( meta:String )
	If Not meta Then
		Return Null
	End If

	Local map:TStringMap = New TStringMap

	Local key:String
	Local value:String
	
	Local i=0
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

Public

Rem
bbdoc: Primitive byte type
End Rem
Global ByteTypeId:TTypeId=New TTypeId.Init( "Byte",1 )

Rem
bbdoc: Primitive short type
End Rem
Global ShortTypeId:TTypeId=New TTypeId.Init( "Short",2 )

Rem
bbdoc: Primitive int type
End Rem
Global IntTypeId:TTypeId=New TTypeId.Init( "Int",4 )

Rem
bbdoc: Primitive unsigned int type
End Rem
Global UIntTypeId:TTypeId=New TTypeId.Init( "UInt",4 )

Rem
bbdoc: Primitive long type
End Rem
Global LongTypeId:TTypeId=New TTypeId.Init( "Long",8 )

Rem
bbdoc: Primitive unsigned long type
End Rem
Global ULongTypeId:TTypeId=New TTypeId.Init( "ULong",8 )

Rem
bbdoc: Primitive size_t type
End Rem
?Not ptr64
Global SizetTypeId:TTypeId=New TTypeId.Init( "size_t",4 )
?ptr64
Global SizetTypeId:TTypeId=New TTypeId.Init( "size_t",8 )
?

Rem
bbdoc: Primitive float type
End Rem
Global FloatTypeId:TTypeId=New TTypeId.Init( "Float",4 )

Rem
bbdoc: Primitive double type
End Rem
Global DoubleTypeId:TTypeId=New TTypeId.Init( "Double",8 )

Rem
bbdoc: Primitive object type
End Rem
?Not ptr64
Global ObjectTypeId:TTypeId=New TTypeId.Init( "Object",4,bbRefObjectClass() )
?ptr64
Global ObjectTypeId:TTypeId=New TTypeId.Init( "Object",8,bbRefObjectClass() )
?

Rem
bbdoc: Primitive string type
End Rem
?Not ptr64
Global StringTypeId:TTypeId=New TTypeId.Init( "String",4,bbRefStringClass(),ObjectTypeId )
?ptr64
Global StringTypeId:TTypeId=New TTypeId.Init( "String",8,bbRefStringClass(),ObjectTypeId )
?

Rem
bbdoc: Primitive array type
End Rem
?Not ptr64
Global ArrayTypeId:TTypeId=New TTypeId.Init( "Null[]",4,bbRefArrayClass(),ObjectTypeId )
?ptr64
Global ArrayTypeId:TTypeId=New TTypeId.Init( "Null[]",8,bbRefArrayClass(),ObjectTypeId )
?

' Void Type
' Only used For Function/Method Return types
Global VoidTypeId:TTypeId=New TTypeId.Init( "Void",0 )

Rem
bbdoc: Primitive pointer type
End Rem
?Not ptr64
Global PointerTypeId:TTypeId=New TTypeId.Init( "Ptr",4 )
?ptr64
Global PointerTypeId:TTypeId=New TTypeId.Init( "Ptr",8 )
?

Rem
bbdoc: Primitive function type
End Rem
?Not ptr64
Global FunctionTypeId:TTypeId=New TTypeId.Init( "Null()",4 )
?ptr64
Global FunctionTypeId:TTypeId=New TTypeId.Init( "Null()",8 )
?

Rem
bbdoc: Type member - Field Or Method.
End Rem
Type TMember

	Rem
	bbdoc: Get member name
	End Rem
	Method Name$()
		Return _name
	End Method

	Method NameLower$()
		If Not _nameLower Then
			_nameLower = _name.ToLower()
		End If
		Return _nameLower
	End Method

	Rem
	bbdoc: Get member type
	End Rem
	Method TypeId:TTypeId()
		Return _typeId
	End Method

	Rem
	bbdoc: Get member meta data
	End Rem
	Method MetaData$( key$="" )
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
	
	Method InitMeta(meta:String)
		_meta = meta
		_metaMap = ExtractMetaMap(meta)
	End Method

	Field _name$,_typeId:TTypeId,_meta$
	Field _nameLower$
	Field _metaMap:TStringMap

End Type

Rem
bbdoc: Type constant
EndRem
Type TConstant Extends TMember

	Method Init:TConstant( name:String, typeId:TTypeId, meta:String, str:String)
		_name = name
		_typeId = typeId
		InitMeta(meta)
		_string = str
		Return Self
	EndMethod

	Rem
	bbdoc: Get constant value
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
	bbdoc: Get constant value as @Float
	EndRem
	Method GetFloat:Int()
		Return GetString().ToFloat()
	EndMethod

	Rem
	bbdoc: Get constant value as @Long
	EndRem
	Method GetLong:Long()
		Return GetString().ToLong()
	EndMethod

	Rem
	bbdoc: Get constant value as @size_t
	EndRem
	Method GetSizet:Size_T()
		Return GetString().ToSizet()
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
?Not ptr64
		Return Byte Ptr GetString().ToInt()
?ptr64
		Return Byte Ptr GetString().ToLong()
?
	EndMethod

	Field _string:String
EndType

Rem
bbdoc: Type field
End Rem
Type TField Extends TMember

	Method Init:TField( name$,typeId:TTypeId,meta$,index )
		_name=name
		_typeId=typeId
		InitMeta(meta)
		_index=index
		Return Self
	End Method

	Rem
	bbdoc: Get field value
	End Rem
	Method Get:Object( obj:Object )
		Return _Get( bbRefFieldPtr( obj,_index ),_typeId )
	End Method

	Rem
	bbdoc: Get #Byte field value
	End Rem
	Method GetByte:Byte( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #Short field value
	End Rem
	Method GetShort:Short( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #Int field value
	End Rem
	Method GetInt:Int( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #UInt field value
	End Rem
	Method GetUInt:UInt( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get long field value
	End Rem
	Method GetLong:Long( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #ULong field value
	End Rem
	Method GetULong:ULong( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #Size_T field value
	End Rem
	Method GetSizet:Size_T( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #Float field value
	End Rem
	Method GetFloat:Float( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #Double field value
	End Rem
	Method GetDouble:Double( obj:Object )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
		End Select
	End Method

	Rem
	bbdoc: Get #String field value
	End Rem
	Method GetString$( obj:Object )
		Return String( Get( obj ) )
	End Method

	Rem
	bbdoc: Set field value
	End Rem
	Method Set( obj:Object,value:Object )
		_Assign bbRefFieldPtr( obj,_index ),_typeId,value
	End Method

	Rem
	bbdoc: Set #Byte field value
	End Rem
	Method Set( obj:Object,value:Byte )
		SetByte(obj, value)
	End Method

	Rem
	bbdoc: Set #Short field value
	End Rem
	Method Set( obj:Object,value:Short )
		SetShort(obj, value)
	End Method

	Rem
	bbdoc: Set #Int field value
	End Rem
	Method Set( obj:Object,value:Int )
		SetInt(obj, value)
	End Method

	Rem
	bbdoc: Set #UInt field value
	End Rem
	Method Set( obj:Object,value:UInt )
		SetUInt(obj, value)
	End Method

	Rem
	bbdoc: Set #Long field value
	End Rem
	Method Set( obj:Object,value:Long )
		SetLong(obj, value)
	End Method

	Rem
	bbdoc: Set #ULong field value
	End Rem
	Method Set( obj:Object,value:ULong )
		SetULong(obj, value)
	End Method

	Rem
	bbdoc: Set #Size_T field value
	End Rem
	Method Set( obj:Object,value:Size_T )
		SetSizet(obj, value)
	End Method

	Rem
	bbdoc: Set #Float field value
	End Rem
	Method Set( obj:Object,value:Float )
		SetFloat(obj, value)
	End Method

	Rem
	bbdoc: Set #Double field value
	End Rem
	Method Set( obj:Object,value:Double )
		SetDouble(obj, value)
	End Method

	Rem
	bbdoc: Set #Object field value
	End Rem
	Method SetObject( obj:Object,value:Object )
		_Assign bbRefFieldPtr( obj,_index ),_typeId,value
	End Method

	Rem
	bbdoc: Set #Byte field value
	End Rem
	Method SetByte( obj:Object,value:Byte )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Short field value
	End Rem
	Method SetShort( obj:Object,value:Short )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Int field value
	End Rem
	Method SetInt( obj:Object,value:Int )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt( value )
		End Select
	End Method

	Rem
	bbdoc: Set #UInt field value
	End Rem
	Method SetUInt( obj:Object,value:UInt )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromUInt( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Long field value
	End Rem
	Method SetLong( obj:Object,value:Long )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromLong( value )
		End Select
	End Method

	Rem
	bbdoc: Set #ULong field value
	End Rem
	Method SetULong( obj:Object,value:ULong )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromULong( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Size_T field value
	End Rem
	Method SetSizet( obj:Object,value:Size_T )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromSizet( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Float field value
	End Rem
	Method SetFloat( obj:Object,value:Float )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromFloat( value )
		End Select
	End Method

	Rem
	bbdoc: Set #Double field value
	End Rem
	Method SetDouble( obj:Object,value:Double )
		Local p:Byte Ptr = bbRefFieldPtr( obj,_index )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble( value )
		End Select
	End Method

	Rem
	bbdoc: Set #String field value
	End Rem
	Method SetString( obj:Object,value$ )
		Set obj,value
	End Method

	Field _index

End Type

Rem
bbdoc: Type global
End Rem
Type TGlobal Extends TMember

	Method Init:TGlobal( name$,typeId:TTypeId,meta$,ref:Byte Ptr )
		_name=name
		_typeId=typeId
		InitMeta(meta)
		_ref=ref
		Return Self
	End Method

	Rem
	bbdoc: Get global value
	End Rem
	Method Get:Object()
		Return _Get( _ref,_typeId )
	End Method

	Rem
	bbdoc: Get int global value
	End Rem
	Method GetInt:Int( )
		Return GetString().ToInt()
	End Method

	Rem
	bbdoc: Get long global value
	End Rem
	Method GetLong:Long()
		Return GetString().ToLong()
	End Method

	Rem
	bbdoc: Get size_t global value
	End Rem
	Method GetSizet:Size_T()
		Return GetString().ToSizet()
	End Method

	Rem
	bbdoc: Get float global value
	End Rem
	Method GetFloat:Float()
		Return GetString().ToFloat()
	End Method

	Rem
	bbdoc: Get double global value
	End Rem
	Method GetDouble:Double()
		Return GetString().ToDouble()
	End Method

	Rem
	bbdoc: Get string global value
	End Rem
	Method GetString$()
		Return String( Get() )
	End Method

	Rem
	bbdoc: Set global value
	End Rem
	Method Set(value:Object )
		_Assign _ref,_typeId,value
	End Method

	Rem
	bbdoc: Set int global value
	End Rem
	Method SetInt(value:Int )
		SetString String.FromInt( value )
	End Method

	Rem
	bbdoc: Set long global value
	End Rem
	Method SetLong(value:Long )
		SetString String.FromLong( value )
	End Method

	Rem
	bbdoc: Set size_t global value
	End Rem
	Method SetSizet(value:Size_T )
		SetString String.FromSizet( value )
	End Method

	Rem
	bbdoc: Set float global value
	End Rem
	Method SetFloat(value:Float )
		SetString String.FromFloat( value )
	End Method

	Rem
	bbdoc: Set double global value
	End Rem
	Method SetDouble(value:Double )
		SetString String.FromDouble( value )
	End Method

	Rem
	bbdoc: Set string global value
	End Rem
	Method SetString(value$ )
		Set value
	End Method

	Field _ref:Byte Ptr

End Type

Rem
bbdoc: Type function
endrem
Type TFunction Extends TMember
	Method Init:TFunction(name:String, typeId:TTypeId, meta:String, selfTypeId:TTypeId, ref:Byte Ptr, argTypes:TTypeId[])
		_name=name
		_typeId=typeId
		InitMeta(meta)
		_selfTypeId=selfTypeId
		_ref=ref
		_argTypes=argTypes
		Return Self
	End Method

	Rem
	bbdoc: Get function arg types
	End Rem
	Method ArgTypes:TTypeId[]()
		Return _argTypes
	End Method

	Rem
	bbdoc: Get function return type
	End Rem
	Method ReturnType:TTypeId()
		Return _typeId
	End Method

	Rem
	bbdoc: Get function pointer.
	endrem
	Method FunctionPtr:Byte Ptr()
		Return _ref
	End Method

	Rem
	bbdoc: Invoke type function
	endrem
	Method Invoke:Object(args:Object[] = Null)
		Return _CallFunction( _ref, _typeId, args, _argTypes)
	End Method

	Field _selfTypeId:TTypeId
	Field _ref:Byte Ptr
	Field _argTypes:TTypeId[]
EndType

Rem
bbdoc: Type method
End Rem
Type TMethod Extends TMember

	Method Init:TMethod( name$,typeId:TTypeId,meta$,selfTypeId:TTypeId,ref:Byte Ptr,argTypes:TTypeId[] )
		_name=name
		_typeId=typeId
		InitMeta(meta)
		_selfTypeId=selfTypeId
		_ref=ref
		_argTypes=argTypes
		Return Self
	End Method

	Rem
	bbdoc: Get method arg types
	End Rem
	Method ArgTypes:TTypeId[]()
		Return _argTypes
	End Method

	Method ReturnType:TTypeId()
		Return _typeId._retType
	End Method

	Rem
	bbdoc: Invoke method
	End Rem
	Method Invoke:Object( obj:Object,args:Object[] = Null)
		Return _CallMethod( _ref,_typeId,obj,args,_argTypes )
	End Method

	Field _selfTypeId:TTypeId
	Field _ref:Byte Ptr
	Field _argTypes:TTypeId[]

End Type

Rem
bbdoc: Type id
End Rem
Type TTypeId

	Rem
	bbdoc: Get name of type
	End Rem
	Method Name$()
		Return _name
	End Method

	Rem
	bbdoc: Get type meta data
	End Rem
	Method MetaData$( key$="" )
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

	Rem
	bbdoc: Get super type
	End Rem
	Method SuperType:TTypeId()
		Return _super
	End Method

	Rem
	bbdoc: Get array type
	End Rem
	Method ArrayType:TTypeId(dims:Int = 1)
		Try
			_guard.Lock()
			
			If dims >= _arrayType.length Then
				_arrayType = _arrayType[..dims + 1]
			End If
			
			Local at:TTypeId = _arrayType[dims]
			
			If Not at
				Local dim:String
				If dims > 1 Then
					For Local i:Int = 1 Until dims
						dim :+ ","
					Next
				End If			
?Not ptr64
				at = New TTypeId.Init( _name+"[" + dim + "]",4,bbRefArrayClass() )
?ptr64
				at = New TTypeId.Init( _name+"[" + dim + "]",8,bbRefArrayClass() )
?
				at._elementType=Self
				If _super
					at._super=_super.ArrayType()
				Else
					at._super=ArrayTypeId
				EndIf
				
				_arrayType[dims] = at
			EndIf
			Return at

		Finally
			_guard.Unlock()
		End Try
	End Method

	Rem
	bbdoc: Get element type
	End Rem
	Method ElementType:TTypeId()
		Return _elementType
	End Method

	Rem
	bbdoc: Get pointer type
	End Rem
	Method PointerType:TTypeId()
		Try
			_guard.Lock()
			
			Local pt:TTypeId = _pointerType
			If Not pt Then
	?Not ptr64
				pt = New TTypeId.Init( _name + " Ptr", 4)
	?ptr64
				pt = New TTypeId.Init( _name + " Ptr", 8)
	?
				pt._elementType = Self
				If _super Then
					pt._super = _super.PointerType()
				Else
					pt._super = PointerTypeId
				EndIf
				
				_pointertype = pt
			EndIf
			Return pt

		Finally
			_guard.Unlock()
		End Try
	End Method

	Rem
	bbdoc: Get function pointer type
	End Rem
	Method FunctionType:TTypeId( args:TTypeId[]=Null)
		Local s:String
		If args.length > 2 Then
			Local sb:TStringBuilder = New TStringBuilder()
			For Local t:TTypeId = EachIn args
				If sb.Length() sb.Append(",")
				sb.Append(t.Name())
			Next
		Else
			For Local t:TTypeId = EachIn args
				If s Then s :+ ","
				s :+ t.Name()
			Next 
		End If
		
		If Not _functionType Then
			_functionType = New TStringMap
		End If
		
		Local ft:TTypeId = TTypeId(_functionType.ValueForKey(s))
	
		If Not ft Then
?Not ptr64
			ft = New TTypeId.Init( _name + "(" + s + ")", 4)
?ptr64
			ft = New TTypeId.Init( _name + "(" + s + ")", 8)
?
			ft._retType = Self
			ft._argTypes = args
			If _super Then
				ft._super = _super.FunctionType()
			Else
				ft._super = FunctionTypeId
			EndIf
			
			_functionType.Insert(s, ft)
		EndIf
		Return ft
	End Method

	Rem
	bbdoc: Get function return type
	End Rem
	Method ReturnType:TTypeId()
		If Not _retType Then Throw "TypeID is not a function type"
		Return _retType
	End Method

	Rem
	bbdoc: Get function argument types
	End Rem
	Method ArgTypes:TTypeId[]()
		If Not _retType Then Throw "TypeID is not a function type"
		Return _argTypes
	End Method

	Rem
	bbdoc: Determine if type extends a type
	End Rem
	Method ExtendsType( typeId:TTypeId )
		If Self=typeId Return True
		If _super Return _super.ExtendsType( typeId )
	End Method

	Rem
	bbdoc: Get list of derived types
	End Rem
	Method DerivedTypes:TList()
		If Not _derived _derived=New TList
		Return _derived
	End Method

	Rem
	bbdoc: Create a new object
	End Rem
	Method NewObject:Object()
		If Not _class Throw "Unable to create new object"
		If _interface Throw "Unable to create object from interface"
		Return bbObjectNew( _class )
	End Method

	Rem
	bbdoc: Returns True if this TypeId is an interface.
	End Rem
	Method IsInterface:Int()
		Return _interface <> Null
	End Method

	Rem
	bbdoc: Get list of constants
	about: Only returns constants declared in this type, not in super types.
	End Rem
	Method Constants:TStringMap()
		Return _consts
	End Method

	Rem
	bbdoc: Get list of fields
	about: Only returns fields declared in this type, not in super types.
	End Rem
	Method Fields:TStringMap()
		Return _fields
	End Method

	Rem
	bbdoc: Get list of globals
	about: Only returns globals declared in this type, not in super types.
	End Rem
	Method Globals:TStringMap()
		Return _globals
	End Method

	Rem
	bbdoc: Get list of functions
	about: Only returns functions declared in this type, not in super types.
	EndRem
	Method Functions:TStringMap()
		Return _functions
	End Method

	Rem
	bbdoc: Get list of methods
	about: Only returns methods declared in this type, not in super types.
	End Rem
	Method Methods:TStringMap()
		Return _methods
	End Method

	Rem
	bbdoc: Get list of implemented interfaces.
	End Rem
	Method Interfaces:TList()
		Return _interfaces
	End Method

	Rem
	bbdoc: Find a constant by name
	about: Searchs type hierarchy for constant called @name.
	End Rem
	Method FindConstant:TConstant( name$ )
		name=name.ToLower()
		Local t:TConstant = TConstant(_consts.ValueForKey(name))
		If t Return t
'		For Local t:TConstant=EachIn _consts
'			If t.NameLower()=name Return t
'		Next
		If _super Return _super.FindConstant( name )
	End Method

	Rem
	bbdoc: Find a field by name
	about: Searchs type hierarchy for field called @name.
	End Rem
	Method FindField:TField( name$ )
		name=name.ToLower()
		Local t:TField = TField(_fields.ValueForKey(name))
		If t Then Return t
		If _super Return _super.FindField( name )
	End Method

	Rem
	bbdoc: Find a global by name
	about: Searchs type hierarchy for global called @name.
	End Rem
	Method FindGlobal:TGlobal( name$ )
		name=name.ToLower()
		Local t:TGlobal = TGlobal(_globals.ValueForKey(name))
		If t Then Return t
		If _super Return _super.FindGlobal( name )
	End Method

	Rem
	bbdoc: Find a function by name
	about: Searches type heirarchy for function called @name
	endrem
	Method FindFunction:TFunction(name:String)
		name = name.ToLower()
		Local t:TFunction = TFunction(_functions.ValueForKey(name))
		If t Then Return t
		If _super Return _super.FindFunction(name)
	End Method

	Rem
	bbdoc: Find a method by name
	about: Searchs type hierarchy for method called @name.
	End Rem
	Method FindMethod:TMethod( name$ )
		name=name.ToLower()
		Local t:TMethod = TMethod(_methods.ValueForKey(name))
		If t Then Return t
		If _super Return _super.FindMethod( name )
	End Method

	Rem
	bbdoc: Enumerate all constants
	about: Returns a list of all constants in type hierarchy
	End Rem
	Method EnumConstants:TList( list:TList=Null )
		If Not list list=New TList
		If _super _super.EnumConstants list
		For Local t:TConstant=EachIn _constsList '.Values()
			list.AddLast t
		Next
		Return list
	End Method

	Rem
	bbdoc: Enumerate all fields
	about: Returns a list of all fields in type hierarchy
	End Rem
	Method EnumFields:TList( list:TList=Null )
		If Not list list=New TList
		If _super _super.EnumFields list
		For Local t:TField=EachIn _fieldsList '.Values()
			list.AddLast t
		Next
		Return list
	End Method

	Rem
	bbdoc: Enumerate all globals
	about: Returns a list of all globals in type hierarchy
	End Rem
	Method EnumGlobals:TList( list:TList=Null )
		If Not list list=New TList
		If _super _super.EnumGlobals list
		For Local t:TGlobal=EachIn _globalsList '.Values()
			list.AddLast t
		Next
		Return list
	End Method

	Rem
	bbdoc: Enumerate all functions
	about: Returns a list of all functions in type hierarchy
	End Rem
	Method EnumFunctions:TList( list:TList=Null )
		Function compareFunction:Int( a:Object, b:Object)
			If TFunction(a) And TFunction(b) Then
				Return TFunction(a).Name().Compare(TFunction(b).Name())
			End If
		EndFunction

		If Not list list=New TList
		If _super And _super <> Self Then _super.EnumFunctions list
		For Local t:TFunction=EachIn _functionsList '.Values()
			list.AddLast t
		Next

		' remove overridden functions
		list.Sort( True, compareFunction)
		Local prev:TFunction
		For Local t:TFunction = EachIn list
			If prev Then
				If (t.Name().Compare(prev.Name())) = 0 Then list.Remove(prev)
			EndIf
			prev = t
		Next

		Return list
	End Method

	Rem
	bbdoc: Enumerate all methods
	about: Returns a list of all methods in type hierarchy - TO DO: handle overrides!
	End Rem
	Method EnumMethods:TList( list:TList=Null )
		If Not list list=New TList
		If _super _super.EnumMethods list
		For Local t:TMethod=EachIn _methodsList '.Values()
			list.AddLast t
		Next
		Return list
	End Method

	Rem
	bbdoc: Create a new array
	End Rem
	Method NewArray:Object( length, dims:Int[] = Null )
		If Not _elementType Throw "TypeID is not an array type"
		Local tag:Byte Ptr=_elementType._typeTag
		If Not tag
			tag=TypeTagForId( _elementType ).ToCString()
			_elementType._typeTag=tag
		EndIf
		If Not dims Then
			Return bbArrayNew1D( tag,length )
		Else
			Return bbRefArrayCreate( tag, dims )
		End If
	End Method

	Rem
	bbdoc: Get array length
	End Rem
	Method ArrayLength( _array:Object, dim:Int = 0 )
		If Not _elementType Throw "TypeID is not an array type"
		Return bbRefArrayLength( _array, dim )
	End Method

	Method NullArray:Object()
		Return bbRefArrayNull()
	End Method
	
	Rem
	bbdoc: Get the number of dimensions
	End Rem
	Method ArrayDimensions:Int( _array:Object )
		If Not _elementType Throw "TypeID is not an array type"
		Return bbRefArrayDimensions( _array )
	End Method
	
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
	bbdoc: Gets an array element
	End Rem
	Method GetArrayElement:Object( _array:Object,index )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Return _Get( p,_elementType )
	End Method

	Rem
	bbdoc: Gets an array element as a #String
	End Rem
	Method GetStringArrayElement:String( _array:Object,index )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Return String(_Get( p,_elementType ))
	End Method

	Rem
	bbdoc: Gets an array element as a #Byte
	End Rem
	Method GetByteArrayElement:Byte( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #Short
	End Rem
	Method GetShortArrayElement:Short( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as an #Int
	End Rem
	Method GetIntArrayElement:Int( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #UInt
	End Rem
	Method GetUIntArrayElement:UInt( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #Long
	End Rem
	Method GetLongArrayElement:Long( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #ULong
	End Rem
	Method GetULongArrayElement:ULong( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #Size_T
	End Rem
	Method GetSizeTArrayElement:Size_T( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #Float
	End Rem
	Method GetFloatArrayElement:Float( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Gets an array element as a #Double
	End Rem
	Method GetDoubleArrayElement:Double( _array:Object,index )
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
		End Select
	End Method

	Rem
	bbdoc: Sets an array element
	End Rem
	Method SetArrayElement( _array:Object,index,value:Object )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		_Assign p,_elementType,value
	End Method

	Rem
	bbdoc: Sets an array element as a #Byte
	End Rem
	Method SetArrayElement( _array:Object,index,value:Byte )
		SetByteArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Short
	End Rem
	Method SetArrayElement( _array:Object,index,value:Short )
		SetShortArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as an #Int
	End Rem
	Method SetArrayElement( _array:Object,index,value:Int )
		SetIntArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #UInt
	End Rem
	Method SetArrayElement( _array:Object,index,value:UInt )
		SetUIntArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Long
	End Rem
	Method SetArrayElement( _array:Object,index,value:Long )
		SetLongArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #ULong
	End Rem
	Method SetArrayElement( _array:Object,index,value:ULong )
		SetULongArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Size_T
	End Rem
	Method SetArrayElement( _array:Object,index,value:Size_T )
		SetSizeTArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Float
	End Rem
	Method SetArrayElement( _array:Object,index,value:Float )
		SetFloatArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Double
	End Rem
	Method SetArrayElement( _array:Object,index,value:Double )
		SetDoubleArrayElement(_array, index, value)
	End Method

	Rem
	bbdoc: Sets an array element as a #Byte
	End Rem
	Method SetByteArrayElement( _array:Object,index,value:Byte )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Short
	End Rem
	Method SetShortArrayElement( _array:Object,index,value:Short )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Int
	End Rem
	Method SetIntArrayElement( _array:Object,index,value:Int )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromInt(value)
		End Select
	End Method
	
	Rem
	bbdoc: Sets an array element as a #UInt
	End Rem
	Method SetUIntArrayElement( _array:Object,index,value:UInt )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromUInt(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Long
	End Rem
	Method SetLongArrayElement( _array:Object,index,value:Long )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromLong(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #ULong
	End Rem
	Method SetULongArrayElement( _array:Object,index,value:ULong )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromULong(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Size_T
	End Rem
	Method SetSizeTArrayElement( _array:Object,index,value:Size_T )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromSizeT(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Float
	End Rem
	Method SetFloatArrayElement( _array:Object,index,value:Float )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromFloat(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element as a #Double
	End Rem
	Method SetDoubleArrayElement( _array:Object,index,value:Double )
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
			Case StringTypeId
				bbRefAssignObject p,String.FromDouble(value)
		End Select
	End Method

	Rem
	bbdoc: Sets an array element
	End Rem
	Method SetStringArrayElement( _array:Object,index,value:String )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		_Assign p,_elementType,value
	End Method

	Rem
	bbdoc: Get Type by name
	End Rem
	Function ForName:TTypeId( name$ )
		Try
			_guard.Lock()
			
			_Update
			If name.EndsWith( "]" )
				' TODO
				name=name[..name.length-2]
				Local nameType:TTypeID = TTypeId( _nameMap.ValueForKey( name.ToLower() ) )
				If Not nameType Then Return Null
				Return nameType.ArrayType()
			' pointers
			ElseIf name.EndsWith( "Ptr" )
				name=name[..name.length-4].Trim()
				If Not name Then Return Null
				Local baseType:TTypeId = ForName( name )
				If baseType Then
					' check for valid pointer base types
					Select baseType
						Case ByteTypeId, ShortTypeId, IntTypeId, LongTypeId, FloatTypeId, DoubleTypeId
							Return baseType.PointerType()
						Default
							If baseType.ExtendsType(PointerTypeId) Then Return baseType.PointerType()
					EndSelect
				EndIf
				Return Null
			' function pointers
			ElseIf name.EndsWith( ")" )
				' check if its in the table already
				Local t:TTypeId = TTypeId( _nameMap.ValueForKey( name.ToLower() ) )
				If t Then Return t
				Local i:Int = name.Find("(")
				Local ret:TTypeId = ForName( name[..i].Trim())
				Local typs:TTypeId[]
				If ret Then
					Local params:String = name[i+1..name.Length-1].Trim()
					If params Then
						Local args:String[] = params.Split(",")
						If args.Length >= 1 And args[0] Then
							typs = New TTypeId[args.Length]
							For Local i:Int = 0 Until args.Length
								typs[i] = ForName(args[i].Trim())
								If Not typs[i] Then typs[i] = ObjectTypeId
							Next
						EndIf
					EndIf
					'ret._functionType = Null
					Return ret.FunctionType(typs)
				EndIf
			Else
				Return TTypeId( _nameMap.ValueForKey( name.ToLower() ) )
			EndIf

		Finally
			_guard.Unlock()
		End Try
	End Function

	Rem
	bbdoc: Get Type by object
	End Rem
	Function ForObject:TTypeId( obj:Object )
		Try
			_guard.Lock()

			_Update
			Local class:Byte Ptr=bbRefGetObjectClass( obj )
			If class=ArrayTypeId._class
				If Not bbRefArrayLength( obj ) Return ArrayTypeId
				Return TypeIdForTag( bbRefArrayTypeTag( obj ) ).ArrayType()
			Else
				Return TTypeId( _classMap.ValueForKey( class ) )
			EndIf

		Finally
			_guard.Unlock()
		End Try
	End Function

	Rem
	bbdoc: Get list of all types
	End Rem
	Function EnumTypes:TList()
		Try
			_guard.Lock()

			_Update
			Local list:TList=New TList
			For Local t:TTypeId=EachIn _nameMap.Values()
				list.AddLast t
			Next
			Return list

		Finally
			_guard.Unlock()
		End Try
	End Function

	Rem
	bbdoc: Gets a list of all interfaces
	End Rem
	Function EnumInterfaces:TList()
		_Update
		Local list:TList=New TList
		For Local t:TTypeId=EachIn _interfaceMap.Values()
			list.AddLast t
		Next
		Return list
	End Function

	'***** PRIVATE *****

	Method Init:TTypeId( name$,size,class:Byte Ptr=Null,supor:TTypeId=Null )
		_name=name
		_size=size
		_class=class
		_super=supor
		_consts=New TStringMap
		_fields=New TStringMap
		_globals=New TStringMap
		_functions=New TStringMap
		_methods=New TStringMap
		_constsList=New TList
		_fieldsList=New TList
		_globalsList=New TList
		_functionsList=New TList
		_methodsList=New TList

		_nameMap.Insert _name.ToLower(),Self
		If class _classMap.Insert class,Self
		Return Self
	End Method
	
	Method InitMeta(meta:String)
		_meta = meta
		_metaMap = ExtractMetaMap(meta)
	End Method

	Method SetClass:TTypeId( class:Byte Ptr )
		Local name$=String.FromCString( bbRefClassDebugScopeName(class) )
		Local meta$
		Local i=name.Find( "{" )
		If i<>-1
			meta=name[i+1..name.length-1]
			name=name[..i]
		EndIf
		_name=name
		InitMeta(meta)
		_class=class
		_nameMap.Insert _name.ToLower(),Self
		_classMap.Insert class,Self
		Return Self
	End Method

	Method SetInterface:TTypeId( ifc:Byte Ptr )
		Local name:String = String.FromCString(bbInterfaceName(ifc))
		Local meta$
		Local i=name.Find( "{" )
		If i<>-1
			meta=name[i+1..name.length-1]
			name=name[..i]
		EndIf
		_name=name
		InitMeta(meta)
		_interface=ifc
		_class=bbInterfaceClass(ifc)
		_nameMap.Insert _name.ToLower(),Self
		_interfaceMap.Insert ifc,Self
		Return Self
	End Method

	Function _Update()
		Local count:Int
?Not ptr64
		Local p:Int Ptr Ptr=bbObjectRegisteredTypes( count )
?ptr64
		Local p:Long Ptr Ptr=bbObjectRegisteredTypes( count )
?
		If count=_count Return
		Local list:TList=New TList
		For Local i=_count Until count
			Local ty:TTypeId=New TTypeId.SetClass( p[i] )
			list.AddLast ty
		Next
		_count=count
		_UpdateInterfaces()
		For Local t:TTypeId=EachIn list
			t._Resolve
		Next
	End Function

	Function _UpdateInterfaces()
		Local count:Int
?Not ptr64
		Local p:Int Ptr Ptr=bbObjectRegisteredInterfaces( count )
?ptr64
		Local p:Long Ptr Ptr=bbObjectRegisteredInterfaces( count )
?
		If count=_icount Return
		Local list:TList=New TList
		For Local i=_icount Until count
			Local ty:TTypeId=New TTypeId.SetInterface( p[i] )
			list.AddLast ty
		Next
		_icount=count
		For Local t:TTypeId=EachIn list
			t._Resolve
		Next
	End Function

	Method _Resolve()
		If _fields Or Not _class Return
		_consts=New TStringMap
		_fields=New TStringMap
		_globals=New TStringMap
		_functions=New TStringMap
		_methods=New TStringMap
		_constsList=New TList
		_fieldsList=New TList
		_globalsList=New TList
		_functionsList=New TList
		_methodsList=New TList
		_interfaces=New TList

		If Not _interface Then
			_super=TTypeId( _classMap.ValueForKey(bbRefClassSuper(_class)))
		End If
		If Not _super _super=ObjectTypeId
		If Not _super._derived _super._derived=New TList
		_super._derived.AddLast Self

		Local p:Byte Ptr = bbRefClassDebugDecl(_class)

		While bbDebugDeclKind(p)
			Local id$=String.FromCString( bbDebugDeclName(p) )
			Local ty$=String.FromCString( bbDebugDeclType(p) )
			Local meta$
			Local i=ty.Find( "{" )
			If i<>-1
				meta=ty[i+1..ty.length-1]
				ty=ty[..i]
			EndIf

			Select bbDebugDeclKind(p)
			Case 1	'const
				Local tt:TTypeId = TypeIdFortag(ty)
				If tt Then
					Local t:TConstant = New TConstant.Init( id, tt, meta, bbDebugDeclConstValue(p))
					_constsList.AddLast(t)
					_consts.Insert(t.NameLower(), t)
				EndIf
			Case 3	'field
				Local typeId:TTypeId=TypeIdForTag( ty )
				If typeId Then
					Local t:TField = New TField.Init( id,typeId,meta,bbDebugDeclFieldOffset(p) )
					_fieldsList.AddLast(t)
					_fields.Insert(t.NameLower(), t)
				End If
			Case 4	'global
				Local typeId:TTypeId=TypeIdForTag( ty )
				If typeId Then
					Local t:TGlobal = New TGlobal.Init( id,typeId,meta, bbDebugDeclVarAddress(p) )
					_globalsList.AddLast(t)
					_globals.Insert(t.NameLower(), t)
				End If
			Case 6, 7	'method/function
				Local t$[]=ty.Split( ")" )
				Local retType:TTypeId=TypeIdForTag( t[1] )
				If retType
					Local argTypes:TTypeId[]
					If t[0].length>1
						Local i,b,q$=t[0][1..],args:TList=New TList
						While i<q.length
							Select q[i]
							Case Asc( "," )
								args.AddLast q[b..i]
								i:+1
								b=i
							Case Asc( "[" )
								i:+1
								While i<q.length And q[i]=Asc(",")
									i:+1
								Wend
							Default
								i:+1
							End Select
						Wend
						If b<q.length args.AddLast q[b..q.length]

						argTypes=New TTypeId[args.Count()]

						i=0
						For Local arg$=EachIn args
							argTypes[i]=TypeIdForTag( arg )
							If Not argTypes[i] retType=Null
							i:+1
						Next
					EndIf
					If retType
						If bbDebugDeclKind(p) = 6 Then ' method
							Local t:TMethod = New TMethod.Init(id, TypeIdForTag(ty), meta, Self, bbDebugDeclVarAddress(p), argTypes)
							_methodsList.AddLast(t)
							_methods.Insert(t.NameLower(), t)
						Else ' function
							Local t:TFunction = New TFunction.Init(id, TypeIdForTag(ty), meta, Self, bbDebugDeclVarAddress(p), argTypes)
							_functionsList.AddLast(t)
							_functions.Insert(t.NameLower(), t)
						End If
					EndIf
				EndIf
			End Select
			p = bbDebugDeclNext(p)
		Wend
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
	End Method

	Field _name$
	Field _meta$
	Field _metaMap:TStringMap
	Field _class:Byte Ptr
	Field _interface:Byte Ptr
' default object size
?Not ptr64
	Field _size=4
?ptr64
	Field _size=8
?
	Field _consts:TStringMap
	Field _fields:TStringMap
	Field _globals:TStringMap
	Field _functions:TStringMap
	Field _methods:TStringMap
	Field _constsList:TList
	Field _fieldsList:TList
	Field _globalsList:TList
	Field _functionsList:TList
	Field _methodsList:TList
	Field _interfaces:TList
	Field _super:TTypeId
	Field _derived:TList
	Field _arrayType:TTypeId[]
	Field _elementType:TTypeId
	Field _typeTag:Byte Ptr

	Field _pointerType:TTypeId

	Field _functionType:TStringMap
	Field _argTypes:TTypeId[]
	Field _retType:TTypeId

	Global _count,_nameMap:TMap=New TMap,_classMap:TPtrMap=New TPtrMap
	Global _icount:Int, _interfaceMap:TPtrMap=New TPtrMap

End Type
