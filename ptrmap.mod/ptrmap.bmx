SuperStrict

Rem
bbdoc: Data structures/PtrMap
about: A maps data structure with Byte Ptr keys.
End Rem
Module BRL.PtrMap

ModuleInfo "Version: 1.13"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2019-2025 Bruce A Henderson"

ModuleInfo "History: 1.13"
ModuleInfo "History: Moved generic-based maps to their own modules."
ModuleInfo "History: 1.12"
ModuleInfo "History: Refactored tree based maps to use brl.collections."

Import BRL.Collections

Rem
bbdoc: A Tree map backed map with Byte Ptr keys and Object values.
End Rem
Type TPtrMap

	Field _map:TTreeMap<Byte Ptr, Object> = New TTreeMap<Byte Ptr, Object>()

	Method Clear()
		_map.Clear()
	End Method

	Method IsEmpty:Int()
		Return _map.IsEmpty()
	End Method

	Method Insert( key:Byte Ptr,value:Object )
		_map.Put(key, value)
	End Method

	Method Contains:Int( key:Byte Ptr )
		Return _map.ContainsKey(key)
	End Method

	Method ValueForKey:Object( key:Byte Ptr )
		Local v:Object
		If _map.TryGetValue( key, v ) Then
			Return v
		End If
		Return Null
	End Method

	Method Remove:Int( key:Byte Ptr )
		Return _map.Remove(key)
	End Method

	Method Keys:TPtrMapEnumerator()
		Local nodeEnumerator:TPtrKeyEnumerator = New TPtrKeyEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Byte Ptr,Object>(_map.GetIterator())
		Local mapEnumerator:TPtrMapEnumerator = New TPtrMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Values:TPtrMapEnumerator()
		Local nodeEnumerator:TPtrValueEnumerator = New TPtrValueEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Byte Ptr,Object>(_map.GetIterator())
		Local mapEnumerator:TPtrMapEnumerator = New TPtrMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Copy:TPtrMap()
		Local newMap:TPtrMap = New TPtrMap
		Local iter:TMapIterator<Byte Ptr,Object> = TMapIterator<Byte Ptr,Object>(_map.GetIterator())
		While iter.MoveNext()
			Local n:TMapNode<Byte Ptr,Object> = iter.Current()
			If n Then
				newMap._map.Add( n.GetKey(), n.GetValue() )
			End If
		Wend
		Return newMap
	End Method

	Method ObjectEnumerator:TPtrNodeEnumerator()
		Local nodeEnumerator:TPtrNodeEnumerator = New TPtrNodeEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Byte Ptr,Object>(_map.GetIterator())
		Return nodeEnumerator
	End Method

	Method Operator[]:Object(key:Byte Ptr)
		Return _map[key]
	End Method

	Method Operator[]=(key:Byte Ptr, value:Object)
		_map[key] = value
	End Method

End Type

Rem
bbdoc: Int holder for key returned by TPtrMap.Keys() enumerator.
about: Because a single instance of #TPtrKey is used during enumeration, #value changes on each iteration.
End Rem
Type TPtrKey
	Rem
	bbdoc: Byte Ptr key value.
	End Rem
	Field value:Byte Ptr
End Type

Type TPtrKeyValue

	Field _key:Byte Ptr
	Field _value:Object

	Method Key:Byte Ptr()
		Return _key
	End Method

	Method Value:Object()
		Return _value
	End Method
End Type

Type TPtrNodeEnumerator

	Method HasNext:Int()
		Return _mapIterator.HasNext()
	End Method

	Method NextObject:Object()
		_mapIterator.MoveNext()
		Local n:TMapNode<Byte Ptr,Object> = _mapIterator.Current()
		If n Then
			keyValue._key = n.GetKey()
			keyValue._value = n.GetValue()
			Return keyValue
		End If	
	End Method

	'***** PRIVATE *****
		
	Field _mapIterator:TMapIterator<Byte Ptr,Object>
	Field keyValue:TPtrKeyValue = New TPtrKeyValue

End Type

Type TPtrKeyEnumerator Extends TPtrNodeEnumerator
	Field _key:TPtrKey = New TPtrKey
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Byte Ptr,Object> = _mapIterator.Current()
		If n Then
			_key.value = n.GetKey()
			Return _key
		End If
	End Method
End Type

Type TPtrValueEnumerator Extends TPtrNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Byte Ptr,Object> = _mapIterator.Current()
		If n Then
			Return n.GetValue()
		End If
	End Method
End Type

Type TPtrMapEnumerator
	Method ObjectEnumerator:TPtrNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TPtrNodeEnumerator
End Type
