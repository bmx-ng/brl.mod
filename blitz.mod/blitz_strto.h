
#ifndef BLITZ_STRTO_H
#define BLITZ_STRTO_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

BBINT bbStrToInt(const BBChar *s, int length, int *end_index);
BBSHORT bbStrToShort(const BBChar *s, int length, int *end_index);
BBBYTE bbStrToByte(const BBChar *s, int length, int *end_index);
BBLONG bbStrToLong(const BBChar *s, int length, int *end_index);
BBUINT bbStrToUInt(const BBChar *s, int length, int *end_index);
BBULONG bbStrToULong(const BBChar *s, int length, int *end_index);
BBLONGINT bbStrToLongInt(const BBChar *s, int length, int *end_index);
BBULONGINT bbStrToULongInt(const BBChar *s, int length, int *end_index);
BBSIZET bbStrToSizet(const BBChar *s, int length, int *end_index);
BBFLOAT bbStrToFloat(const BBChar *s, int length, int *end_index);
BBDOUBLE bbStrToDouble(const BBChar *s, int length, int *end_index);

#ifdef __cplusplus
}
#endif

#endif
