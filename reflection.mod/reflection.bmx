
Strict

Rem
bbdoc: BASIC/Reflection
End Rem
Module BRL.Reflection

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.03"
ModuleInfo "History: Added grable enhancements."
ModuleInfo "History: Added support for globals."
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added Brucey's size fix to GetArrayElement()/SetArrayElement()."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Fixed NewArray using temp type name"

Import BRL.LinkedList
Import BRL.Map

Import "reflection.cpp"

Private

Extern

Function bbObjectNew:Object( class:Byte Ptr )
?Not x64
Function bbObjectRegisteredTypes:Int Ptr( count Var )
?x64
Function bbObjectRegisteredTypes:Long Ptr( count Var )
?

Function bbArrayNew1D:Object( typeTag:Byte Ptr,length )


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

End Extern

Type TClass

	Method Compare( with:Object )
		Return _class-TClass( with )._class
	End Method
	
	Method SetClass:TClass( class:Byte Ptr )
		_class=class
		Return Self
	End Method
	
	Field _class:Byte Ptr
End Type

Function _Get:Object( p:Byte Ptr,typeId:TTypeId )
	Select typeId
	Case ByteTypeId
		Return String.FromInt( (Byte Ptr p)[0] )
	Case ShortTypeId
		Return String.FromInt( (Short Ptr p)[0] )
	Case IntTypeId
		Return String.FromInt( (Int Ptr p)[0] )
	Case LongTypeId
		Return String.FromLong( (Long Ptr p)[0] )
	Case FloatTypeId
		Return String.FromFloat( (Float Ptr p)[0] )
	Case DoubleTypeId
		Return String.FromDouble( (Double Ptr p)[0] )
	Default
		If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not x64
			Return String.FromInt( (Int Ptr p)[0] )
?x64
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
	Case LongTypeId
		(Long Ptr sp)[0]=value.ToString().ToLong()
		Return sp+8
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
?Not x64
				(Int Ptr sp)[0]=value.ToString().ToInt()
				Return sp+4
?x64
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
	Case LongTypeId
		(Long Ptr p)[0]=value.ToString().ToLong()
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
?Not x64
				(Int Ptr p)[0]=value.ToString().ToInt()
?x64
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
		EndIf
		bbRefAssignObject p,value
	End Select
End Function

Function _CallFunction:Object( p:Byte Ptr,typeId:TTypeId,args:Object[],argTypes:TTypeId[] )
	Local q:Byte Ptr[10]
	For Local i=0 Until args.length
		_Push( Varptr q[i],argTypes[i],args[i] )
	Next

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
?Not x64
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
?x64
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
	For Local i=0 Until args.length
		'If Int Ptr(sp)>=Int Ptr(q)+8 Throw "ERROR"
		_Push( Varptr q[i],argTypes[i],args[i] )
	Next
	'If Int Ptr(sp)>Int Ptr(q)+8 Throw "ERROR"
	Select typeId
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
		If typeid.ExtendsType(PointerTypeId) Or typeid.ExtendsType(FunctionTypeId) Then
?Not x64
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
?x64
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
	Case LongTypeId Return "l"
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

Function TypeIdForTag:TTypeId( ty$ )
	If ty.StartsWith( "[" )
		Local dims:Int = ty.split(",").length
		ty=ty[ty.Find("]")+1..]
		Local id:TTypeId = TypeIdForTag( ty )
		If id Then
			id._arrayType = Null
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
			id._pointerType = Null
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
		retType._functionType = Null
		Return retType.FunctionType(argTypes)
	EndIf
	Select ty
	Case "b" Return ByteTypeId
	Case "s" Return ShortTypeId
	Case "i" Return IntTypeId
	Case "l" Return LongTypeId
	Case "f" Return FloatTypeId
	Case "d" Return DoubleTypeId
	Case "$" Return StringTypeId
	Case "*" Return PointerTypeId
	Case "(" Return FunctionTypeId
	Case "" Return VoidTypeId
	End Select
End Function

