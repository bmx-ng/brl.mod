SuperStrict
Framework BRL.StandardIO

Type TBox
    Field value:Int
End Type

Global keeper:TBox

Function MakeGlobal()
    keeper = New TBox
    keeper.value = 42
End Function

Function CheckLocal:Int()
    Local item:TBox = New TBox
    item.value = 17
    For Local i:Int = 0 Until 20
        GCCollect()
    Next
    Return item.value
End Function

MakeGlobal()
For Local i:Int = 0 Until 20
    GCCollect()
Next
Print keeper.value
Print CheckLocal()
