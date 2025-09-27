SuperStrict

Import BRL.Collections

Type TObjectMap

	Field _map:TTreeMap<Object, Object> = New TTreeMap<Object, Object>()

	Method Clear()
		_map.Clear()
	End Method

	Method IsEmpty:Int()
		Return _map.IsEmpty()
	End Method

	Method Insert( key:Object,value:Object )
		_map.Put(key, value)
	End Method

	Method Contains:Int( key:Object )
		Return _map.ContainsKey(key)
	End Method

	Method ValueForKey:Object( key:Object )
		Local v:Object
		If _map.TryGetValue( key, v ) Then
			Return v
		End If
		Return Null
	End Method

	Method Remove:Int( key:Object )
		Return _map.Remove(key)
	End Method

	Method Keys:TObjectMapEnumerator()
		Local nodeEnumerator:TObjectKeyEnumerator = New TObjectKeyEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Object,Object>(_map.GetIterator())
		Local mapEnumerator:TObjectMapEnumerator = New TObjectMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Values:TObjectMapEnumerator()
		Local nodeEnumerator:TObjectValueEnumerator = New TObjectValueEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Object,Object>(_map.GetIterator())
		Local mapEnumerator:TObjectMapEnumerator = New TObjectMapEnumerator
		mapEnumerator._enumerator = nodeEnumerator
		Return mapEnumerator
	End Method

	Method Copy:TObjectMap()
		Local newMap:TObjectMap = New TObjectMap
		Local iter:TMapIterator<Object,Object> = TMapIterator<Object,Object>(_map.GetIterator())
		While iter.MoveNext()
			Local n:TMapNode<Object,Object> = iter.Current()
			If n Then
				newMap._map.Add( n.GetKey(), n.GetValue() )
			End If
		Wend
		Return newMap
	End Method

	Method ObjectEnumerator:TObjectNodeEnumerator()
		Local nodeEnumerator:TObjectNodeEnumerator = New TObjectNodeEnumerator
		nodeEnumerator._mapIterator = TMapIterator<Object,Object>(_map.GetIterator())
		Return nodeEnumerator
	End Method

	Method Operator[]:Object(key:Object)
		Return _map[key]
	End Method

	Method Operator[]=(key:Object, value:Object)
		_map[key] = value
	End Method

End Type

Type TObjectKeyValue

	Field _key:Object
	Field _value:Object

	Method Key:Object()
		Return _key
	End Method

	Method Value:Object()
		Return _value
	End Method
End Type

Type TObjectNodeEnumerator

	Method HasNext:Int()
		Return _mapIterator.HasNext()
	End Method

	Method NextObject:Object()
		_mapIterator.MoveNext()
		Local n:TMapNode<Object,Object> = _mapIterator.Current()
		If n Then
			keyValue._key = n.GetKey()
			keyValue._value = n.GetValue()
			Return keyValue
		End If	
	End Method

	'***** PRIVATE *****
		
	Field _mapIterator:TMapIterator<Object,Object>
	Field keyValue:TObjectKeyValue = New TObjectKeyValue

End Type

Type TObjectKeyEnumerator Extends TObjectNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Object,Object> = _mapIterator.Current()
		If n Then
			Return n.GetKey()
		End If
	End Method
End Type

Type TObjectValueEnumerator Extends TObjectNodeEnumerator
	Method NextObject:Object() Override
		_mapIterator.MoveNext()
		Local n:TMapNode<Object,Object> = _mapIterator.Current()
		If n Then
			Return n.GetValue()
		End If
	End Method
End Type

Type TObjectMapEnumerator
	Method ObjectEnumerator:TObjectNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TObjectNodeEnumerator
End Type
