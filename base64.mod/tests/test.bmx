SuperStrict

Framework brl.standardio
Import BRL.Base64
Import BRL.MaxUnit

New TTestSuite.run()

Type TBase64Test Extends TTest

	Method testStringEncodeWithoutPadding() { test }
		Local text:String = "The quick brown fox jumps over the lazy"
		Local encoded:String = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5"
	
		Local result:String = TBase64.Encode(text)
	
		AssertEquals(encoded, result)
	End Method
	
	Method testStringEncodeWithSinglePadding() { test }
		Local text:String = "The quick brown fox jumps over the lazy d"
		Local encoded:String = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGQ="
	
		Local result:String = TBase64.Encode(text)
	
		AssertEquals(encoded, result)
	End Method
	
	Method testStringEncodeWithDoublePadding() { test }
		Local text:String = "The quick brown fox jumps over the lazy dog"
		Local encoded:String = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw=="
	
		Local result:String = TBase64.Encode(text)
	
		AssertEquals(encoded, result)
	End Method
	
	Method testStringEncodeDontBreakLines() { test }
		Local text:String = "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog."
		Local encoded:String = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gVGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4="
	
		Local result:String = TBase64.Encode(text, EBase64Options.DontBreakLines)
	
		AssertEquals(encoded, result)
	End Method

	Method testStringEncodeWithLineBreaks() { test }
		Local text:String = "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog."
		Local encoded:String = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gVGhlIHF1aWNrIGJy~nb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gVGhlIHF1aWNrIGJyb3duIGZveCBqdW1w~ncyBvdmVyIHRoZSBsYXp5IGRvZy4gVGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBs~nYXp5IGRvZy4="
	
		Local result:String = TBase64.Encode(text)
	
		AssertEquals(encoded, result)
	End Method
End Type
