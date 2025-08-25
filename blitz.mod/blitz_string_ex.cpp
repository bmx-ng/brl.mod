/*
   Copyright 2024 Bruce A Henderson
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
*/
#include "fast_float/fast_float.h"
#include "blitz_debug.h"
#ifdef _WIN32
#if defined(_WIN64)
 typedef __int64 LONG_PTR; 
 typedef unsigned __int64 UINT_PTR;
#else
 typedef long LONG_PTR;
 typedef unsigned int UINT_PTR;
#endif
typedef UINT_PTR WPARAM;
typedef LONG_PTR LPARAM;
#endif
#include "blitz_string.h"

// extracts a double from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid double, or the position of the first character after the double otherwise
int bbStringToDoubleEx( BBString *str, double * val, int startPos, int endPos, BBULONG format, BBString* sep ) {
    return bbStrToDoubleEx( str->buf, str->length, val, startPos, endPos, format, sep );
}

int bbStrToDoubleEx( BBChar *buf, int length, double * val, int startPos, int endPos, BBULONG format, BBString* sep ) {
    if ( startPos < 0 || startPos >= length || endPos < -1 || endPos > length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = length;
    }
    const char16_t * start = (char16_t*)buf;
    const char16_t * end = start + length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    const char16_t sepChar = sep->length > 0 ? sep->buf[0] : '.';
    double result;

    if ( sepChar != 0 && sepChar != '.' ) {
        fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), sepChar};
        fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
        if (res.ptr != nullptr) {
            *val = result;
            return res.ptr - start;
        }
    }
    else {
        fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars(p, e, result, static_cast<fast_float::chars_format>(format));
        if (res.ptr != nullptr) {
            *val = result;
            return res.ptr - start;
        }
    }
    return 0;
}

// extracts a float from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid float, or the position of the first character after the float otherwise
int bbStringToFloatEx( BBString *str, float * val, int startPos, int endPos, BBULONG format, BBString* sep ) {
    return bbStrToFloatEx( str->buf, str->length, val, startPos, endPos, format, sep );
}

int bbStrToFloatEx( BBChar *buf, int length, float * val, int startPos, int endPos, BBULONG format, BBString* sep ) {
    if ( startPos < 0 || startPos >= length || endPos < -1 || endPos > length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = length;
    }
    const char16_t * start = (char16_t*)buf;
    const char16_t * end = start + length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    const char16_t sepChar = sep->length > 0 ? sep->buf[0] : '.';
    float result;

    if ( sepChar != 0 && sepChar != '.' ) {
        fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), sepChar};
        fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
        if (res.ptr != nullptr) {
            *val = result;
            return res.ptr - start;
        }
    }
    else {
        fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars(p, e, result, static_cast<fast_float::chars_format>(format));
        if (res.ptr != nullptr) {
            *val = result;
            return res.ptr - start;
        }
    }
    return 0;
}

// extracts a int from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid int, or the position of the first character after the int otherwise
int bbStringToIntEx( BBString *str, int * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    int result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a UInt from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid UInt, or the position of the first character after the UInt otherwise
int bbStringToUIntEx( BBString *str, unsigned int * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    unsigned int result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a Long from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid Long, or the position of the first character after the Long otherwise
int bbStringToLongEx( BBString *str, BBInt64 * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    BBInt64 result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a ULong from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid ULong, or the position of the first character after the ULong otherwise
int bbStringToULongEx( BBString *str, BBUInt64 * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    BBUInt64 result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a Size_T from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid Size_T, or the position of the first character after the Size_T otherwise
int bbStringToSizeTEx( BBString *str, BBSIZET * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    BBSIZET result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a LongInt from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns -1 if the string is not a valid LongInt, or the position of the first character after the LongInt otherwise
int bbStringToLongIntEx( BBString *str, BBLONGINT * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    BBLONGINT result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}

// extracts a ULongInt from a string, from the range startPos to endPos
// endPos of -1 means the end of the string
// returns 0 if the string is not a valid ULongInt, or the position of the first character after the ULongInt otherwise
int bbStringToULongIntEx( BBString *str, BBULONGINT * val, int startPos, int endPos, BBULONG format, int base ) {
    if ( startPos < 0 || startPos >= str->length || endPos < -1 || endPos > str->length ) {
        return 0;
    }
    if (endPos == -1) {
        endPos = str->length;
    }
    const char16_t * start = (char16_t*)str->buf;
    const char16_t * end = start + str->length;
    const char16_t * p = start + startPos;
    const char16_t * e = start + endPos;
    BBULONGINT result;

    fast_float::parse_options_t<char16_t> options{static_cast<fast_float::chars_format>(format), '.', base};
    fast_float::from_chars_result_t<char16_t> res = fast_float::from_chars_advanced(p, e, result, options);
    if (res.ptr != nullptr) {
        *val = result;
        return res.ptr - start;
    }
    return 0;
}
