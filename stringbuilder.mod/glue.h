/*
  Copyright (c) 2018-2020 Bruce A Henderson
  
  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.
  
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  
  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/ 
#ifndef _BRL_STRINGBUILDER_H_
#define _BRL_STRINGBUILDER_H_

#include "brl.mod/blitz.mod/blitz.h"
#include "brl.mod/blitz.mod/blitz_unicode.h"

struct MaxStringBuilder {
	BBChar * buffer;
	int count;
	int capacity;
	BBULONG hash;
};

struct MaxSplitBuffer {
	struct MaxStringBuilder * buffer;
	int count;
	int * startIndex;
	int * endIndex;
};

void bmx_stringbuilder_free(struct MaxStringBuilder * buf);
struct MaxStringBuilder * bmx_stringbuilder_new(int initial);
void bmx_stringbuilder_resize(struct MaxStringBuilder * buf, int size);
int bmx_stringbuilder_count(struct MaxStringBuilder * buf);
int bmx_stringbuilder_capacity(struct MaxStringBuilder * buf);
void bmx_stringbuilder_setlength(struct MaxStringBuilder * buf, int length);
BBString * bmx_stringbuilder_tostring(struct MaxStringBuilder * buf);
void bmx_stringbuilder_append_string(struct MaxStringBuilder * buf, BBString * value);
void bmx_stringbuilder_remove(struct MaxStringBuilder * buf, int start, int end);
void bmx_stringbuilder_insert(struct MaxStringBuilder * buf, int offset, BBString * value);
void bmx_stringbuilder_reverse(struct MaxStringBuilder * buf);
BBString * bmx_stringbuilder_substring(struct MaxStringBuilder * buf, int beginIndex, int endIndex);
void bmx_stringbuilder_append_stringbuffer(struct MaxStringBuilder * buf, struct MaxStringBuilder * other);
int bmx_stringbuilder_matches(struct MaxStringBuilder * buf, int offset, BBString * subString);
int bmx_stringbuilder_startswith(struct MaxStringBuilder * buf, BBString * subString);
int bmx_stringbuilder_endswith(struct MaxStringBuilder * buf, BBString * subString);
int bmx_stringbuilder_find(struct MaxStringBuilder * buf, BBString * subString, int startIndex);
int bmx_stringbuilder_findlast(struct MaxStringBuilder * buf, BBString * subString, int startIndex);
void bmx_stringbuilder_tolower(struct MaxStringBuilder * buf);
void bmx_stringbuilder_toupper(struct MaxStringBuilder * buf);
void bmx_stringbuilder_trim(struct MaxStringBuilder * buf);
void bmx_stringbuilder_replace(struct MaxStringBuilder * buf, BBString * subString, BBString *  withString);
void bmx_stringbuilder_join(struct MaxStringBuilder * buf, BBArray * bits, struct MaxStringBuilder * newbuf);
void bmx_stringbuilder_join_strings(struct MaxStringBuilder * buf, BBArray * bits, BBString * joiner);
struct MaxSplitBuffer * bmx_stringbuilder_split(struct MaxStringBuilder * buf, BBString * separator);
void bmx_stringbuilder_setcharat(struct MaxStringBuilder * buf, int index, int ch);
int bmx_stringbuilder_charat(struct MaxStringBuilder * buf, int index);
void bmx_stringbuilder_removecharat(struct MaxStringBuilder * buf, int index);
void bmx_stringbuilder_append_cstring(struct MaxStringBuilder * buf, const char * chars);
void bmx_stringbuilder_append_utf8string(struct MaxStringBuilder * buf, const char * chars);
void bmx_stringbuilder_append_double(struct MaxStringBuilder * buf, double value);
void bmx_stringbuilder_append_float(struct MaxStringBuilder * buf, float value);
void bmx_stringbuilder_append_int(struct MaxStringBuilder * buf, int value);
void bmx_stringbuilder_append_long(struct MaxStringBuilder * buf, BBInt64 value);
void bmx_stringbuilder_append_short(struct MaxStringBuilder * buf, BBSHORT value);
void bmx_stringbuilder_append_byte(struct MaxStringBuilder * buf, BBBYTE value);
void bmx_stringbuilder_append_uint(struct MaxStringBuilder * buf, unsigned int value);
void bmx_stringbuilder_append_ulong(struct MaxStringBuilder * buf, BBUInt64 value);
void bmx_stringbuilder_append_sizet(struct MaxStringBuilder * buf, BBSIZET value);
void bmx_stringbuilder_append_shorts(struct MaxStringBuilder * buf, BBSHORT * shorts, int length);
void bmx_stringbuilder_append_char(struct MaxStringBuilder * buf, int value);
BBString * bmx_stringbuilder_left(struct MaxStringBuilder * buf, int length);
BBString * bmx_stringbuilder_right(struct MaxStringBuilder * buf, int length);
int bmx_stringbuilder_compare(struct MaxStringBuilder * buf1, struct MaxStringBuilder * buf2);
int bmx_stringbuilder_equals(struct MaxStringBuilder * buf1, struct MaxStringBuilder * buf2);
void bmx_stringbuilder_leftalign(struct MaxStringBuilder * buf, int length);
void bmx_stringbuilder_rightalign(struct MaxStringBuilder * buf, int length);
char * bmx_stringbuilder_toutf8string(struct MaxStringBuilder * buf);
BBChar * bmx_stringbuilder_towstring(struct MaxStringBuilder * buf);
void bmx_stringbuilder_toutf8_buffer(BBString *str, char * buf, size_t length);
void bmx_stringbuilder_format_string(struct MaxStringBuilder * buf, BBString * formatText, BBString * value);
void bmx_stringbuilder_format_byte(struct MaxStringBuilder * buf, BBString * formatText, BBBYTE value);
void bmx_stringbuilder_format_short(struct MaxStringBuilder * buf, BBString * formatText, BBSHORT value);
void bmx_stringbuilder_format_int(struct MaxStringBuilder * buf, BBString * formatText, BBINT value);
void bmx_stringbuilder_format_uint(struct MaxStringBuilder * buf, BBString * formatText, BBUINT value);
void bmx_stringbuilder_format_long(struct MaxStringBuilder * buf, BBString * formatText, BBLONG value);
void bmx_stringbuilder_format_ulong(struct MaxStringBuilder * buf, BBString * formatText, BBULONG value);
void bmx_stringbuilder_format_sizet(struct MaxStringBuilder * buf, BBString * formatText, BBSIZET value);
void bmx_stringbuilder_format_float(struct MaxStringBuilder * buf, BBString * formatText, float value);
void bmx_stringbuilder_format_double(struct MaxStringBuilder * buf, BBString * formatText, double value);
BBULONG bmx_stringbuilder_hash(struct MaxStringBuilder * buf);

/* ----------------------------------------------------- */

int bmx_stringbuilder_splitbuffer_length(struct MaxSplitBuffer * buf);
BBString * bmx_stringbuilder_splitbuffer_text(struct MaxSplitBuffer * buf, int index);
void bmx_stringbuilder_splitbuffer_free(struct MaxSplitBuffer * buf);
BBArray * bmx_stringbuilder_splitbuffer_toarray(struct MaxSplitBuffer * buf);

#endif
