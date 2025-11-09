SuperStrict

Rem
bbdoc: Data structures/StringMap
about: A maps data structure with String keys.
End Rem
Module BRL.StringMap

ModuleInfo "Version: 1.14"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2019-2025 Bruce A Henderson"

ModuleInfo "History: 1.14"
ModuleInfo "History: Now backed by TTreeMap."
ModuleInfo "History: Added option to use case insensitive keys."
ModuleInfo "History: 1.13"
ModuleInfo "History: Moved generic-based maps to their own modules."
ModuleInfo "History: 1.12"
ModuleInfo "History: Refactored tree based maps to use brl.collections."

Import BRL.Collections

Rem
bbdoc: A Tree map backed map with String keys and Object values.
End Rem
Type TStringMap
	
	Field _map:TTreeMap<String, Object>
	Field _caseSensitive:Int = True

	Rem
	bbdoc: Creates a new TStringMap.
	about: By default, the map is case-sensitive.
	End Rem
	Method New()
		_map = New TTreeMap<String, Object>
	End Method

	Rem
	bbdoc: Creates a new TStringMap.
	about: If caseSensitive is #False, the map will be case-insensitive.
	End Rem
	Method New(caseSensitive:Int)
		_caseSensitive = caseSensitive
		If Not _caseSensitive Then
			_map = New TTreeMap<String, Object>( New TStringCaseInsensitiveComparator )
		Else
			_map = New TTreeMap<String, Object>
		End If
	End Method

	Method Clear()
		_map.Clear()
	End Method

	Method IsEmpty:Int()
		Return _map.IsEmpty()
	End Method

	Method Insert( key:String,value:Object )
		_map.Put(key, value)
	End Method

	Method Contains:Int( key:String )
		Return _map.ContainsKey(key)
	End Method

	Method ValueForKey:Object( key:String )
		Local v:Object
		If _map.TryGetValue( key, v ) Then
			Return v
		End If
		Return Null
	End Method

	Method ValueForKey:Int( key:String, value:Object Var )
		Return _map.TryGetValue( key, value )
	End Method

	Method Remove:Int( key:String )
		Return _map.Remove(key)
	End Method

	Method Keys:TStringMapEnumerator()
		Local nodeEnumerator:TStringKeyEnumerator = New TStringKeyEnumerator
		nodeEnumerator._mapIterator = TMapIterator<String,Object>(_map.GetIterator())
		Local mapEnumerator:TStringMapEnumerator = New TStringMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Values:TStringMapEnumerator()
		Local nodeEnumerator:TStringValueEnumerator = New TStringValueEnumerator
		nodeEnumerator._mapIterator = TMapIterator<String,Object>(_map.GetIterator())
		Local mapEnumerator:TStringMapEnumerator = New TStringMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Copy:TStringMap()
		Local newMap:TStringMap = New TStringMap(_caseSensitive)
		Local iter:TMapIterator<String,Object> = TMapIterator<String,Object>(_map.GetIterator())
		While iter.MoveNext()
			Local n:TMapNode<String,Object> = iter.Current()
			If n Then
				newMap._map.Add( n.GetKey(), n.GetValue() )
			End If
		Wend
		Return newMap
	End Method

	Method ObjectEnumerator:TStringNodeEnumerator()
		Local nodeEnumerator:TStringNodeEnumerator = New TStringNodeEnumerator
		nodeEnumerator._mapIterator = TMapIterator<String,Object>(_map.GetIterator())
		Return nodeEnumerator
	End Method

	Method Operator[]:Object(key:String)
		Return _map[key]
	End Method

	Method Operator[]=(key:String, value:Object)
		_map[key] = value
	End Method

End Type

Type TStringKeyValue

	Field _key:String
	Field _value:Object

	Method Key:String()
		Return _key
	End Method

	Method Value:Object()
		Return _value
	End Method
End Type

Type TStringNodeEnumerator

	Method HasNext:Int()
		Return _mapIterator.HasNext()
	End Method

	Method NextObject:Object()
		_mapIterator.MoveNext()
		Local n:TMapNode<String,Object> = _mapIterator.Current()
		If n Then
			keyValue._key = n.GetKey()
			keyValue._value = n.GetValue()
			Return keyValue
		End If	
	End Method

	'***** PRIVATE *****
		
	Field _mapIterator:TMapIterator<String,Object>
	Field keyValue:TStringKeyValue = New TStringKeyValue

End Type

Type TStringKeyEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<String,Object> = _mapIterator.Current()
		If n Then
			Return n.GetKey()
		End If
	End Method
End Type

Type TStringValueEnumerator Extends TStringNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<String,Object> = _mapIterator.Current()
		If n Then
			Return n.GetValue()
		End If
	End Method
End Type

Type TStringMapEnumerator
	Method ObjectEnumerator:TStringNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TStringNodeEnumerator
End Type

Type TStringCaseInsensitiveComparator Implements IComparator<String>
	Method Compare:Int(a:String, b:String)
		Return a.Compare(b, False)
	End Method
End Type
