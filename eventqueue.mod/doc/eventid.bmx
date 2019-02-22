SuperStrict

Import MaxGUI.Drivers

Local MyWindow:TGadget=CreateWindow("Button Example", 200,200,320,240)
Local MyButton:TGadget=CreateButton("Click Me",140,60,80,40, MyWindow)

Repeat
  WaitEvent()
  Select EventID()
  Case EVENT_WINDOWCLOSE
     End
   End Select
Forever
