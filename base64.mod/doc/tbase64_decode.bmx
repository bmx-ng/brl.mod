SuperStrict

Framework brl.standardio
Import brl.base64

Local encodedData:String = "SGVsbG8gQmxpdHpNYXggV29ybGQh"
Local data:Byte[] = TBase64.Decode(encodedData)
Local decoded:String = String.FromUTF8String(data)
Print "Decoded : " + decoded