Function ExtractMetaData$( meta$,key$ )
	If Not key Return meta
	Local i=0
	While i<meta.length
		Local e=meta.Find( "=",i )
		If e=-1 Throw "Malformed meta data"
		Local k$=meta[i..e],v$
		i=e+1
		If i<meta.length And meta[i]=Asc("~q")
			i:+1
			Local e=meta.Find( "~q",i )
			If e=-1 Throw "Malformed meta data"
			v=meta[i..e]
			i=e+1
		Else
			Local e=meta.Find( " ",i )
			If e=-1 e=meta.length
			v=meta[i..e]
			i=e
		EndIf
		If k=key Return v
		If i<meta.length And meta[i]=Asc(" ") i:+1
	Wend
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
bbdoc: Primitive long type
End Rem
Global LongTypeId:TTypeId=New TTypeId.Init( "Long",8 )

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
?Not x64
Global ObjectTypeId:TTypeId=New TTypeId.Init( "Object",4,bbRefObjectClass() )
?x64
Global ObjectTypeId:TTypeId=New TTypeId.Init( "Object",8,bbRefObjectClass() )
?

Rem
bbdoc: Primitive string type
End Rem
?Not x64
Global StringTypeId:TTypeId=New TTypeId.Init( "String",4,bbRefStringClass(),ObjectTypeId )
?x64
Global StringTypeId:TTypeId=New TTypeId.Init( "String",8,bbRefStringClass(),ObjectTypeId )
?

Rem
bbdoc: Primitive array type
End Rem
?Not x64
Global ArrayTypeId:TTypeId=New TTypeId.Init( "Null[]",4,bbRefArrayClass(),ObjectTypeId )
?x64
Global ArrayTypeId:TTypeId=New TTypeId.Init( "Null[]",8,bbRefArrayClass(),ObjectTypeId )
?

' Void Type
' Only used For Function/Method Return types
Global VoidTypeId:TTypeId=New TTypeId.Init( "Void",0 )

Rem
bbdoc: Primitive pointer type
End Rem
?Not x64
Global PointerTypeId:TTypeId=New TTypeId.Init( "Ptr",4 )
?x64
Global PointerTypeId:TTypeId=New TTypeId.Init( "Ptr",8 )
?

Rem
bbdoc: Primitive function type
End Rem
?Not x64
Global FunctionTypeId:TTypeId=New TTypeId.Init( "Null()",4 )
?x64
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
		Return ExtractMetaData( _meta,key )
	End Method
	
	Field _name$,_typeId:TTypeId,_meta$
	
End Type

Rem
bbdoc: Type constant
EndRem
Type TConstant Extends TMember

?Not x64
	Method Init:TConstant( name:String, typeId:TTypeId, meta:String, stringRef:Int Ptr)
?x64
	Method Init:TConstant( name:String, typeId:TTypeId, meta:String, stringRef:Long Ptr)
?
		_name = name
		_typeId = typeId
		_meta = meta
		_stringRef = stringRef
		Return Self
	EndMethod

	Rem
	bbdoc: Get constant value
	EndRem
	Method GetString:String()
		Return bbStringFromRef(_stringRef)
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
	bbdoc: Get constant value as @Double
	EndRem	
	Method GetDouble:Int()
		Return GetString().ToDouble()
	EndMethod

	Rem
	bbdoc: Get constant value as @{Byte Ptr}
	EndRem
	Method GetPointer:Byte Ptr()
		Return Byte Ptr GetString().ToInt()
	EndMethod

?Not x64
	Field _stringRef:Int Ptr
?x64
	Field _stringRef:Long Ptr
?

EndType

Rem
bbdoc: Type field
End Rem
Type TField Extends TMember

	Method Init:TField( name$,typeId:TTypeId,meta$,index )
		_name=name
		_typeId=typeId
		_meta=meta
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
	bbdoc: Get int field value
	End Rem
	Method GetInt:Int( obj:Object )
		Return GetString( obj ).ToInt()
	End Method
	
	Rem
	bbdoc: Get long field value
	End Rem
	Method GetLong:Long( obj:Object )
		Return GetString( obj ).ToLong()
	End Method
	
	Rem
	bbdoc: Get float field value
	End Rem
	Method GetFloat:Float( obj:Object )
		Return GetString( obj ).ToFloat()
	End Method
	
	Rem
	bbdoc: Get double field value
	End Rem
	Method GetDouble:Double( obj:Object )
		Return GetString( obj ).ToDouble()
	End Method
	
	Rem
	bbdoc: Get string field value
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
	bbdoc: Set int field value
	End Rem
	Method SetInt( obj:Object,value:Int )
		SetString obj,String.FromInt( value )
	End Method
	
	Rem
	bbdoc: Set long field value
	End Rem
	Method SetLong( obj:Object,value:Long )
		SetString obj,String.FromLong( value )
	End Method
	
	Rem
	bbdoc: Set float field value
	End Rem
	Method SetFloat( obj:Object,value:Float )
		SetString obj,String.FromFloat( value )
	End Method
	
	Rem
	bbdoc: Set double field value
	End Rem
	Method SetDouble( obj:Object,value:Double )
		SetString obj,String.FromDouble( value )
	End Method
	
	Rem
	bbdoc: Set string field value
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
		_meta=meta
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
		_meta=meta
		_selfTypeId=selfTypeId		
		_ref=ref
		_argTypes=argTypes
