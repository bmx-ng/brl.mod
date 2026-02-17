/*
  Copyright (c) 2018-2026 Bruce A Henderson
  
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

#include "glue.h"
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include "ryu/ryu.h"

static int utf32strlen( const BBUINT *p ){
	const BBUINT *t=p;
	while( *t ) ++t;
	return t-p;
}

void bmx_stringbuilder_free(struct MaxStringBuilder * buf) {
	free(buf->buffer);
	free(buf);
}

struct MaxStringBuilder * bmx_stringbuilder_new(int initial) {
	struct MaxStringBuilder * buf = malloc(sizeof(struct MaxStringBuilder));
	
	buf->count = 0;
	buf->capacity = initial;
	buf->buffer = malloc(initial * sizeof(BBChar));
	buf->hash = 0;
	
	return buf;
}

/* make more capacity if requested size greater */
void bmx_stringbuilder_resize(struct MaxStringBuilder * buf, int size) {
	if (buf->capacity < size) {
		
		if (buf->capacity * 2  > size) {
			size = buf->capacity * 2;
		}
		BBChar * newBuffer = (BBChar *)malloc(size * sizeof(BBChar));
		
		/* copy text to new buffer */
		memcpy(newBuffer, buf->buffer, buf->count * sizeof(BBChar));
		
		/* free old buffer */
		free(buf->buffer);
		
		buf->buffer = newBuffer;
		buf->capacity = size;
		buf->hash = 0;
	}
}

int bmx_stringbuilder_count(struct MaxStringBuilder * buf) {
	return buf->count;
}

int bmx_stringbuilder_capacity(struct MaxStringBuilder * buf) {
	return buf->capacity;
}


void bmx_stringbuilder_setlength(struct MaxStringBuilder * buf, int length) {
	bmx_stringbuilder_resize(buf, length);
	if (length < buf->count) {
		buf->count = length;
		buf->hash = 0;
	}
}

BBString * bmx_stringbuilder_tostring(struct MaxStringBuilder * buf) {
	if (!buf->count) {
		return &bbEmptyString;
	} else {
		return bbStringFromShorts(buf->buffer, buf->count);
	}
}

void bmx_stringbuilder_append_string(struct MaxStringBuilder * buf, BBString * value) {
	if (value != &bbEmptyString) {
		bmx_stringbuilder_resize(buf, buf->count + value->length);
		BBChar * p = buf->buffer + buf->count;
		memcpy(p, value->buf, value->length * sizeof(BBChar));
		
		buf->count += value->length;
		buf->hash = 0;
	}	
}

void bmx_stringbuilder_remove(struct MaxStringBuilder * buf, int start, int end) {
	if (start < 0 || start > buf->count || start > end) {
		return;
	}
	
	/* trim end if it is too big */
	if (end > buf->count) {
		end = buf->count;
	}
	
	/* still something to remove ? */
	if (buf->count - end != 0) {
		memcpy(buf->buffer + start, buf->buffer + end, (buf->count - end) * sizeof(BBChar));
	}
	
	buf->count -= end - start;
	buf->hash = 0;
}

void bmx_stringbuilder_insert(struct MaxStringBuilder * buf, int offset, BBString * value) {
	if (value != &bbEmptyString) {
		if (offset < 0 || offset > buf->count) {
			return;
		}
		
		int length = value->length;
		bmx_stringbuilder_resize(buf, buf->count + length);

		/* make some space for the insertion */
		/* using memmove because data overlaps */
		memmove(buf->buffer + offset + length, buf->buffer + offset, (buf->count - offset) * sizeof(BBChar));
		
		/* insert the string */
		memcpy(buf->buffer + offset, value->buf, length * sizeof(BBChar));
		
		buf->count += length;
		buf->hash = 0;
	}
}

void bmx_stringbuilder_reverse(struct MaxStringBuilder * buf) {
	int i = buf->count >> 1;
	int n = buf->count - i;
	while (--i >= 0) {
		BBChar c = buf->buffer[i];
		buf->buffer[i] = buf->buffer[n];
		buf->buffer[n] = c;
		n++;
	}
	buf->hash = 0;
}

BBString * bmx_stringbuilder_substring(struct MaxStringBuilder * buf, int beginIndex, int endIndex) {
	if (!endIndex) {
		endIndex = buf->count;
	}
	
	if (beginIndex < 0 || endIndex > buf->count || endIndex < beginIndex) {
		return &bbEmptyString;
	}
	
	return bbStringFromShorts(buf->buffer + beginIndex, endIndex - beginIndex);
}

void bmx_stringbuilder_append_stringbuffer(struct MaxStringBuilder * buf, struct MaxStringBuilder * other) {
	if (other->count > 0) {
		bmx_stringbuilder_resize(buf, buf->count + other->count);
	
		memcpy(buf->buffer + buf->count, other->buffer, other->count * sizeof(BBChar));
	
		buf->count += other->count;
		buf->hash = 0;
	}
}

