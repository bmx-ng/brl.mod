SuperStrict

Import "collection.bmx"
Import "comparator.bmx"

Interface ISet<E> Extends ICollection<E>

End Interface

Type TAbstractSet<E> Extends TAbstractCollection<E> Implements ISet<E> Abstract

	Method Equals:Int(o:Object)
		' TODO
	End Method
	
	Method RemoveAll:Int(c:ICollection<E>)
		Local modified:Int
		If Size() > c.Size() Then
			Local it:IIterator<E> = c.Iterator()
			While it.HasNext()
				modified :| Remove(it.NextElement())
			Wend
		Else
		
			Local it:IIterator<E> = Iterator()
			While it.HasNext()
				If c.Contains(it.NextElement()) Then
					it.Remove()
					modified = True
				End If
			Wend
		End If
		
		Return modified
	End Method

End Type


Interface INavigableSet<E> Extends ISortedSet<E>

	Method Lower:E(element:E)
	Method Floor:E(element:E)
	Method Higher:E(element:E)
	Method PollFirst:E()
	Method PollLast:E()
	Method DescendingSet:INavigableSet<E>()
	Method DescentingIterator:IIterator<E>()

End Interface

Interface ISortedSet<E> Extends ISet<E>

	Method Comparator:IComparator<E>()
	Method First:E()
	Method Last:E()

End Interface


