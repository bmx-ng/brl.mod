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
bbdoc: JSON Object de/serializer.
End Rem
Module brl.jconv

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/png"
ModuleInfo "Copyright: 2019 Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Added custom serializer."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added support for arrays."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import brl.reflection
Import brl.json
Import brl.map

Rem
bbdoc: Creates an instance of #TJConv with custom settings.
End Rem
Type TJConvBuilder

	Field options:TJConvOptions = New TJConvOptions

	Rem
	bbdoc: Builds the #TJConv instance.
	End Rem
	Method Build:TJConv()
		Local jconv:TJConv = New TJConv
		jconv.options = options
		
		For Local serializer:TJConvSerializer = EachIn options.serializers.Values()
			serializer.jconv = jconv
		Next
		
		Return jconv
	End Method

	Rem
	bbdoc: Null/Empty array fields will be output to JSON as `[]`.
	about: The default is not to output these fields.
	End Rem
	Method WithEmptyArrays:TJConvBuilder()
		options.emptyArraysAreNull = False
		Return Self
	End Method
	
	Rem
	bbdoc: Registers a serializer for the given source type.
	End Rem
	Method RegisterSerializer:TJConvBuilder(sourceType:String, serializer:Object)
		options.serializers.Insert(sourceType, serializer)
		Return Self
	End Method

	'Rem
	'bbdoc: 
	'End Rem
	'Method RegisterDeserializer:TJConvBuilder(sourceType:String, deserializer:Object)
	'	options.deserializers.Insert(sourceType, deserializer)
	'	Return Self
	'End Method
	
End Type

