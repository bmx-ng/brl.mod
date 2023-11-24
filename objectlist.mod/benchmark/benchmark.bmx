SuperStrict

Framework brl.standardio
Import brl.linkedlist
Import brl.objectlist

Global words:String[] = ["ring", "white", "infection", "calorie", "wage", "trust", "adventure", "ribbon", "assumption", "marble", ..
	"favorable", "gun", "bark", "lick", "frank", "idea", "game", "white", "generation", "perfect", "leash", "sniff", "formal", ..
	"hay", "pavement", "treaty", "user", "outer", "heir", "looting", "plaintiff", "welfare", "pier", "adventure", "ribbon", ..
	"assumption", "precision", "image", "review", "idea", "game", "white", "generation", "perfect", "move", "establish", "lamp",
	"fool", "ridge", "fortune", "psychology", "idea", "matter", "appearance", "fruit", "velvet", "white", "thread", "bless", "scream", "heaven"]

Global sorted_words:String[] = ["adventure", "adventure", "appearance", "assumption", "assumption", "bark", "bless", "calorie", ..
	"establish", "favorable", "fool", "formal", "fortune", "frank", "fruit", "game", "game", "generation", "generation", "gun", ..
	"hay", "heaven", "heir", "idea", "idea", "idea", "image", "infection", "lamp", "leash", "lick", "looting", "marble", "matter", ..
	"move", "outer", "pavement", "perfect", "perfect", "pier", "plaintiff", "precision", "psychology", "review", "ribbon", "ribbon", ..
	"ridge", "ring", "scream", "sniff", "thread", "treaty", "trust", "user", "velvet", "wage", "welfare", "white", "white", "white", "white" ]
	
Global reversed_words:String[] = ["white", "white", "white", "white", "welfare", "wage", "velvet", "user", "trust", "treaty", ..
	"thread", "sniff", "scream", "ring", "ridge", "ribbon", "ribbon", "review", "psychology", "precision", "plaintiff", "pier", ..
	"perfect", "perfect", "pavement", "outer", "move", "matter", "marble", "looting", "lick", "leash", "lamp", "infection", "image", ..
	"idea", "idea", "idea", "heir", "heaven", "hay", "gun", "generation", "generation", "game", "game", "fruit", "frank", "fortune", ..
	"formal", "fool", "favorable", "establish", "calorie", "bless", "bark", "assumption", "assumption", "appearance", "adventure", "adventure"]

Const COUNT:Int = 10000

Print "Using " + COUNT + " iterations with " + words.length + " words list :"

Local log1:TTestLogger = testTList()
Local log2:TTestLogger = testTObjectList()

MergeLogs([log1, log2])