'		If _index >= 65536 Then
'			_fptr = Byte Ptr(_index)
'		Else
'			_fptr = Null
'		EndIf
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
		_meta=meta
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

	Rem
	bbdoc: Invoke method
	End Rem
	Method Invoke:Object( obj:Object,args:Object[] )
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
		Return ExtractMetaData( _meta,key )
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
		If Not _arrayType
			Local dim:String
			If dims > 1 Then
				For Local i:Int = 1 Until dims
					dim :+ ","
				Next
			End If
?Not x64
			_arrayType=New TTypeId.Init( _name+"[" + dim + "]",4,bbRefArrayClass() )
?x64
			_arrayType=New TTypeId.Init( _name+"[" + dim + "]",8,bbRefArrayClass() )
?
			_arrayType._elementType=Self
			If _super
				_arrayType._super=_super.ArrayType()
			Else
				_arrayType._super=ArrayTypeId
			EndIf
		EndIf
		Return _arrayType
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
		If Not _pointerType Then
?Not x64
			_pointerType = New TTypeId.Init( _name + " Ptr", 4)
?x64
			_pointerType = New TTypeId.Init( _name + " Ptr", 8)
?
			_pointerType._elementType = Self
			If _super Then
				_pointerType._super = _super.PointerType()
			Else
				_pointerType._super = PointerTypeId
			EndIf
		EndIf
		Return _pointerType
	End Method

	Rem
	bbdoc: Get function pointer type
	End Rem
	Method FunctionType:TTypeId( args:TTypeId[]=Null)
		If Not _functionType Then
			Local s:String
			For Local t:TTypeId = EachIn args
				If s Then s :+ ","
				s :+ t.Name()
			Next
?Not x64
			_functionType = New TTypeId.Init( _name + "(" + s + ")", 4)
?x64
			_functionType = New TTypeId.Init( _name + "(" + s + ")", 8)