Rem
bbdoc: Serialises or deserializes objects to and from JSON.
End Rem
Type TJConv

	Field options:TJConvOptions = New TJConvOptions
	
	Field defaultSerializer:TJConvSerializer = New TJConvSerializer
	'Field defaultDeserializer:TJConvDeserializer = New TJConvDeserializer
	
	Method New()
		defaultSerializer.jconv = Self
		'defaultDeserializer.jconv = Self
	End Method

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

	Rem
	bbdoc: 
	End Rem
	Method FromJson:Object(stream:TStream, typeName:String)
		Local typeId:TTypeId = TTypeId.ForName(typeName)
		
		Return FromJson(stream, typeId, Null)
	End Method
	
	Method FromJson:Object(stream:TStream, typeId:TTypeId, obj:Object)
		Local error:TJSONError
		Local json:TJSON = TJSON.Load(stream, 0, error)

		Return FromJson(json, typeId, obj)
	End Method

	Method FromJson:Object(json:TJSON, typeId:TTypeId, obj:Object)
	
		If TJSONObject(json) Then
			If Not obj Then
				obj = typeId.NewObject()
			End If

			For Local j:TJSON = EachIn TJSONObject(json)
				Local f:TField = typeId.FindField(j.key)

				If f Then
					Local fieldType:TTypeId = f.TypeId()

					If TJSONInteger(j) Then
						Select fieldType
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetLong(obj, TJSONInteger(j).Value())
						End Select
						Continue
					End If
					
					If TJSONReal(j) Then
						Select fieldType
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetDouble(obj, TJSONReal(j).Value())
						End Select
						Continue
					End If
					
					If TJSONString(j) Then
						Select fieldType
							Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
								f.SetString(obj, TJSONString(j).Value())
						End Select
						Continue
					End If
					
					If TJSONArray(j) Then

						If fieldType.ExtendsType(ArrayTypeId) Then

							Local elementType:TTypeId = fieldType.ElementType()

							Local arrayObj:Object = ProcessArray(TJSONArray(j), fieldType, Null)
							
							f.Set(obj, arrayObj)
						End If
						Continue
					End If
					
					If TJSONObject(j) Then
					
						If typeId.ExtendsType(ObjectTypeId) Then
							
							Local o:Object = FromJson(j, fieldType, Null)
							If o Then
								f.Set(obj, o)
							End If
						End If
					End If
				End If
			Next
		Else If TJSONArray(json) Then
			
			obj = ProcessArray(TJSONArray(json), typeId, obj)
		
		End If
				
		Return obj
	End Method

	Method ProcessArray:Object(jsonArray:TJSONArray, typeId:TTypeId, arrayObj:Object)

		Local size:Int = jsonArray.Size()

		If Not size Then
			Return typeId.NullArray()
		End If

		Local elementType:TTypeId = typeId.ElementType()

		' arrayObj is Null Array?
		' We need to read the first jsonarray element and create a new array of that type
		If Not elementType And size Then
			
			Local jsonElement:TJSON = jsonArray.Get(0)
			
			If TJSONInteger(jsonElement) Then
				typeId = TypeIdForTag("[]l")
			Else If TJSONReal(jsonElement) Then
				typeId = TypeIdForTag("[]d")
			Else If TJSONString(jsonElement) Then
				typeId = TypeIdForTag("[]$")
			Else If TJSONObject(jsonElement) Then
				typeId = TypeIdForTag("[]:Object")
			End If

			elementType = typeId.ElementType()
			If Not elementType Then
				Return Null
			End If
		End If

		If Not arrayObj Then
			arrayObj = typeId.NewArray(size)
		Else
			arrayObj = typeId.ArraySlice(arrayObj, 0, size)
		End If

		For Local i:Int = 0 Until size
			Local jsonElement:TJSON = jsonArray.Get(i)
			
			If TJSONInteger(jsonElement) Then
				Select elementType
					Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
						typeId.SetLongArrayElement(arrayObj, i, TJSONInteger(jsonElement).Value())
				End Select
				Continue
			End If

			If TJSONReal(jsonElement) Then
				Select elementType
					Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
						typeId.SetDoubleArrayElement(arrayObj, i, TJSONReal(jsonElement).Value())
				End Select
				Continue
			End If
			
			If TJSONString(jsonElement) Then
				Select elementType
					Case ByteTypeId,ShortTypeId,IntTypeId,UIntTypeId,LongTypeId,ULongTypeId,SizetTypeId,FloatTypeId,DoubleTypeId,StringTypeId
						typeId.SetStringArrayElement(arrayObj, i, TJSONString(jsonElement).Value())
				End Select
				Continue
			End If
			
			If TJSONObject(jsonElement) Then
				If elementType.ExtendsType(ObjectTypeId) Then
					Local o:Object = FromJson(jsonElement, elementType, Null)
					typeId.SetArrayElement(arrayObj, i, o)
				End If
			End If						
		Next
		
		Return arrayObj
	End Method
	
	Rem
	bbdoc: Serializes the specified object into its equivalent JSON representation.
	returns: The JSON representation as a #String.
	End Rem
	Method ToJson:String(obj:Object)
		If Not obj Then
			If IsEmptyArray(obj) Then
				Return "[]"
			End If
			
			Return "{}"
		End If
		
		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		If typeId.ExtendsType(ArrayTypeId) Then
			Local json:TJSONArray = New TJSONArray.Create()
		
			ToJson(json, obj)
			
			Return json.SaveString()
		End If
		
		If typeId.ExtendsType(ObjectTypeId) Then

			Local serializer:TJConvSerializer = TJConvSerializer(options.serializers.ValueForKey(typeId.Name()))
			If Not serializer Then
				serializer = defaultSerializer
			End If

			Local json:TJSON = serializer.Serialize(obj, typeId.Name())

			Return json.SaveString()
		End If
	End Method
	
	Rem
	bbdoc: Serializes the specified object into its equivalent JSON representation and outputs to a #TStream.
	about: The stream should be open and writeable.
	End Rem
	Method ToJson(obj:Object, stream:TStream)
		If Not obj Then
			If IsEmptyArray(obj) Then
				Local json:TJSONArray = New TJSONArray.Create()
				json.SaveStream(stream)
				Return
			End If
			
			Local json:TJSONObject = New TJSONObject.Create()
			json.SaveStream(stream)
			Return
		End If

		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		If typeId.ExtendsType(ArrayTypeId) Then
			Local json:TJSONArray = New TJSONArray.Create()
		
			ToJson(json, obj)
			
			json.SaveStream(stream)
			Return
		Else If typeId.ExtendsType(ObjectTypeId) Then

			Local json:TJSONObject = New TJSONObject.Create()

			ToJson(json, obj)
		
			json.SaveStream(stream)
		End If

	End Method
	
	Method ToJson(json:TJSONObject, obj:Object)
		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		For Local f:TField = EachIn typeId.EnumFields()
			Local j:TJSON
			
			Local fieldType:TTypeId = f.TypeId()
			
			Local serializer:TJConvSerializer = TJConvSerializer(options.serializers.ValueForKey(fieldType.Name()))
			If Not serializer Then
				serializer = defaultSerializer
			End If
			
			Select fieldType
				Case ByteTypeId
					j = serializer.Serialize(f.GetByte(obj), fieldType.Name())

				Case ShortTypeId
					j = serializer.Serialize(f.GetShort(obj), fieldType.Name())

				Case IntTypeId
					j = serializer.Serialize(f.GetInt(obj), fieldType.Name())

				Case UIntTypeId
					j = serializer.Serialize(f.GetUInt(obj), fieldType.Name())

				Case LongTypeId
					j = serializer.Serialize(f.GetLong(obj), fieldType.Name())

				Case ULongTypeId
					j = serializer.Serialize(f.GetULong(obj), fieldType.Name())

				Case SizetTypeId
					j = serializer.Serialize(f.GetSizeT(obj), fieldType.Name())
					
				Case FloatTypeId
					j = serializer.Serialize(f.GetFloat(obj), fieldType.Name())

				Case DoubleTypeId
					j = serializer.Serialize(f.GetDouble(obj), fieldType.Name())
					
				Case StringTypeId
					Local s:String = f.GetString(obj)
					If s Then
						j = serializer.Serialize(s, fieldType.Name())
						json.Set(f.Name(), j)
					End If
					Continue
			End Select
			
			If Not j And fieldType.ExtendsType(ArrayTypeId) Then
				Local array:Object = f.Get(obj)

				If array Then
					j = New TJSONArray.Create()

					ProcessArrayToJson(TJSONArray(j), fieldType, array)

				Else If Not options.emptyArraysAreNull Then
					j = New TJSONArray.Create()
				End If
			End If
			
			If Not j And fieldType.ExtendsType(ObjectTypeId) Then
				Local o:Object = f.Get(obj)
				If o Then
					Local objectTypeId:TTypeId = TTypeId.ForObject(o)
				
					j = serializer.Serialize(o, objectTypeId.Name())
				End If
			End If
			
			If j Then
				json.Set(f.Name(), j)
			End If
		Next
		
	End Method

	Method ToJson(json:TJSONArray, obj:Object)
		Local typeId:TTypeId = TTypeId.ForObject(obj)
		
		ProcessArrayToJson(json, typeId, obj)
	End Method
	
	Method ProcessArrayToJson(json:TJSONArray, typeId:TTypeId, array:Object)
		Local dims:Int
		Try
			dims = typeId.ArrayDimensions(array)
		Catch e:String
			Return
		End Try

		Local elementType:TTypeId = typeId.ElementType()
		Local size:Int

		Try
			size = typeId.ArrayLength(array)
		Catch e:String
			size = 0
		End Try

		Local serializer:TJConvSerializer = TJConvSerializer(options.serializers.ValueForKey(elementType.Name()))
		If Not serializer Then
			serializer = defaultSerializer
		End If

		For Local i:Int = 0 Until size
			Local element:TJSON

			Select elementType
				Case ByteTypeId
					element = serializer.Serialize(typeId.GetByteArrayElement(array, i), elementType.Name())

				Case ShortTypeId
					element = serializer.Serialize(typeId.GetShortArrayElement(array, i), elementType.Name())

				Case IntTypeId
					element = serializer.Serialize(typeId.GetIntArrayElement(array, i), elementType.Name())

				Case UIntTypeId
					element = serializer.Serialize(typeId.GetUIntArrayElement(array, i), elementType.Name())

				Case LongTypeId
					element = serializer.Serialize(typeId.GetLongArrayElement(array, i), elementType.Name())

				Case ULongTypeId
					element = serializer.Serialize(typeId.GetULongArrayElement(array, i), elementType.Name())

				Case SizetTypeId
					element = serializer.Serialize(typeId.GetSizeTArrayElement(array, i), elementType.Name())

				Case FloatTypeId
					element = serializer.Serialize(typeId.GetFloatArrayElement(array, i), elementType.Name())

				Case DoubleTypeId
					element = serializer.Serialize(typeId.GetDoubleArrayElement(array, i), elementType.Name())

				Case StringTypeId
					element = serializer.Serialize(typeId.GetStringArrayElement(array, i), elementType.Name())
			End Select

			If Not element And typeId.ExtendsType(ObjectTypeId) Then
				Local o:Object = typeId.GetArrayElement(array, i)
				If o Then
					Local objectTypeId:TTypeId = TTypeId.ForObject(o)
				
					element = serializer.Serialize(o, objectTypeId.Name())
				End If
			End If
			
			If element Then
				json.Append(element)
			End If
		Next

	End Method

