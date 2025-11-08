
Object^Null{

	-New()="bbObjectCtor"
	-Delete()="bbObjectDtor"

	-ToString:String()="bbObjectToString"
	-Compare:Int( otherObject:Object )="bbObjectCompare"
	-SendMessage:Object( message:Object,source:object )="bbObjectSendMessage"
	-HashCode:UInt()="bbObjectHashCode"
	
}="bbObjectClass"

String^Object{

	@length:Int

	-ToString:String()="bbStringToString"
	-Compare:Int(otherString:String)="bbStringCompare"
	-HashCode:UInt()="bbStringHash"
	
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
	+FromFloat:String( floatValue:Float, fixed:Int=0 )="bbStringFromFloat"
	+FromDouble:String( doubleValue:Double, fixed:Int=0 )="bbStringFromDouble"
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
	
	-ToUTF8StringBuffer:Byte Ptr(buf:Byte Ptr, length:Size_T Var)="bbStringToUTF8StringBuffer"
	-ToUTF8String:Byte Ptr(length:Size_T Var)="bbStringToUTF8StringLen"

	-ToUTF32String:UInt Ptr()="bbStringToUTF32String"
	+FromUTF32String:String( utf32String:UInt Ptr )="bbStringFromUTF32String"
	+FromUTF32Bytes:String( utf32String:UInt Ptr, count:Size_T )="bbStringFromUTF32Bytes"

	-ToWStringBuffer:Short Ptr(buf:Short Ptr, length:Size_T Var)="bbStringToWStringBuffer"

	-ToLongInt:LongInt()="bbStringToLongInt"
	+FromLongInt:String( longIntValue:LongInt )="bbStringFromLongInt"
	-ToULongInt:ULongInt()="bbStringToULongInt"
	+FromULongInt:String( ulongIntValue:ULongInt )="bbStringFromULongInt"

	-ToDoubleEx:Int( val:Double Var,startPos:Int=0,endPos:Int=-1,format:Int=5,sep:String="." )="bbStringToDoubleEx"
	-ToFloatEx:Int( val:Float Var,startPos:Int=0,endPos:Int=-1,format:Int=5,sep:String="." )="bbStringToFloatEx"
	-ToIntEx:Int( val:Int Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToIntEx"
	-ToUIntEx:Int( val:UInt Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToUIntEx"
	-ToLongEx:Int( val:Long Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToLongEx"
	-ToULongEx:Int( val:ULong Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToULongEx"
	-ToSizeTEx:Int( val:Size_T Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToSizeTEx"
	-ToLongIntEx:Int( val:LongInt Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToLongIntEx"
	-ToULongIntEx:Int( val:ULongInt Var,startPos:Int=0,endPos:Int=-1,format:Int=5,base:Int=10 )="bbStringToULongIntEx"

	+FromBytesAsHex:String( buf:Byte Ptr, length:Int, upperCase:Int=1 )="bbStringFromBytesAsHex"
	-Compare:Int(otherString:String, caseSensitive:Int)="bbStringCompareCase"
}AF="bbStringClass"

___Array^Object{

	@elementTypeEncoding:Byte Ptr
	@numberOfDimensions:Int
	@sizeMinusHeader:Int
	@length:Int
	
	-Sort( ascending=1 )="bbArraySort"
	-Dimensions:Int[]()="bbArrayDimensions"
	
}AF="bbArrayClass"