?
			_functionType._retType = Self
			_functionType._argTypes = args
			If _super Then
				_functionType._super = _super.FunctionType()
			Else
				_functionType._super = FunctionTypeId
			EndIf
		EndIf
		Return _functionType
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
		Return bbObjectNew( _class )
	End Method
	
	Rem
	bbdoc: Get list of constants
	about: Only returns constants declared in this type, not in super types.
	End Rem
	Method Constants:TList()
		Return _consts
	End Method	
	
	Rem
	bbdoc: Get list of fields
	about: Only returns fields declared in this type, not in super types.
	End Rem
	Method Fields:TList()
		Return _fields
	End Method

	Rem
	bbdoc: Get list of globals
	about: Only returns globals declared in this type, not in super types.
	End Rem
	Method Globals:TList()
		Return _globals
	End Method

	Rem
	bbdoc: Get list of functions
	about: Only returns functions declared in this type, not in super types.
	EndRem
	Method Functions:TList()
		Return _functions
	End Method	
	
	Rem
	bbdoc: Get list of methods
	about: Only returns methods declared in this type, not in super types.
	End Rem
	Method Methods:TList()
		Return _methods
	End Method
	
	Rem
	bbdoc: Find a constant by name
	about: Searchs type hierarchy for constant called @name.
	End Rem
	Method FindConstant:TConstant( name$ )
		name=name.ToLower()
		For Local t:TConstant=EachIn _consts
			If t.Name().ToLower()=name Return t
		Next
		If _super Return _super.FindConstant( name )
	End Method	
	
	Rem
	bbdoc: Find a field by name
	about: Searchs type hierarchy for field called @name.
	End Rem
	Method FindField:TField( name$ )
		name=name.ToLower()
		For Local t:TField=EachIn _fields
			If t.Name().ToLower()=name Return t
		Next
		If _super Return _super.FindField( name )
	End Method

	Rem
	bbdoc: Find a global by name
	about: Searchs type hierarchy for global called @name.
	End Rem
	Method FindGlobal:TGlobal( name$ )
		name=name.ToLower()
		For Local t:TGlobal=EachIn _globals
			If t.Name().ToLower()=name Return t
		Next
		If _super Return _super.FindGlobal( name )
	End Method

	Rem
	bbdoc: Find a function by name
	about: Searches type heirarchy for function called @name
	endrem
	Method FindFunction:TFunction(name:String)
		name = name.ToLower()
		For Local t:TFunction = EachIn _functions
			If t.Name().ToLower() = name Return t
		Next
		If _super Return _super.FindFunction(name)
	End Method
	
	Rem
	bbdoc: Find a method by name
	about: Searchs type hierarchy for method called @name.
	End Rem
	Method FindMethod:TMethod( name$ )
		name=name.ToLower()
		For Local t:TMethod=EachIn _methods
			If t.Name().ToLower()=name Return t
		Next
		If _super Return _super.FindMethod( name )
	End Method

	Rem
	bbdoc: Enumerate all constants
	about: Returns a list of all constants in type hierarchy
	End Rem	
	Method EnumConstants:TList( list:TList=Null )
		If Not list list=New TList
		If _super _super.EnumConstants list
		For Local t:TConstant=EachIn _consts
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
		For Local t:TField=EachIn _fields
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
		For Local t:TField=EachIn _globals
			list.AddLast t
		Next
		Return list
	End Method

	Rem
	bbdoc: Enumerate all functions
	about: Returns a list of all functions in type hierarchy
	End Rem
	Method EnumFunctions:TList( list:TList=Null )
		Function compareFunction:Int( a:TFunction, b:TFunction)
			Return a.Name().Compare(b.Name())
		EndFunction

		If Not list list=New TList
		If _super And _super <> Self Then _super.EnumFunctions list
		For Local t:TFunction=EachIn _functions
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
		For Local t:TMethod=EachIn _methods
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
	
	Rem
	bbdoc: Get the number of dimensions
	End Rem
	Method ArrayDimensions:Int( _array:Object )
		If Not _elementType Throw "TypeID is not an array type"
		Return bbRefArrayDimensions( _array )
	End Method
	
	Rem
	bbdoc: Get an array element
	End Rem
	Method GetArrayElement:Object( _array:Object,index )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		Return _Get( p,_elementType )
	End Method
	
	Rem
	bbdoc: Set an array element
	End Rem
	Method SetArrayElement( _array:Object,index,value:Object )
		If Not _elementType Throw "TypeID is not an array type"
		Local p:Byte Ptr=bbRefArrayElementPtr( _elementType._size,_array,index )
		_Assign p,_elementType,value
	End Method
	
	Rem
	bbdoc: Get Type by name
	End Rem
	Function ForName:TTypeId( name$ )
		_Update
		If name.EndsWith( "]" )
			' TODO
			name=name[..name.length-2]
			Return TTypeId( _nameMap.ValueForKey( name.ToLower() ) ).ArrayType()
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
				ret._functionType = Null
				Return ret.FunctionType(typs)
			EndIf
		Else
			Return TTypeId( _nameMap.ValueForKey( name.ToLower() ) )
		EndIf
	End Function

	Rem
	bbdoc: Get Type by object
	End Rem	
	Function ForObject:TTypeId( obj:Object )
		_Update
		Local class:Byte Ptr=bbRefGetObjectClass( obj )
		If class=ArrayTypeId._class
			If Not bbRefArrayLength( obj ) Return ArrayTypeId
			Return TypeIdForTag( bbRefArrayTypeTag( obj ) ).ArrayType()
		Else
			Return TTypeId( _classMap.ValueForKey( New TClass.SetClass( class ) ) )
		EndIf
	End Function
	
	Rem
	bbdoc: Get list of all types
	End Rem
	Function EnumTypes:TList()
		_Update
		Local list:TList=New TList
		For Local t:TTypeId=EachIn _nameMap.Values()
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
		_consts=New TList
		_fields=New TList
		_globals=New TList
		_functions=New TList
		_methods=New TList
		_nameMap.Insert _name.ToLower(),Self
		If class _classMap.Insert New TClass.SetClass( class ),Self
		Return Self
	End Method
	
	Method SetClass:TTypeId( class:Byte Ptr )
