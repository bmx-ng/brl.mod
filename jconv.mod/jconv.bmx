' Copyright (c) 2019 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
'
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
'
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
'
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
'
'    3. This notice may not be removed or altered from any source
'    distribution.
'
SuperStrict

Rem
bbdoc: JSON Object serialiser.
End Rem
Module brl.jconv

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/png"
ModuleInfo "Copyright: 2019 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import brl.reflection
Import brl.json

Rem
bbdoc: Creates an instance of #TJConv with custom settings.
End Rem
Type TJConvBuilder

	Rem
	bbdoc: Builds the #TJConv instance.
	End Rem
	Method Build:TJConv()
		Return New TJConv
	End Method

End Type

Rem
bbdoc: Serialises or deserializes objects to and from JSON.
End Rem
Type TJConv

	Rem
	bbdoc: Deserializes the specified JSON string into an object of the specified type.
	returns: The deserialized object.
	End Rem
	Method FromJson:Object(json:String, typeName:String)
		Local typeId:TTypeId = TTypeId.ForName(typeName)
		
		Return FromJson(json, typeId, Null)
	End Method

	Rem
	bbdoc: Deserializes the specified JSON string into @obj.
	End Rem
	Method FromJson:Object(json:String, obj:Object)
		If Not obj Then
			Return Null
		End If
		
		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		Return FromJson(json, typeId, obj)
	End Method

	Method FromJson:Object(txt:String, typeId:TTypeId, obj:Object)
		Local error:TJSONError
		Local json:TJSON = TJSON.Load(txt, 0, error)

		Return FromJson(json, typeId, obj)
	End Method

	Method FromJson:Object(json:TJSON, typeId:TTypeId, obj:Object)
	
		If Not obj Then
			obj = typeId.NewObject()
		End If

		If TJSONObject(json) Then
			For Local j:TJSON = EachIn TJSONObject(json)
				Local f:TField = typeId.FindField(j.key)
				
				If f Then
					If TJSONInteger(j) Then
						Select f.TypeId()
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetLong(obj, TJSONInteger(j).Value())
						End Select
						Continue
					End If
					
					If TJSONReal(j) Then
						Select f.TypeId()
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetDouble(obj, TJSONReal(j).Value())
						End Select
						Continue
					End If
					
					If TJSONString(j) Then
						Select f.TypeId()
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetString(obj, TJSONString(j).Value())
						End Select
						Continue
					End If
					
					If TJSONObject(j) Then
						If f.TypeId().ExtendsType(ObjectTypeId) Then
							Local o:Object = FromJson(j, f.TypeId(), Null)
							If o Then
								f.Set(obj, o)
							End If
						End If
					End If
				End If
			Next
		End If
				
		Return obj
	End Method
	
	Rem
	bbdoc: Serializes the specified object into its equivalent JSON representation.
	returns: The JSON representation as a #String.
	End Rem
	Method ToJson:String(obj:Object)
		If Not obj Then
			Return Null
		End If
		
		Local json:TJSONObject = New TJSONObject.Create()
		
		ToJson(json, obj)
		
		Return json.SaveString()
	End Method
	
	Rem
	bbdoc: Serializes the specified object into its equivalent JSON representation and outputs to a #TStream.
	about: The stream should be open and writeable.
	End Rem
	Method ToJson(obj:Object, stream:TStream)
		If Not obj Then
			Return
		End If

		Local json:TJSONObject = New TJSONObject.Create()
		
		ToJson(json, obj)
		
		json.SaveStream(stream)
	End Method
	
	Method ToJson(json:TJSONObject, obj:Object)
		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		For Local f:TField = EachIn typeId.EnumFields()
			Local j:TJSON
			
			Select f.TypeId()
				Case ByteTypeId
					j = New TJSONInteger.Create(f.GetByte(obj))

				Case ShortTypeId
					j = New TJSONInteger.Create(f.GetShort(obj))

				Case IntTypeId
					j = New TJSONInteger.Create(f.GetInt(obj))

				Case UIntTypeId
					j = New TJSONInteger.Create(f.GetUInt(obj))

				Case LongTypeId
					j = New TJSONInteger.Create(f.GetLong(obj))

				Case ULongTypeId
					j = New TJSONInteger.Create(f.GetULong(obj))

				Case SizetTypeId
					j = New TJSONInteger.Create(f.GetSizeT(obj))
					
				Case FloatTypeId
					j = New TJSONReal.Create(f.GetFloat(obj))

				Case DoubleTypeId
					j = New TJSONReal.Create(f.GetDouble(obj))
					
				Case StringTypeId
					Local s:String = f.GetString(obj)
					If s Then
						json.Set(f.Name(), New TJSONString.Create(s))
					End If
					Continue
			End Select
			
			If f.TypeId().ExtendsType(ObjectTypeId) Then
				Local o:Object = f.Get(obj)
				If o Then
					j = New TJSONObject.Create()
					ToJson(TJSONObject(j), o)
				End If
			End If
			
			If j Then
				json.Set(f.Name(), j)
			End If
		
		Next
		
	End Method
	
End Type
