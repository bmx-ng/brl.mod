
#ifndef BLITZ_STRINGSPLIT_H
#define BLITZ_STRINGSPLIT_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

BBArray *bbStringSplitInts( BBString *str, BBString *sep );
BBArray *bbStringSplitBytes( BBString *str, BBString *sep );
BBArray *bbStringSplitShorts( BBString *str, BBString *sep );
BBArray *bbStringSplitUInts( BBString *str, BBString *sep );
BBArray *bbStringSplitLongs( BBString *str, BBString *sep );
BBArray *bbStringSplitULongs( BBString *str, BBString *sep );
BBArray *bbStringSplitSizets( BBString *str, BBString *sep );
BBArray *bbStringSplitLongInts( BBString *str, BBString *sep );
BBArray *bbStringSplitULongInts( BBString *str, BBString *sep );
BBArray *bbStringSplitFloats( BBString *str, BBString *sep );
BBArray *bbStringSplitDoubles( BBString *str, BBString *sep );

BBArray *bbStrSplitInts( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitBytes( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitShorts( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitUInts( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitLongs( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitULongs( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitSizets( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitLongInts( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitULongInts( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitFloats( BBChar *str, int strLength, BBChar * sep, int sepLength );
BBArray *bbStrSplitDoubles( BBChar *str, int strLength, BBChar * sep, int sepLength );

#ifdef __cplusplus
}
#endif

#endif
