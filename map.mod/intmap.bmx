SuperStrict

Import BRL.Collections

Type TIntMap
	
	Field _map:TTreeMap<Int, Object> = New TTreeMap<Int, Object>()

	Method Clear()
		_map.Clear()
	End Method

	Method IsEmpty:Int()
		Return _map.IsEmpty()
	End Method

	Method Insert( key:Int,value:Object )
		_map.Put(key, value)
	End Method

	Method Contains:Int( key:Int )
		Return _map.ContainsKey(key)
	End Method

	Method ValueForKey:Object( key:Int )
		Local v:Object
		If _map.TryGetValue( key, v ) Then
			Return v
		End If
		Return Null
	End Method

	Method Remove:Int( key:Int )
		Return _map.Remove(key)
	End Method

	Method Keys:TIntMapEnumerator()
		Local nodeEnumerator:TIntKeyEnumerator = New TIntKeyEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Int,Object>(_map.GetIterator())
		Local mapEnumerator:TIntMapEnumerator = New TIntMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Values:TIntMapEnumerator()
		Local nodeEnumerator:TIntValueEnumerator = New TIntValueEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Int,Object>(_map.GetIterator())
		Local mapEnumerator:TIntMapEnumerator = New TIntMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Copy:TIntMap()
		Local newMap:TIntMap = New TIntMap
		Local iter:TMapIterator<Int,Object> = TMapIterator<Int,Object>(_map.GetIterator())
		While iter.MoveNext()
			Local n:TMapNode<Int,Object> = iter.Current()
			If n Then
				newMap._map.Add( n.GetKey(), n.GetValue() )
			End If
		Wend
		Return newMap
	End Method

	Method ObjectEnumerator:TIntNodeEnumerator()
		Local nodeEnumerator:TIntNodeEnumerator = New TIntNodeEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Int,Object>(_map.GetIterator())
		Return nodeEnumerator
	End Method

	Method Operator[]:Object(key:Int)
		Return _map[key]
	End Method

	Method Operator[]=(key:Int, value:Object)
		_map[key] = value
	End Method

End Type

Rem
bbdoc: Int holder for key returned by TIntMap.Keys() enumerator.
about: Because a single instance of #TIntKey is used during enumeration, #value changes on each iteration.
End Rem
Type TIntKey
	Rem
	bbdoc: Int key value.
	End Rem
	Field value:Int
End Type

Type TIntKeyValue

	Field _key:Int
	Field _value:Object

	Method Key:Int()
		Return _key
	End Method

	Method Value:Object()
		Return _value
	End Method
End Type

Type TIntNodeEnumerator

	Method HasNext:Int()
		Return _mapIterator.HasNext()
	End Method

	Method NextObject:Object()
		_mapIterator.MoveNext()
		Local n:TMapNode<Int,Object> = _mapIterator.Current()
		If n Then
			keyValue._key = n.GetKey()
			keyValue._value = n.GetValue()
			Return keyValue
		End If	
	End Method

	'***** PRIVATE *****
		
	Field _mapIterator:TMapIterator<Int,Object>
	Field keyValue:TIntKeyValue = New TIntKeyValue

End Type

Type TIntKeyEnumerator Extends TIntNodeEnumerator
	Field _key:TIntKey = New TIntKey
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Int,Object> = _mapIterator.Current()
		If n Then
			_key.value = n.GetKey()
			Return _key
		End If
	End Method
End Type

Type TIntValueEnumerator Extends TIntNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Int,Object> = _mapIterator.Current()
		If n Then
			Return n.GetValue()
		End If
	End Method
End Type

Type TIntMapEnumerator
	Method ObjectEnumerator:TIntNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TIntNodeEnumerator
End Type
