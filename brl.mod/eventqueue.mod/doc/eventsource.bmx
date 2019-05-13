SuperStrict

Import MaxGUI.Drivers

Local MyWindow:TGadget=CreateWindow("Two Buttons Example", 200,200,320,240)
Local Button1:TGadget=CreateButton("One",140,40,80,40, MyWindow)
Local Button2:TGadget=CreateButton("Two",140,100,80,40, MyWindow)

Repeat
  WaitEvent()
  Select EventID()
  Case EVENT_WINDOWCLOSE
     End
  Case EVENT_GADGETACTION
    Select EventSource()
      Case Button1
         SetGadgetText(Button1,"One clicked")
      Case Button2
         SetGadgetText(Button2,"Two clicked")
      End Select
   End Select
Forever

