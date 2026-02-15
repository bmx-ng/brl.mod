#include "blitz.h"
#include <errno.h>

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define BB_INLINE inline
#else
#  define BB_INLINE /* nothing */
#endif

static BB_INLINE int bbIsspace(BBChar c) {
    return c == 0x20 || c == '\t' || c == '\n' || c == '\r' || c == '\f' || c == '\v';
}

BBArray *bbStringSplitInts( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
		return &bbEmptyArray;
	}
    return bbStrSplitInts( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitBytes( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitBytes( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitShorts( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitShorts( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitUInts( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitUInts( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitLongs( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitLongs( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitULongs( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitULongs( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitSizets( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitSizets( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitLongInts( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitLongInts( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

BBArray *bbStringSplitULongInts( BBString *str, BBString *sep ){
	if( str==&bbEmptyString || str->length==0 ){
        return &bbEmptyArray;
    }
	return bbStrSplitULongInts( str->buf, str->length, sep==&bbEmptyString ? NULL : sep->buf, sep->length );
}

static inline int sep_match_at(const BBChar *s, int i, const BBChar *d, int dlen){
	/* assumes caller already checked i <= slen-dlen */

	if( s[i] != d[0] ) return 0;
	if( s[i + dlen - 1] != d[dlen - 1] ) return 0;

	switch( dlen ){
	case 2:
		return 1; /* first+last already checked (same as both chars) */
	case 3:
		return s[i+1] == d[1];
	case 4:
		return (s[i+1] == d[1]) & (s[i+2] == d[2]); /* '&' avoids short-circuit branch */
	}
	/* general case */
	for( int k=1; k<dlen-1; ++k ){
		if( s[i+k] != d[k] ) return 0;
	}
	return 1;
}

#define BB_DEFINE_STR_SPLIT_NUMS(FNNAME, ARRID, CTYPE, PARSEFN)                        \
BBArray *FNNAME( BBChar *str, int strLength, BBChar *sep, int sepLength ){            \
	/* Empty string => empty array */                                                 \
	if( !str || strLength==0 ){                                                       \
		return &bbEmptyArray;                                                         \
	}                                                                                 \
                                                                                      \
	BBChar *s = str;                                                                  \
	int slen = strLength;                                                             \
                                                                                      \
	/* Empty separator => parse whole string as single entry */                       \
	if( !sep || sepLength==0 ){                                                       \
		BBArray *arr = bbArrayNew1D( ARRID, 1 );                                      \
		CTYPE *out = (CTYPE*)BBARRAYDATA(arr,1);                                      \
                                                                                      \
		int endi=0;                                                                   \
		errno=0;                                                                      \
		CTYPE v = PARSEFN( s, slen, &endi );                                          \
                                                                                      \
		/* Reject trailing junk (allow whitespace only) */                            \
		int j = endi;                                                                 \
		while( j < slen && bbIsspace(s[j]) ) ++j;                                     \
		if( j < slen ) v = (CTYPE)0;                                                  \
                                                                                      \
		out[0] = v;                                                                   \
		return arr;                                                                   \
	}                                                                                 \
                                                                                      \
	BBChar *d = sep;                                                                  \
	int dlen = sepLength;                                                             \
                                                                                      \
	/* count separators => number of tokens */                                \
	int count = 1;                                                                    \
	if( dlen==1 ){                                                                    \
		BBChar c = d[0];                                                              \
		for( int i=0; i<slen; ++i ){                                                  \
			if( s[i]==c ) ++count;                                                    \
		}                                                                             \
	}else{                                                                            \
		for( int i=0; i <= slen-dlen; ++i ){                                          \
			if( sep_match_at(s, i, d, dlen) ){                                        \
				++count;                                                              \
				i += dlen-1;                                                          \
			}                                                                         \
		}                                                                             \
	}                                                                                 \
                                                                                      \
	BBArray *arr = bbArrayNew1D( ARRID, count );                                      \
	CTYPE *out = (CTYPE*)BBARRAYDATA(arr,1);                                          \
                                                                                      \
	/* parse each token */                                                    \
	int start = 0;                                                                    \
	int outIndex = 0;                                                                 \
                                                                                      \
	if( dlen==1 ){                                                                    \
		BBChar c = d[0];                                                              \
		for( int i=0; i <= slen; ++i ){                                               \
			if( i==slen || s[i]==c ){                                                 \
				int tokLen = i - start;                                               \
				if( tokLen <= 0 ){                                                    \
					out[outIndex++] = 0;                                              \
				}else{                                                                \
					int endi=0;                                                       \
					errno = 0;                                                        \
					CTYPE v = PARSEFN( s+start, tokLen, &endi );                      \
					int j=endi;                                                       \
					while( j < tokLen && bbIsspace( (s+start)[j] ) ) ++j;             \
					if( j < tokLen ) v = 0;                                           \
					out[outIndex++] = v;                                              \
				}                                                                     \
				start = i + 1; /* skip delimiter char */                              \
			}                                                                         \
		}                                                                             \
	}else{                                                                            \
		for( int i=0; i <= slen; ){                                                   \
			int isMatch = 0;                                                          \
			if( i <= slen-dlen ){                                                     \
				isMatch = sep_match_at( s, i, d, dlen );                              \
			}                                                                         \
			if( isMatch || i==slen ){                                                 \
				int tokLen = i - start;                                               \
				/* Empty entry => 0 */                                                \
				if( tokLen <= 0 ){                                                    \
					out[outIndex++] = (CTYPE)0;                                       \
				}else{                                                                \
					int endi = 0;                                                     \
					errno = 0;                                                        \
					CTYPE v = PARSEFN( s + start, tokLen, &endi );                    \
																					\
					/* Reject trailing junk (allow whitespace only) */                \
					int j = endi;                                                     \
					while( j < tokLen && bbIsspace( (s+start)[j] ) ) ++j;             \
					if( j < tokLen ){                                                 \
						v = (CTYPE)0;                                                 \
					}                                                                 \
																						\
					out[outIndex++] = v;                                              \
				}                                                                     \
																						\
				start = i + dlen;                                                     \
				i += dlen;                                                            \
				continue;                                                             \
			}                                                                         \
																						\
			++i;                                                                      \
		}                                                                             \
	}                                                                                 \
	return arr;                                                                       \
}

BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitInts,     "i", BBINT,     bbStrToInt )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitBytes,    "b", BBBYTE,    bbStrToByte )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitShorts,   "s", BBSHORT,   bbStrToShort )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitUInts,    "u", BBUINT,    bbStrToUInt )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitLongs,    "l", BBLONG,    bbStrToLong )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitULongs,   "y", BBULONG,   bbStrToULong )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitSizets,   "t", BBSIZET,   bbStrToSizet )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitLongInts, "v", BBLONGINT, bbStrToLongInt )
BB_DEFINE_STR_SPLIT_NUMS( bbStrSplitULongInts,"e", BBULONGINT,bbStrToULongInt )