int bmx_stringbuilder_matches(struct MaxStringBuilder * buf, int offset, BBString * subString) {
	int length = subString->length;
	int index = 0;
	while (--length >= 0) {
		if (buf->buffer[offset++] != subString->buf[index++]) {
			return 0;
		}
	}
	return 1;
}

int bmx_stringbuilder_startswith(struct MaxStringBuilder * buf, BBString * subString, int startIndex) {
	if (startIndex < 0) {
		startIndex = 0;
	}

	if ((startIndex + subString->length) <= buf->count) {
		return bmx_stringbuilder_matches(buf, startIndex, subString);
	}
	return 0;
}

int bmx_stringbuilder_endswith(struct MaxStringBuilder * buf, BBString * subString) {
	if (subString->length <= buf->count) {
		return bmx_stringbuilder_matches(buf, buf->count - subString->length, subString);
	}
	return 0;
}

int bmx_stringbuilder_find(struct MaxStringBuilder * buf, BBString * subString, int startIndex) {
	if (startIndex < 0) {
		startIndex = 0;
	}
	
	int limit = buf->count - subString->length;
	while (startIndex <= limit) {
		if (bmx_stringbuilder_matches(buf, startIndex, subString)) {
			return startIndex;
		}
		startIndex++;
	}
	return -1;
}

int bmx_stringbuilder_findlast(struct MaxStringBuilder * buf, BBString * subString, int startIndex) {
	if (startIndex < 0) {
		startIndex = 0;
	}
	
	startIndex = buf->count - startIndex;

	if (startIndex + subString->length > buf->count) {
		startIndex = buf->count - subString->length;
	}
	
	while (startIndex >= 0) {
		if (bmx_stringbuilder_matches(buf, startIndex, subString)) {
			return startIndex;
		}
		startIndex--;
	}
	return -1;
}

void bmx_stringbuilder_tolower(struct MaxStringBuilder * buf) {
	int i;
	for (i = 0; i < buf->count; i++ ) {
		int c = buf->buffer[i];
		if (c < 192) {
			c = ( c >= 'A' && c <= 'Z') ? (c|32) : c;
		} else {
			int lo = 0, hi = 3828 / 4 - 1;
			while (lo <= hi) {
				int mid = (lo+hi)/2;
				if (c < bbToLowerData[mid*2]) {
					hi = mid-1;
				} else if (c > bbToLowerData[mid*2]) {
					lo = mid + 1;
				} else {
					c = bbToLowerData[mid*2+1];
					break;
				}
			}
		}
		buf->buffer[i]=c;
	}
	buf->hash = 0;
}

void bmx_stringbuilder_toupper(struct MaxStringBuilder * buf) {
	int i;
	for (i = 0; i < buf->count; i++) {
		int c = buf->buffer[i];
		if (c < 181) {
			c = (c >= 'a' && c <= 'z') ? (c&~32) : c;
		} else {
			int lo = 0, hi = 3860/4-1;
			while (lo<=hi) {
				int mid=(lo+hi)/2;
				if (c < bbToUpperData[mid*2]) {
					hi = mid - 1;
				} else if (c > bbToUpperData[mid*2]) {
					lo = mid + 1;
				} else {
					c = bbToUpperData[mid*2+1];
					break;
				}
			}
		}
		buf->buffer[i]=c;
	}
	buf->hash = 0;
}

void bmx_stringbuilder_trim(struct MaxStringBuilder * buf) {
	int start = 0;
	int end = buf->count;
	while (start < end && buf->buffer[start] <= ' ') {
		++start;
	}
	if (start == end ) {
		buf->count = 0;
		buf->hash = 0;
		return;
	}
	while (buf->buffer[end - 1] <= ' ') {
		--end;
	}
	if (end - start == buf->count) {
		return;
	}

	memmove(buf->buffer, buf->buffer + start, (end - start) * sizeof(BBChar));
	buf->count = end - start;	
	buf->hash = 0;
}

void bmx_stringbuilder_replace(struct MaxStringBuilder * buf, BBString * subString, BBString *  withString) {
	if (!subString->length) {
		return;
	}
	
	struct MaxStringBuilder * newbuf = bmx_stringbuilder_new(16);
	
	int j, n;
	int i = 0;
	int p = 0;
	
	while( (j = bmx_stringbuilder_find(buf, subString, i)) != -1) {
		n = j - i;
		if (n) {
			bmx_stringbuilder_resize(newbuf, newbuf->count + n);
			memcpy(newbuf->buffer + p, buf->buffer + i, n * sizeof(BBChar));
			newbuf->count += n;
			p += n;
		}
		n = withString->length;
		bmx_stringbuilder_resize(newbuf, newbuf->count + n);
		memcpy(newbuf->buffer + p, withString->buf, n * sizeof(BBChar));
		newbuf->count += n;
		p += n;
		i = j + subString->length;
	}

	n = buf->count - i;
	if (n) {
		bmx_stringbuilder_resize(newbuf, newbuf->count + n);
		memcpy(newbuf->buffer + p, buf->buffer + i, n*sizeof(BBChar));
		newbuf->count += n;
	}

	bmx_stringbuilder_setlength(buf, 0);
	bmx_stringbuilder_append_stringbuffer(buf, newbuf);
	bmx_stringbuilder_free(newbuf);
}

