SuperStrict

Import "iterator.bmx"
Import "errors.bmx"

Interface ICollection<E> Extends IIterable<E>

	Method Size:Int()
	Method IsEmpty:Int()
	Method Iterator:IIterator<E>()
	Method ToArray:E[]()
	Method Add:Int(element:E)
	Method Remove:Int(element:E)
	Method Contains:Int(element:E)
	Method ContainsAll:Int(c:ICollection<E>)
	Method AddAll:Int(c:ICollection<E>)
	Method AddAll:Int(a:E[])
	Method RemoveAll:Int(c:ICollection<E>)
	Method RetainAll:Int(c:ICollection<E>)
	Method Clear()
	Method Equals:Int(o:Object)

End Interface


Type TAbstractCollection<E> Implements ICollection<E> Abstract

	Method Iterator:IIterator<E>() Abstract
	Method Size:Int() Abstract
	
	Method IsEmpty:Int()
		Return Size() = 0
	End Method

	Method Add:Int(element:E)
		Throw New TUnsupportedOperationException
	End Method
	
	Method AddAll:Int(c:ICollection<E>)
		Local isModified:Int
		Local i:IIterator<E> = c.Iterator()
		While i.HasNext()
			If Add(i.NextElement()) Then
				isModified = True
			End If
		Wend
		Return isModified
	End Method
	
	Method AddAll:Int(a:E[])
		Local isModified:Int
		If a Then
			For Local i:E = EachIn a
				If Add(i) Then
					isModified = True
				End If
			Next
		End If
		Return isModified
	End Method

	Method Clear()
		Local i:IIterator<E> = Iterator()
		While i.HasNext()
			i.NextElement()
			i.Remove()
		Wend
	End Method
	
	Method Contains:Int(element:E)
		Local i:IIterator<E> = Iterator()
		If Not element Then
			While i.HasNext()
				If Not i.NextElement() Then
					Return True
				End If
			Wend
		Else
			While i.HasNext()
				If element = i.NextElement() Then
					Return True
				End If
			Wend
		End If
		Return False
	End Method
	
	Method ToArray:E[]()
		' TODO
	End Method
	
	Method RemoveAll:Int(c:ICollection<E>)
		Local isModified:Int
		Local i:IIterator<E> = Iterator()
		While i.HasNext()
			If c.Contains(i.NextElement()) Then
				i.Remove()
				isModified = True
			End If
		Wend
		Return isModified
	End Method
	
	Method Remove:Int(element:E)
		Local i:IIterator<E> = Iterator()
		If Not element Then
			While i.HasNext()
				If Not i.NextElement() Then
					i.Remove()
					Return True
				End If
			Wend
		Else
			While i.HasNext()
				If element = i.NextElement() Then
					i.Remove()
					Return True
				End If
			Wend
		End If
		Return False
	End Method
	
	Method ContainsAll:Int(c:ICollection<E>)
		Local i:IIterator<E> = c.Iterator()
		While i.HasNext()
			If Not Contains(i.NextElement()) Then
				Return False
			End If
		Wend
		Return True
	End Method
	
	Method RetainAll:Int(c:ICollection<E>)
		Local isModified:Int
		Local i:IIterator<E> = Iterator()
		While i.HasNext()
			If Not c.Contains(i.NextElement()) Then
				i.Remove()
				isModified = True
			End If
		Wend
		Return isModified
	End Method
	
End Type

