SuperStrict

Type TComparatorArraySort<T> Extends TArraySort<T>

	Field comparator:IComparator<T>
	
	Method New(comparator:IComparator<T>)
		Self.comparator = comparator
	End Method

	Method DoCompare:Int(a:T, b:T) Override
		Return comparator.Compare(a, b)
	End Method

End Type

Type TArraySort<T>

	Method DoCompare:Int(a:T, b:T)
		Return DefaultComparator_Compare(a, b)
	End Method

	Method Sort(array:T[], low:Int, high:Int, depthLimit:Int)

		While high > low
		
			Local partitionSize:Int = high - low + 1
			If partitionSize <= 16 Then
				If partitionSize = 1 Then
					Return
				End If
				
				If partitionSize = 2 Then
					SwapIfGreater(array, low, high)
					Return
				End If
				
				If partitionSize = 3 Then
					SwapIfGreater(array, low, high - 1)
					SwapIfGreater(array, low, high)
					SwapIfGreater(array, high - 1, high)
					Return
				End If
				
				InsertionSort(array, low, high)
				Return
			End If
		
			If Not depthLimit Then
				Heapsort(array, low, high)
				Return
			End If
			
			depthLimit :- 1
			
			Local pivot:Int = PickPivotAndPartition(array, low, high)
			Sort(array, pivot + 1, high, depthLimit)
			high = pivot - 1
		Wend
	End Method

	Method SwapIfGreater(array:T[], a:Int, b:Int)
		If a <> b Then
			If DoCompare(array[a], array[b]) > 0 Then
				Local tmp:T = array[a]
				array[a] = array[b]
				array[b] = tmp
			End If
		End If
	End Method

	Method Swap(array:T[], a:Int, b:Int)
		If a <> b Then
			Local tmp:T = array[a]
			array[a] = array[b]
			array[b] = tmp
		End If
	End Method
	
	Method InsertionSort(array:T[], low:Int, high:Int)
		For Local i:Int = low Until high
			Local n:Int = i
			Local tmp:T = array[i + 1]
			While n >= low And DoCompare(tmp, array[n]) < 0
				array[n + 1] = array[n]
				n :- 1
			Wend
			array[n + 1] = tmp
		Next
	End Method
	
	Method HeapSort(array:T[], low:Int, high:Int)
		Local n:Int = high - low + 1
		Local i:Int = n / 2
		While i >= 1
			DownHeap(array, i, n, low)
			i :- 1
		Wend
		i = n
		While i > 1
			Swap(array, low, low + i - 1)
			DownHeap(array, 1, i - 1, low)
			i :- 1
		Wend
	End Method

	Method DownHeap(array:T[], i:Int, n:Int, low:Int)
		Local down:T = array[low + i - 1]
		Local child:Int
		While i <= n / 2
			child = 2 * i
			If child < n And DoCompare(array[low + child - 1], array[low + child]) < 0 Then
				child :+ 1
			End If
			If DoCompare(down, array[low + child - 1]) >= 0 Then
				Exit
			End If
			array[low + i - 1] = array[low + child - 1]
			i = child
		Wend
		array[low + i - 1] = down
	End Method

	Method PickPivotAndPartition:Int(array:T[], low:Int, high:Int)
		Local middle:Int = low + ((high - low) / 2)
		
		SwapIfGreater(array, low, middle)
		SwapIfGreater(array, low, high)
		SwapIfGreater(array, middle, high)

		Local pivot:T = array[middle]
		Swap(array, middle, high - 1)
		Local lft:Int = low
		Local rgt:Int = high - 1
		
		While lft < rgt
			lft :+ 1
			While DoCompare(array[lft], pivot) < 0
				lft :+ 1
			Wend
			rgt :- 1
			While DoCompare(pivot, array[rgt]) < 0
				rgt :- 1
			Wend

			If lft >= rgt Then
				Exit
			End If

			Swap(array, lft, rgt)
		Wend

		Swap(array, lft, high - 1)
		Return lft
	End Method
	
End Type