void bmx_stringbuilder_join(struct MaxStringBuilder * buf, BBArray * bits, struct MaxStringBuilder * newbuf) {
	if(bits == &bbEmptyArray) {
		return;
	}

	int i;
	int n_bits = bits->scales[0];
	BBString **p = (BBString**)BBARRAYDATA( bits,1 );
	for(i = 0; i < n_bits; ++i) {
		if (i) {
			bmx_stringbuilder_append_stringbuffer(newbuf, buf);
		}
		BBString *bit = *p++;
		bmx_stringbuilder_append_string(newbuf, bit);
	}
}

void bmx_stringbuilder_join_strings(struct MaxStringBuilder * buf, BBArray * bits, BBString * joiner) {
	if (bits == &bbEmptyArray) {
		return;
	}

	int i;
	int n_bits = bits->scales[0];
	int n = joiner->length;
	BBString **p = (BBString**)BBARRAYDATA( bits,1 );
	for(i = 0; i < n_bits; ++i) {
		if (i && n) {
			bmx_stringbuilder_append_string(buf, joiner);
		}
		bmx_stringbuilder_append_string(buf, *p++);
	}
}

struct MaxSplitBuffer * bmx_stringbuilder_split(struct MaxStringBuilder * buf, BBString * separator) {
	struct MaxSplitBuffer * splitBuffer = malloc(sizeof(struct MaxSplitBuffer));
	splitBuffer->buffer = buf;
	
	int count = 1;
	int i = 0;
	int offset = 0;
	if (separator->length > 0) {
	
		/* get a count of fields */
		while ((offset = bmx_stringbuilder_find(buf, separator, i)) != -1 ) {
			++count;
			i = offset + separator->length;
		}

		splitBuffer->count = count;
		splitBuffer->startIndex = malloc(count * sizeof(int));
		splitBuffer->endIndex = malloc(count * sizeof(int));

		i = 0;
		
		int * bufferStartIndex = splitBuffer->startIndex;
		int * bufferEndIndex = splitBuffer->endIndex;
		
		while( count-- ){
			offset = bmx_stringbuilder_find(buf, separator, i);
			if (offset == -1) {
				offset = buf->count;
			}
			
			*bufferStartIndex++ = i;
			*bufferEndIndex++ = offset;

			i = offset + separator->length;
		}

	} else {
		// TODO - properly handle Null separator
		
		splitBuffer->count = count;
		splitBuffer->startIndex = malloc(count * sizeof(int));
		splitBuffer->endIndex = malloc(count * sizeof(int));
		
		*splitBuffer->startIndex = 0;
		*splitBuffer->endIndex = buf->count;

	}
	
	return splitBuffer;
}

void bmx_stringbuilder_setcharat(struct MaxStringBuilder * buf, int index, int ch) {
	if (index < 0 || index > buf->count) {
		return;
	}

	buf->buffer[index] = ch;
	buf->hash = 0;
}

int bmx_stringbuilder_charat(struct MaxStringBuilder * buf, int index) {
	if (index < 0 || index > buf->count) {
		return 0;
	}

	return buf->buffer[index];
}

void bmx_stringbuilder_removecharat(struct MaxStringBuilder * buf, int index) {
	if (index < 0 || index >= buf->count) {
		return;
	}

	if (index < buf->count - 1) {
		memcpy(buf->buffer + index, buf->buffer + index + 1, (buf->count - index - 1) * sizeof(BBChar));
	}
	
	buf->count--;
	buf->hash = 0;
}

void bmx_stringbuilder_append_cstring(struct MaxStringBuilder * buf, const char * chars) {
	if (!chars) {
		return;
	}
	int length = strlen(chars);
	bmx_stringbuilder_append_cstringbytes(buf, chars, length);
}

void bmx_stringbuilder_append_cstringbytes(struct MaxStringBuilder * buf, const char * chars, int length) {
	if (length > 0) {
		int count = length;
		
		bmx_stringbuilder_resize(buf, buf->count + length);
		
		const char * p = chars;
		BBChar * b = buf->buffer + buf->count;
		while (length--) {
			*b++ = *p++;
		}
		
		buf->count += count;
		buf->hash = 0;
	}
}

void bmx_stringbuilder_append_utf8string(struct MaxStringBuilder * buf, const char * chars) {
	if (!chars) {
		return;
	}
	int length = strlen(chars);
	bmx_stringbuilder_append_utf8bytes(buf, chars, length);
}

