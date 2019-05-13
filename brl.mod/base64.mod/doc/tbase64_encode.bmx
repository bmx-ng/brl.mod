SuperStrict

Framework brl.standardio
Import brl.base64

Local someData:String = "Hello BlitzMax World!"
Local encoded:String = TBase64.Encode(someData.ToUTF8String(), someData.length)
Print "Encoded : " + encoded