End Type

Type TJConvOptions

	Field emptyArraysAreNull:Int = True

	Field serializers:TMap = New TMap
	'Field deserializers:TMap = New TMap

End Type

Rem
bbdoc: Serializes BlitzMax type to JSON.
End Rem
Type TJConvSerializer

	Field jconv:TJConv

	Method Serialize:TJSON(source:Byte, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method

	Method Serialize:TJSON(source:Short, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method
	
	Method Serialize:TJSON(source:Int, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method

	Method Serialize:TJSON(source:UInt, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method

	Method Serialize:TJSON(source:Long, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method

	Method Serialize:TJSON(source:ULong, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method

	Method Serialize:TJSON(source:Size_T, sourceType:String)
		Return New TJSONInteger.Create(source)
	End Method
					
	Method Serialize:TJSON(source:Float, sourceType:String)
		Return New TJSONReal.Create(source)
	End Method

	Method Serialize:TJSON(source:Double, sourceType:String)
		Return New TJSONReal.Create(source)
	End Method

	Method Serialize:TJSON(source:String, sourceType:String)
		Return New TJSONString.Create(source)
	End Method

	Method Serialize:TJSON(source:Object, sourceType:String)
		Local json:TJSONObject = New TJSONObject.Create()
		jconv.ToJson(json, source)
		Return json
	End Method
	
End Type

'Type TJConvDeserializer
'
'	Field jconv:TJConv
'
'End Type