void bmx_stringbuilder_append_utf8bytes(struct MaxStringBuilder * buf, const char * chars, int length) {
	if (length > 0) {
		int count = 0;
		
		bmx_stringbuilder_resize(buf, buf->count + length);
		
		char * p = chars;
		BBChar * b = buf->buffer + buf->count;
		
		while( length-- ){
			int c=*p++ & 0xff;
			if( c<0x80 ){
				*b++=c;
			}else{
				if (!length--) break;
				int d=*p++ & 0x3f;
				if( c<0xe0 ){
					*b++=((c&31)<<6) | d;
				}else{
					if (!length--) break;
					int e=*p++ & 0x3f;
					if( c<0xf0 ){
						*b++=((c&15)<<12) | (d<<6) | e;
					}else{
						if (!length--) break;
						int f=*p++ & 0x3f;
						int v=((c&7)<<18) | (d<<12) | (e<<6) | f;
						if( v & 0xffff0000 ) bbExThrowCString( "Unicode character out of UCS-2 range" );
						*b++=v;
					}
				}
			}
			count++;
		}

		buf->count += count;
		buf->hash = 0;
	}
}

void bmx_stringbuilder_append_float(struct MaxStringBuilder *buf, float value, int fixed){
	char tmp[64];
	int len = fixed ? d2fixed_buffered_n((double)value, 9, tmp) : f2s_buffered_expand_n(value, tmp);
	if( len <= 0 ) return;

	bmx_stringbuilder_append_cstringbytes(buf, tmp, len);
}

void bmx_stringbuilder_append_double(struct MaxStringBuilder *buf, double value, int fixed){
	char tmp[64];
	int len = fixed ? d2fixed_buffered_n(value, 17, tmp) : d2s_buffered_expand_n(value, tmp);
	if( len <= 0 ) return;

	bmx_stringbuilder_append_cstringbytes(buf, tmp, len);
}