Function testTList:TTestLogger()
	Local out:TTestLogger = New TTestLogger

	out.Print " "
	out.Print "TList"
	Local list:TList = New TList
	
	out.Print "  AddLast/Clear"	
	Local ts:Int = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local s:String = EachIn words
			list.AddLast(s)
		Next
		If list.Count() <> words.length Throw "Wrong count"
		list.Clear()
		If list.Count() <> 0 Throw "Wrong count"
	Next
	Local te:Int = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddFirst/Clear"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local s:String = EachIn words
			list.AddFirst(s)
		Next
		If list.Count() <> words.length Throw "Wrong count"
		list.Clear()
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Contains"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		Local total:Int
		For Local s:String = EachIn words
			If list.Contains(s) Then
				total :+ 1
			End If
		Next
		If total <> words.length Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  ValueAtIndex"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local n:Int = 0 Until words.length
			Local s:String = String(list.ValueAtIndex(n))
			If s <> words[n] Then Throw "Wrong value : " + s + "/" + words[n]
		Next
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  First/Last"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT * 10
		If list.First() <> words[0] Then Throw "Wrong value"
		If list.Last() <> words[words.length - 1] Then Throw "Wrong value"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/RemoveFirst"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		For Local s:String = EachIn words
			Local v:String = String(list.RemoveFirst())
			If v <> s Then Throw "Wrong value : " + v + "/" + s
		Next
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/RemoveLast"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		Local n:Int = words.length - 1
		While n >= 0
			Local s:String = words[n]
			Local v:String = String(list.RemoveLast())
			If v <> s Then Throw "Wrong value : " + v + "/" + s
			n :- 1
		Wend
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/Contains/Remove"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		Local toRemove:String[] = ["white", "idea", "game"]

		For Local s:String = EachIn toRemove
			While list.Contains(s)
				If Not list.Remove(s) Then Throw "nothing to remove"
			Wend
		Next
		
		If list.Count() <> 52 Throw "Wrong count : " + list.Count() + "/" + 52
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/Contains/Remove+/Compact"	
	out.Print "    n/a"

	out.Print "  enumerating"
	ts = MilliSecs()
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	For Local i:Int = 0 Until COUNT
		Local n:Int
		For Local s:String = EachIn list
			Local v:String = words[n]
			If s <> v Then Throw "Wrong value : " + s + "/" + v
			n :+ 1
		Next
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/enumerate/Remove"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next
		
		For Local s:String = EachIn list
			list.Remove(s)
		Next
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Reverse"
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	Local toggle:Int
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT * 5
		list.Reverse()
		If toggle Then
			If list.First() <> words[0] Throw "Wrong Value"
			If list.Last() <> words[words.length-1] Throw "Wrong Value"
		Else
			If list.Last() <> words[0] Throw "Wrong Value"
			If list.First() <> words[words.length-1] Throw "Wrong Value"
		End If
		toggle = 1 - toggle
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Copy"
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		Local list2:TList = list.Copy()
		If list2.Count() <> words.length Throw "wrong size"
		If list2.First() <> words[0] Throw "Wrong Value"
		If list2.Last() <> words[words.length-1] Throw "Wrong Value"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/Sort"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		list.Sort()
		
	Next
	te = MilliSecs()
	For Local i:Int = 0 Until sorted_words.length
		If String(list.ValueAtIndex(i)) <> sorted_words[i] Throw "Wrong Value"
	Next
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/Sort (reversed)"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		list.Sort(False)
	Next
	te = MilliSecs()
	For Local i:Int = 0 Until reversed_words.length
		If String(list.ValueAtIndex(i)) <> reversed_words[i] Throw "Wrong Value"
	Next
	out.Print "    took " + (te - ts) + "ms"


	Return out
End Function