?Not x64
		Local debug:Int=(Int Ptr class)[2]
		Local name$=String.FromCString( Byte Ptr( (Int Ptr debug)[1] ) )
?x64
		Local debug:Long=(Long Ptr class)[2]
		Local name$=String.FromCString( Byte Ptr( (Long Ptr debug)[1] ) )
?
		Local meta$
		Local i=name.Find( "{" )
		If i<>-1
			meta=name[i+1..name.length-1]
			name=name[..i]
		EndIf
		_name=name
		_meta=meta
		_class=class
		_nameMap.Insert _name.ToLower(),Self
		_classMap.Insert New TClass.SetClass( class ),Self
		Return Self
	End Method
	
	Function _Update()
		Local count:Int
?Not x64
		Local p:Int Ptr Ptr=bbObjectRegisteredTypes( count )
?x64
		Local p:Long Ptr Ptr=bbObjectRegisteredTypes( count )
?
		If count=_count Return
		Local list:TList=New TList
		For Local i=_count Until count
			Local ty:TTypeId=New TTypeId.SetClass( p[i] )
			list.AddLast ty
		Next
		_count=count
		For Local t:TTypeId=EachIn list
			t._Resolve
		Next
	End Function
	
	Method _Resolve()
		If _fields Or Not _class Return
		_consts=New TList
		_fields=New TList
		_globals=New TList
		_functions=New TList
		_methods=New TList
?Not x64
		_super=TTypeId( _classMap.ValueForKey( New TClass.SetClass( (Int Ptr _class)[0] ) ) )
?x64
		_super=TTypeId( _classMap.ValueForKey( New TClass.SetClass( (Long Ptr _class)[0] ) ) )
?
		If Not _super _super=ObjectTypeId
		If Not _super._derived _super._derived=New TList
		_super._derived.AddLast Self
		
?Not x64
		Local debug:Int Ptr=(Int Ptr Ptr _class)[2]
		Local p:Int Ptr=debug+2
?x64
		Local debug:Long Ptr=(Long Ptr Ptr _class)[2]
		Local p:Long Ptr=debug+2
?
		While p[0]
			Local id$=String.FromCString( Byte Ptr p[1] )
			Local ty$=String.FromCString( Byte Ptr p[2] )
			Local meta$
			Local i=ty.Find( "{" )
			If i<>-1
				meta=ty[i+1..ty.length-1]
				ty=ty[..i]
			EndIf

			Select p[0]
			Case 1	'const
				Local tt:TTypeId = TypeIdFortag(ty)
				If tt Then
?Not x64
					_consts.AddLast New TConstant.Init( id, tt, meta, Int Ptr(p[3]))
?x64
					_consts.AddLast New TConstant.Init( id, tt, meta, Long Ptr(p[3]))
?
				EndIf
			Case 3	'field
				Local typeId:TTypeId=TypeIdForTag( ty )
				If typeId _fields.AddLast New TField.Init( id,typeId,meta,p[3] )
			Case 4	'global
				Local typeId:TTypeId=TypeIdForTag( ty )
				If typeId _globals.AddLast New TGlobal.Init( id,typeId,meta,p[3] )
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
						If p[0] = 6 Then ' method
							_methods.AddLast New TMethod.Init(id, retType, meta, Self, Byte Ptr p[3], argTypes)
						Else ' function
							_functions.AddLast New TFunction.Init(id, retType, meta, Self, Byte Ptr p[3], argTypes)
						End If
					EndIf
				EndIf
			End Select
			p:+4
		Wend
	End Method
	
	Field _name$
	Field _meta$
	Field _class:Byte Ptr
	Field _size=4
	Field _consts:TList
	Field _fields:TList
	Field _globals:TList
	Field _functions:TList
	Field _methods:TList
	Field _super:TTypeId
	Field _derived:TList
	Field _arrayType:TTypeId
	Field _elementType:TTypeId
	Field _typeTag:Byte Ptr
	
	Field _pointerType:TTypeId
	
	Field _functionType:TTypeId
	Field _argTypes:TTypeId[]
	Field _retType:TTypeId
	
	Global _count,_nameMap:TMap=New TMap,_classMap:TMap=New TMap
	
End Type