void bmx_stringbuilder_append_int(struct MaxStringBuilder *buf, int value) {

	/* Fast path: 0 */
	if( value == 0 ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	int neg = (value < 0);
	uint32_t mag = neg ? (uint32_t)(-(int64_t)value) : (uint32_t)value;

	int dlen = bbU32DecLen(mag);
	int add  = dlen + (neg ? 1 : 0);

	/* Ensure capacity once */
	bmx_stringbuilder_resize(buf, buf->count + add);

	BBChar *t = buf->buffer + buf->count;
	if( neg ) *t++ = (BBChar)'-';

	BBChar *end = t + dlen;
	(void)bbWriteU32DecBackwards(end, mag);

	buf->count += add;
	buf->hash = 0;
}

void bmx_stringbuilder_append_long(struct MaxStringBuilder *buf, BBInt64 value) {

	if( value == 0 ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	int neg = (value < 0);
	uint64_t mag = neg ? (uint64_t)(-(int64_t)value) : (uint64_t)value;

	int dlen = bbU64DecLen(mag);
	int add  = dlen + (neg ? 1 : 0);

	bmx_stringbuilder_resize(buf, buf->count + add);

	BBChar *t = buf->buffer + buf->count;
	if( neg ) *t++ = (BBChar)'-';

	BBChar *end = t + dlen;
	(void)bbWriteU64DecBackwards(end, mag);

	buf->count += add;
	buf->hash = 0;
}

void bmx_stringbuilder_append_short(struct MaxStringBuilder *buf, BBSHORT value) {

	uint32_t v = (uint32_t)value;

	if( v == 0u ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	int dlen = bbU32DecLen(v);
	bmx_stringbuilder_resize(buf, buf->count + dlen);

	BBChar *end = buf->buffer + buf->count + dlen;
	(void)bbWriteU32DecBackwards(end, v);

	buf->count += dlen;
	buf->hash = 0;
}

void bmx_stringbuilder_append_byte(struct MaxStringBuilder *buf, BBBYTE value) {

	uint32_t v = (uint32_t)value;

	if( v == 0u ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	int dlen = bbU32DecLen(v);
	bmx_stringbuilder_resize(buf, buf->count + dlen);

	BBChar *end = buf->buffer + buf->count + dlen;
	(void)bbWriteU32DecBackwards(end, v);

	buf->count += dlen;
	buf->hash = 0;
}

void bmx_stringbuilder_append_uint(struct MaxStringBuilder *buf, unsigned int value) {

	if( value == 0u ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	uint32_t mag = (uint32_t)value;
	int dlen = bbU32DecLen(mag);

	bmx_stringbuilder_resize(buf, buf->count + dlen);

	BBChar *end = buf->buffer + buf->count + dlen;
	(void)bbWriteU32DecBackwards(end, mag);

	buf->count += dlen;
	buf->hash = 0;
}

void bmx_stringbuilder_append_ulong(struct MaxStringBuilder *buf, BBUInt64 value) {

	if( value == 0ull ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	uint64_t mag = (uint64_t)value;
	int dlen = bbU64DecLen(mag);

	bmx_stringbuilder_resize(buf, buf->count + dlen);

	BBChar *end = buf->buffer + buf->count + dlen;
	(void)bbWriteU64DecBackwards(end, mag);

	buf->count += dlen;
	buf->hash = 0;
}

void bmx_stringbuilder_append_sizet(struct MaxStringBuilder *buf, BBSIZET value) {

	uint64_t v = (uint64_t)value;

	if( v == 0ull ){
		bmx_stringbuilder_resize(buf, buf->count + 1);
		buf->buffer[buf->count++] = (BBChar)'0';
		buf->hash = 0;
		return;
	}

	int dlen = bbU64DecLen(v);
	bmx_stringbuilder_resize(buf, buf->count + dlen);

	BBChar *end = buf->buffer + buf->count + dlen;
	(void)bbWriteU64DecBackwards(end, v);

	buf->count += dlen;
	buf->hash = 0;
}

void bmx_stringbuilder_append_shorts(struct MaxStringBuilder * buf, BBSHORT * shorts, int length) {
	if (length > 0) {
		bmx_stringbuilder_resize(buf, buf->count + length);
		BBChar * p = buf->buffer + buf->count;
		memcpy(p, shorts, length * sizeof(BBChar));
		
		buf->count += length;
		buf->hash = 0;
	}	
}

void bmx_stringbuilder_append_char(struct MaxStringBuilder * buf, int value) {
	bmx_stringbuilder_resize(buf, buf->count + 1);
	BBChar * p = buf->buffer + buf->count;
	*p = (BBChar)value;
	buf->count++;
	buf->hash = 0;
}

BBString * bmx_stringbuilder_left(struct MaxStringBuilder * buf, int length) {
	if (length <= 0) {
		return &bbEmptyString;
	} else if (length >= buf->count) {
		return bbStringFromShorts(buf->buffer, buf->count);
	} else {
		return bbStringFromShorts(buf->buffer, length);
	}
}

BBString * bmx_stringbuilder_right(struct MaxStringBuilder * buf, int length) {
	if (length <= 0) {
		return &bbEmptyString;
	} else if (length >= buf->count) {
		return bbStringFromShorts(buf->buffer, buf->count);
	} else {
		return bbStringFromShorts(buf->buffer + (buf->count - length), length);
	}
}

int bmx_stringbuilder_compare(struct MaxStringBuilder * buf1, struct MaxStringBuilder * buf2) {
	if (buf1 == buf2) {
		return 0;
	}
	
	int c = buf1->count < buf2->count ? buf1->count : buf2->count;
	int n = 0;
	int i;
	for (i=0; i < c; ++i) {
		if ((n = buf1->buffer[i] - buf2->buffer[i])) {
			return n;
		}
	}
	return buf1->count - buf2->count;
}

int bmx_stringbuilder_equals(struct MaxStringBuilder * buf1, struct MaxStringBuilder * buf2) {
	if (buf1 == buf2) {
		return 1;
	}
	if (buf1->count-buf2->count != 0) return 0;
	if (buf1->hash != 0 && buf2->hash != 0 && buf1->hash != buf2->hash) return 0;
	return memcmp(buf1->buffer, buf2->buffer, buf1->count * sizeof(BBChar)) == 0;
}

void bmx_stringbuilder_leftalign(struct MaxStringBuilder * buf, int length) {
	if (length == buf->count) {
		return;
	} else if (length > buf->count) {
		bmx_stringbuilder_resize(buf, length);

		int c = length - buf->count;

		BBChar * p = buf->buffer + buf->count;
		int i;
		for (i=0; i < c; ++i) {
			*p++ = (BBChar)' ';
		}
	}
	
	buf->count = length;
	buf->hash = 0;
}

void bmx_stringbuilder_rightalign(struct MaxStringBuilder * buf, int length) {
	if (length == buf->count) {
		return;
	} else if (length < buf->count) {
		int offset = buf->count - length;
		memmove(buf->buffer, buf->buffer + offset, buf->count * sizeof(BBChar));
	} else {
		bmx_stringbuilder_resize(buf, length);

		int offset = length - buf->count;
		
		if (offset == 0) {
			return;
		}
		
		memmove(buf->buffer + offset, buf->buffer, buf->count * sizeof(BBChar));

		BBChar * p = buf->buffer;
		int i;
		for (i=0; i < offset; ++i) {
			*p++ = (BBChar)' ';
		}
	}

	buf->count = length;
	buf->hash = 0;
}

char * bmx_stringbuilder_toutf8string(struct MaxStringBuilder * buf) {
	int i = 0;
	int count = buf->count;
	if (count == 0) {
		return NULL;
	}
	char *ubuf = (char*)bbMemAlloc( count * 4 + 1 );
	char *q = ubuf;
	unsigned short *p = buf->buffer;
	while (i < count) {
		unsigned int c=*p++;
		if (0xd800 <= c && c <= 0xdbff && i < count - 1) {
			/* surrogate pair */
			unsigned int c2 = *p;
			if(0xdc00 <= c2 && c2 <= 0xdfff) {
				/* valid second surrogate */
				c = ((c - 0xd800) << 10) + (c2 - 0xdc00) + 0x10000;
				++p;
				++i;
			}
		}
		if (c < 0x80) {
			*q++ = c;
		} else if (c < 0x800){
			*q++ = 0xc0 | (c >> 6);
			*q++ = 0x80 | (c & 0x3f);
		} else if (c < 0x10000) { 
			*q++ = 0xe0 | (c >> 12);
			*q++ = 0x80 | ((c >> 6) & 0x3f);
			*q++ = 0x80 | (c & 0x3f);
		} else if (c <= 0x10ffff) {
			*q++ = 0xf0 | (c >> 18);
			*q++ = 0x80 | ((c >> 12) & 0x3f);
			*q++ = 0x80 | ((c >> 6) & 0x3f);
			*q++ = 0x80 | ((c & 0x3f));
		} else {
			bbExThrowCString( "Unicode character out of UTF-8 range" );
		}
		++i;
	}
	*q=0;
	return ubuf;
}

BBChar * bmx_stringbuilder_towstring(struct MaxStringBuilder * buf) {
	int count = buf->count;
	if (count == 0) {
		return NULL;
	}
	BBChar *p = (BBChar*)bbMemAlloc((count + 1) * sizeof(BBChar));
	memcpy(p, buf->buffer, count * sizeof(BBChar));
	p[count] = 0;
	return p;
}

void bmx_stringbuilder_toutf8_buffer(BBString *str, char * buf, size_t length) {
	int i=0,len=str->length;
	int out=0;
	char *q=buf;
	unsigned short *p=str->buf;
	while (i < len && out < length) {
		unsigned int c=*p++;
		if(0xd800 <= c && c <= 0xdbff && i < len - 1) {
			/* surrogate pair */
			unsigned int c2 = *p;
			if(0xdc00 <= c2 && c2 <= 0xdfff) {
				/* valid second surrogate */
				c = ((c - 0xd800) << 10) + (c2 - 0xdc00) + 0x10000;
				++p;
				++i;
			}
		}
		if( c<0x80 ){
			*q++=c;
			out++;
		}else if( c<0x800 ){
			if (out > length - 2) {
				break;
			}
			*q++=0xc0|(c>>6);
			*q++=0x80|(c&0x3f);
			out += 2;
		}else if(c < 0x10000) { 
			if (out > length - 3) {
				break;
			}
			*q++=0xe0|(c>>12);
			*q++=0x80|((c>>6)&0x3f);
			*q++=0x80|(c&0x3f);
			out += 3;
		}else if(c <= 0x10ffff) {
			if (out > length - 4) {
				break;
			}
			*q++ = 0xf0|(c>>18);
			*q++ = 0x80|((c>>12)&0x3f);
			*q++ = 0x80|((c>>6)&0x3f);
			*q++ = 0x80|((c&0x3f));
			out += 4;
		}else{
			bbExThrowCString( "Unicode character out of UTF-8 range" );
		}
		++i;
	}
	*q=0;
}

void bmx_stringbuilder_toutf8_sbuffer(BBChar * p, int len, char * buf, size_t length) {
	int i=0;
	int out=0;
	char *q=buf;

	while (i < len && out < length) {
		unsigned int c=*p++;
		if(0xd800 <= c && c <= 0xdbff && i < len - 1) {
			/* surrogate pair */
			unsigned int c2 = *p;
			if(0xdc00 <= c2 && c2 <= 0xdfff) {
				/* valid second surrogate */
				c = ((c - 0xd800) << 10) + (c2 - 0xdc00) + 0x10000;
				++p;
				++i;
			}
		}
		if( c<0x80 ){
			*q++=c;
			out++;
		}else if( c<0x800 ){
			if (out > length - 2) {
				break;
			}
			*q++=0xc0|(c>>6);
			*q++=0x80|(c&0x3f);
			out += 2;
		}else if(c < 0x10000) { 
			if (out > length - 3) {
				break;
			}
			*q++=0xe0|(c>>12);
			*q++=0x80|((c>>6)&0x3f);
			*q++=0x80|(c&0x3f);
			out += 3;
		}else if(c <= 0x10ffff) {
			if (out > length - 4) {
				break;
			}
			*q++ = 0xf0|(c>>18);
			*q++ = 0x80|((c>>12)&0x3f);
			*q++ = 0x80|((c>>6)&0x3f);
			*q++ = 0x80|((c&0x3f));
			out += 4;
		}else{
			bbExThrowCString( "Unicode character out of UTF-8 range" );
		}
		++i;
	}
	*q=0;
}

void bmx_stringbuilder_format_string(struct MaxStringBuilder * buf, BBString * formatText, BBString * value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char vbuffer[2048];
	bmx_stringbuilder_toutf8_buffer(value, vbuffer, sizeof(vbuffer));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, vbuffer);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_byte(struct MaxStringBuilder * buf, BBString * formatText, BBBYTE value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_short(struct MaxStringBuilder * buf, BBString * formatText, BBSHORT value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_int(struct MaxStringBuilder * buf, BBString * formatText, BBINT value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_uint(struct MaxStringBuilder * buf, BBString * formatText, BBUINT value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_long(struct MaxStringBuilder * buf, BBString * formatText, BBLONG value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_ulong(struct MaxStringBuilder * buf, BBString * formatText, BBULONG value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_sizet(struct MaxStringBuilder * buf, BBString * formatText, BBSIZET value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_float(struct MaxStringBuilder * buf, BBString * formatText, float value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

void bmx_stringbuilder_format_double(struct MaxStringBuilder * buf, BBString * formatText, double value) {
	char formatBuf[256];
	bmx_stringbuilder_toutf8_buffer(formatText, formatBuf, sizeof(formatBuf));
	char buffer[2048];
	snprintf(buffer, sizeof(buffer), formatBuf, value);
	bmx_stringbuilder_append_utf8string(buf, buffer);
}

BBUINT bmx_stringbuilder_hashcode(struct MaxStringBuilder * buf) {
	if (buf->hash > 0) return buf->hash;
	BBULONG hash = XXH3_64bits(buf->buffer, buf->count * sizeof(BBChar));
	buf->hash = (BBUINT)(hash ^ (hash >> 32));
	return buf->hash;
}

void bmx_stringbuilder_append_utf32string(struct MaxStringBuilder * buf, BBUINT * chars) {
	int length = utf32strlen(chars);
	bmx_stringbuilder_append_utf32bytes(buf, chars, length);
}

void bmx_stringbuilder_append_utf32bytes(struct MaxStringBuilder * buf, BBUINT * chars, int length) {
	if( !chars || length <= 0 ) return;
	
	int len = length * 2;
	bmx_stringbuilder_resize(buf, buf->count + len);

	BBChar * be = buf->buffer + buf->count;
	BBChar * q = be;
	BBUINT* bp = chars;

	int i = 0;
	while (i++ < length) {
		BBUINT c = *bp++;
		if (c <= 0xffffu) {
			if (c >= 0xd800u && c <= 0xdfffu) {
				*q++ = 0xfffd;
			} else {
          		*q++ = c;
			}
		} else if (c > 0x0010ffffu) {
			*q++ = 0xfffd;
		} else {
			c -= 0x0010000u;
        	*q++ = (BBChar)((c >> 10) + 0xd800);
        	*q++ = (BBChar)((c & 0x3ffu) + 0xdc00);
		}
	}
			
	buf->count += (q - be);
	buf->hash = 0;
}

int bmx_stringbuilder_toint(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToInt(buf->buffer, buf->count, NULL);
}

BBLONG bmx_stringbuilder_tolong(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToLong(buf->buffer, buf->count, NULL);
}

BBUINT bmx_stringbuilder_touint(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToUInt(buf->buffer, buf->count, NULL);
}

BBSHORT bmx_stringbuilder_toshort(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToShort(buf->buffer, buf->count, NULL);
}

BBBYTE bmx_stringbuilder_tobyte(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToByte(buf->buffer, buf->count, NULL);
}

BBULONG bmx_stringbuilder_toulong(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToULong(buf->buffer, buf->count, NULL);
}

BBLONGINT bmx_stringbuilder_tolongint(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToLongInt(buf->buffer, buf->count, NULL);
}

BBULONGINT bmx_stringbuilder_toulongint(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToULongInt(buf->buffer, buf->count, NULL);
}

BBSIZET bmx_stringbuilder_tosizet(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToSizet(buf->buffer, buf->count, NULL);
}

BBFLOAT bmx_stringbuilder_tofloat(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToFloat(buf->buffer, buf->count, NULL);
}

BBDOUBLE bmx_stringbuilder_todouble(struct MaxStringBuilder * buf) {
	if (buf->count == 0) {
		return 0;
	}

	return bbStrToDouble(buf->buffer, buf->count, NULL);
}

void bmx_stringbuilder_append_as_hex(struct MaxStringBuilder * buf, const char * bytes, int length, int upperCase) {
	static const char hexDigitsLower[] = "0123456789abcdef";
	static const char hexDigitsUpper[] = "0123456789ABCDEF";
	
	const char * hexDigits = upperCase ? hexDigitsUpper : hexDigitsLower;
	
	if (length > 0) {
		int count = length * 2;
		
		bmx_stringbuilder_resize(buf, buf->count + count);
		
		const unsigned char * p = (const unsigned char *)bytes;
		BBChar * b = buf->buffer + buf->count;
		while (length--) {
			unsigned char byte = *p++;
			*b++ = hexDigits[(byte >> 4) & 0x0f];
			*b++ = hexDigits[byte & 0x0f];
		}
		
		buf->count += count;
		buf->hash = 0;
	}
}

BBArray * bmx_stringbuilder_split_ints(struct MaxStringBuilder * buf, BBString * sep) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitInts( buf->buffer, buf->count, sep == &bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray * bmx_stringbuilder_split_bytes(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitBytes( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_shorts(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitShorts( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_uints(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitUInts( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_longs(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitLongs( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_ulongs(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitULongs( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_sizets(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitSizets( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_longints(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitLongInts( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_ulongints(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitULongInts( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_floats(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitFloats( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

BBArray * bmx_stringbuilder_split_doubles(struct MaxStringBuilder * buf, BBString * separator) {
	if (buf->count == 0) {
		return &bbEmptyArray;
	}
	return bbStrSplitDoubles( buf->buffer, buf->count, separator == &bbEmptyString ? NULL : separator->buf, separator->length );
}

/* ----------------------------------------------------- */

int bmx_stringbuilder_splitbuffer_length(struct MaxSplitBuffer * buf) {
	return buf->count;
}

BBString * bmx_stringbuilder_splitbuffer_text(struct MaxSplitBuffer * buf, int index) {
	if (index < 0 || index >= buf->count) {
		return &bbEmptyString;
	}

	return bmx_stringbuilder_substring(buf->buffer, buf->startIndex[index], buf->endIndex[index]);
}

void bmx_stringbuilder_splitbuffer_free(struct MaxSplitBuffer * buf) {
	free(buf->startIndex);
	free(buf->endIndex);
	free(buf);
}

BBArray * bmx_stringbuilder_splitbuffer_toarray(struct MaxSplitBuffer * buf) {
	int i, n;
	BBString **p,*bit;
	BBArray *bits;

	n = buf->count;
	
	bits = bbArrayNew1D("$", n);
	p = (BBString**)BBARRAYDATA(bits, 1);

	i = 0;
	while (n--) {
		bit = bmx_stringbuilder_substring(buf->buffer, buf->startIndex[i], buf->endIndex[i]);
		BBINCREFS( bit );
		*p++ = bit;
		i++;
	}
	return bits;
}

struct MaxSplitBuffer * bmx_stringbuilder_splitbuffer_split(struct MaxSplitBuffer * splitBuffer, BBString * separator, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return NULL;
    }

    // Extract the segment we want to split further
    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    
    // Create a temporary buffer for just this segment
    struct MaxStringBuilder tempBuf;
    tempBuf.buffer = splitBuffer->buffer->buffer + start;
    tempBuf.count = end - start;
    tempBuf.capacity = end - start;
    tempBuf.hash = 0;

    // First, count how many new segments we will create
    int count = 1;
    int offset = 0;
    int i = 0;

    while ((offset = bmx_stringbuilder_find(&tempBuf, separator, i)) != -1) {
        ++count;
        i = offset + separator->length;
    }

    // Allocate memory for new split buffer
    struct MaxSplitBuffer * newSplitBuffer = malloc(sizeof(struct MaxSplitBuffer));
    newSplitBuffer->buffer = splitBuffer->buffer; // Reference the original buffer
    newSplitBuffer->count = count;
    newSplitBuffer->startIndex = malloc(count * sizeof(int));
    newSplitBuffer->endIndex = malloc(count * sizeof(int));

    int * bufferStartIndex = newSplitBuffer->startIndex;
    int * bufferEndIndex = newSplitBuffer->endIndex;

    // Perform the actual split
    i = 0;
    int subSegmentStart = 0;
    while ((offset = bmx_stringbuilder_find(&tempBuf, separator, i)) != -1) {
        *bufferStartIndex++ = start + subSegmentStart;
        *bufferEndIndex++ = start + offset;
        subSegmentStart = offset + separator->length;
        i = subSegmentStart;
    }

    // Handle the last segment (or the whole segment if no separator was found)
    *bufferStartIndex++ = start + subSegmentStart;
    *bufferEndIndex++ = end;

    return newSplitBuffer;
}

int bmx_stringbuilder_splitbuffer_toint(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    // Get the start and end positions of the segment in the original buffer
    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];

    int length = end - start;

    // If the segment is empty, return 0
    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *)&(splitBuffer->buffer->buffer[start]);

	return bbStrToInt(segment, length, NULL);
}

unsigned int bmx_stringbuilder_splitbuffer_touint(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToUInt(segment, length, NULL);
}

float bmx_stringbuilder_splitbuffer_tofloat(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0.0f;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0.0f;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToFloat(segment, length, NULL);
}

double bmx_stringbuilder_splitbuffer_todouble(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0.0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0.0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToDouble(segment, length, NULL);
}

BBInt64 bmx_stringbuilder_splitbuffer_tolong(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToLong(segment, length, NULL);
}

BBUInt64 bmx_stringbuilder_splitbuffer_toulong(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToULong(segment, length, NULL);
}

size_t bmx_stringbuilder_splitbuffer_tosizet(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToSizet(segment, length, NULL);
}

BBSHORT bmx_stringbuilder_splitbuffer_toshort(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToShort(segment, length, NULL);
}

BBBYTE bmx_stringbuilder_splitbuffer_tobyte(struct MaxSplitBuffer * splitBuffer, int index) {
    if (index < 0 || index >= splitBuffer->count) {
        return 0;
    }

    int start = splitBuffer->startIndex[index];
    int end = splitBuffer->endIndex[index];
    int length = end - start;

    if (length == 0) {
        return 0;
    }

    BBChar *segment = (BBChar *) &(splitBuffer->buffer->buffer[start]);

	return bbStrToByte(segment, length, NULL);
}
