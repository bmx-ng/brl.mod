
Object^Null{

	-New()="bbObjectCtor"
	-Delete()="bbObjectDtor"

	-ToString:String()="bbObjectToString"
	-Compare:Int( otherObject:Object )="bbObjectCompare"
	-SendMessage:Object( message:Object,source:object )="bbObjectSendMessage"
	
}="bbObjectClass"

String^Object{

	@length:Int

	-ToString:String()="bbStringToString"
	-Compare:Int(otherObject:Object)="bbStringCompare"
	
	-Find:Int( subString:String,startIndex=0 )="bbStringFind"
	-FindLast:Int( subString:String,startIndex=0 )="bbStringFindLast"
	
	-Trim:String()="bbStringTrim"
	-Replace:String( substring:String,withString:String )="bbStringReplace"

	-ToLower:String()="bbStringToLower"
	-ToUpper:String()="bbStringToUpper"
	
	-ToInt:Int()="bbStringToInt"
	-ToLong:Long()="bbStringToLong"
	-ToFloat:Float()="bbStringToFloat"
	-ToDouble:Double()="bbStringToDouble"
	-ToCString:Byte Ptr()="bbStringToCString"
	-ToWString:Short Ptr()="bbStringToWString"

	+FromInt:String( intValue:Int)="bbStringFromInt"
	+FromLong:String( longValue:Long )="bbStringFromLong"
	+FromFloat:String( floatValue:Float )="bbStringFromFloat"
	+FromDouble:String( doubleValue:Double )="bbStringFromDouble"
	+FromCString:String( cString:Byte Ptr )="bbStringFromCString"
	+FromWString:String( wString:Short ptr )="bbStringFromWString"
	
	+FromBytes:String( bytes:Byte Ptr,count )="bbStringFromBytes"
	+FromShorts:String( shorts:Short Ptr,count )="bbStringFromShorts"

	-StartsWith:Int( subString:String )="bbStringStartsWith"
	-EndsWith:Int( subString:String )="bbStringEndsWith"
	-Contains:Int( subString:String )="bbStringContains"
	
	-Split:String[]( separator:String )="bbStringSplit"
	-Join:String( bits:String[] )="bbStringJoin"
	
	+FromUTF8String:String( utf8String:Byte Ptr )="bbStringFromUTF8String"
	-ToUTF8String:Byte Ptr()="bbStringToUTF8String"
	+FromUTF8Bytes:String( utf8String:Byte Ptr, count )="bbStringFromUTF8Bytes"

	-ToSizet:size_t()="bbStringToSizet"
	+FromSizet:String( sizetValue:size_t )="bbStringFromSizet"

	-ToUInt:UInt()="bbStringToUInt"
	+FromUInt:String( uintValue:UInt )="bbStringFromUInt"
	-ToULong:ULong()="bbStringToULong"
	+FromULong:String( ulongValue:ULong )="bbStringFromULong"

	-ToWParam:WParam()="bbStringToWParam"
	+FromWParam:String( wparamValue:WParam )="bbStringFromWParam"
	-ToLParam:LParam()="bbStringToLParam"
	+FromLParam:String( lparamValue:LParam )="bbStringFromLParam"

	-ToUTF8StringBuffer:Byte Ptr(buf:Byte Ptr, length:Size_T Var)="bbStringToUTF8StringBuffer"
	-Hash:ULong()="bbStringHash"
		
}AF="bbStringClass"

___Array^Object{

	@elementTypeEncoding:Byte Ptr
	@numberOfDimensions:Int
	@sizeMinusHeader:Int
	@length:Int
	
	-Sort( ascending=1 )="bbArraySort"
	-Dimensions:Int[]()="bbArrayDimensions"
	
}AF="bbArrayClass"
