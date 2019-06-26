SuperStrict

Framework brl.standardio
Import BRL.uuid

Local bytes:Byte[] = uuidGenerateBytes()
Print uuidToCanonical(bytes, False)
Print uuidToCanonical(bytes, True)