Function testTObjectList:TTestLogger()
	Local out:TTestLogger = New TTestLogger

	out.Print " "
	out.Print "TObjectList"
	Local list:TObjectList = New TObjectList
	
	out.Print "  AddLast/Clear"	
	Local ts:Int = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local s:String = EachIn words
			list.AddLast(s)
		Next
		If list.Count() <> words.length Throw "Wrong count"
		list.Clear()
		If list.Count() <> 0 Throw "Wrong count"
	Next
	Local te:Int = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddFirst/Clear"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local s:String = EachIn words
			list.AddFirst(s)
		Next
		If list.Count() <> words.length Throw "Wrong count"
		list.Clear()
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Contains"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		Local total:Int
		For Local s:String = EachIn words
			If list.Contains(s) Then
				total :+ 1
			End If
		Next
		If total <> words.length Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  ValueAtIndex"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		For Local n:Int = 0 Until words.length
			Local s:String = String(list.ValueAtIndex(n))
			If s <> words[n] Then Throw "Wrong value : " + s + "/" + words[n]
		Next
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  First/Last"	
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT * 10
		If list.First() <> words[0] Then Throw "Wrong value"
		If list.Last() <> words[words.length - 1] Then Throw "Wrong value"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/RemoveFirst"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		For Local s:String = EachIn words
			Local v:String = String(list.RemoveFirst())
			If v <> s Then Throw "Wrong value : " + v + "/" + s
		Next
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/RemoveLast"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		Local n:Int = words.length - 1
		While n >= 0
			Local s:String = words[n]
			Local v:String = String(list.RemoveLast())
			If v <> s Then Throw "Wrong value : " + v + "/" + s
			n :- 1
		Wend
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/Contains/Remove"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		Local toRemove:String[] = ["white", "idea", "game"]

		For Local s:String = EachIn toRemove
			While list.Contains(s)
				If Not list.Remove(s) Then Throw "nothing to remove"
			Wend
		Next
		
		list.Compact()
		
		If list.Count() <> 52 Throw "Wrong count : " + list.Count() + "/" + 52
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  AddLast/Contains/Remove+/Compact"	
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		Local toRemove:String[] = ["white", "idea", "game"]

		For Local s:String = EachIn toRemove
			While list.Contains(s)
				If Not list.Remove(s, True, False) Then Throw "nothing to remove"
			Wend
		Next
		
		If list.Count() <> 52 Throw "Wrong count : " + list.Count() + "/" + 52
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  enumerating"
	ts = MilliSecs()
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	For Local i:Int = 0 Until COUNT
		Local n:Int
		For Local s:String = EachIn list
			Local v:String = words[n]
			If s <> v Then Throw "Wrong value : " + s + "/" + v
			n :+ 1
		Next
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/enumerate/Remove"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next
		
		For Local s:String = EachIn list
			list.Remove(s, False, False)
		Next
		If list.Count() <> 0 Throw "Wrong count"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Reverse"
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	Local toggle:Int
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT * 5
		list.Reverse()
		If toggle Then
			If list.First() <> words[0] Throw "Wrong Value"
			If list.Last() <> words[words.length-1] Throw "Wrong Value"
		Else
			If list.Last() <> words[0] Throw "Wrong Value"
			If list.First() <> words[words.length-1] Throw "Wrong Value"
		End If
		toggle = 1 - toggle
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Copy"
	list.Clear()
	For Local s:String = EachIn words
		list.AddLast(s)
	Next
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		Local list2:TObjectList = list.Copy()
		If list2.Count() <> words.length Throw "wrong size"
		If list2.First() <> words[0] Throw "Wrong Value"
		If list2.Last() <> words[words.length-1] Throw "Wrong Value"
	Next
	te = MilliSecs()
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/Sort"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		list.Sort()
	Next
	te = MilliSecs()
	For Local i:Int = 0 Until sorted_words.length
		If String(list.ValueAtIndex(i)) <> sorted_words[i] Throw "Wrong Value"
	Next
	out.Print "    took " + (te - ts) + "ms"

	out.Print "  Clear/AddLast/Sort (reversed)"
	ts = MilliSecs()
	For Local i:Int = 0 Until COUNT
		list.Clear()
		For Local s:String = EachIn words
			list.AddLast(s)
		Next

		list.Sort(False)
	Next
	te = MilliSecs()
	For Local i:Int = 0 Until reversed_words.length
		If String(list.ValueAtIndex(i)) <> reversed_words[i] Throw "Wrong Value"
	Next
	out.Print "    took " + (te - ts) + "ms"

	Return out
End Function

Type TTestLogger
	Field LINES:TList = New TList
	Method Print(s:String)
		LINES.AddLast(s)
	End Method
End Type

Function MergeLogs(logs:TTestLogger[])

'	For Local n:Int = 0 Until logs.length
'		Print "log " + n + " LINES = " + logs[n].LINES.count()
'	Next

	Local widest:Int
	Local pad:String
	Local Log:TTestLogger = logs[0]
	Local count:Int
	For Local s:String = EachIn Log.LINES
		If s.length > widest Then
			widest = s.length
		End If
		count :+ 1
	Next
	For Local i:Int = 0 Until widest
		pad :+ " "
	Next
	
	For Local i:Int = 0 Until count
		Local s:String
		For Local n:Int = 0 Until logs.length
			Local txt:String = String(logs[n].LINES.ValueAtIndex(i))
			s :+ (txt + pad)[..widest + 2] 
		Next
		Print s
	Next
End Function
