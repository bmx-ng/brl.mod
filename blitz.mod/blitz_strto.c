
#include "blitz.h"

#include <limits.h>
#include <errno.h>
#include <stdint.h>

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define BB_INLINE inline
#else
#  define BB_INLINE /* nothing */
#endif

static BB_INLINE int bbIsspace(BBChar c) {
    return c == 0x20 || c == '\t' || c == '\n' || c == '\r' || c == '\f' || c == '\v';
}
static BB_INLINE int bbIsdigit(BBChar c) {
    return c >= '0' && c <= '9';
}

/* Convert a BBChar to a digit value for the given base (2,10,16). 
   Returns 0..base-1 on success, or -1 if not a valid digit. */
static BB_INLINE int bbGetdigit(BBChar ch, int base) {
    int v;
    if (ch >= '0' && ch <= '9') {
        v = (int)(ch - '0');
    } else if (ch >= 'A' && ch <= 'F') {
        v = 10 + (int)(ch - 'A');
    } else if (ch >= 'a' && ch <= 'f') {
        v = 10 + (int)(ch - 'a');
    } else {
        return -1;
    }
    return (v < base) ? v : -1;  /* reject e.g. '2' in base 2, 'A' in base 10 */
}

BBLONGINT bbStrToLongInt(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBLONG v = bbStrToLong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)             return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v < LONG_MIN || v > LONG_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBLONGINT)v;
}

BBINT bbStrToInt(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBLONG v = bbStrToLong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)             return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v < INT_MIN) {
        errno = ERANGE;
        return INT_MIN;               // out of int range
    } else if (v > INT_MAX) {
        errno = ERANGE;
        return INT_MAX;               // out of int range
    }
    return (int)v;
}

BBULONGINT bbStrToULongInt(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBULONG v = bbStrToULong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)              return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v > ULONG_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBULONGINT)v;
}

BBBYTE bbStrToByte(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBULONG v = bbStrToULong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)              return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v > UCHAR_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBBYTE)v;
}

BBSHORT bbStrToShort(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBULONG v = bbStrToULong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)              return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v > USHRT_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBSHORT)v;
}

BBUINT bbStrToUInt(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBULONG v = bbStrToULong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)              return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v > UINT_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBUINT)v;
}

BBLONG bbStrToLong(const BBChar *s, int length, int *end_index) {
    BBLONG acc, cutoff;
    int i, any, neg, base, overflowed, digits_start, cutlim, d;

    if (end_index) *end_index = 0;
    if (!s || length <= 0) { errno = EINVAL; return 0; }

    i = 0;
    while (i < length && bbIsspace(s[i])) ++i;
    if (i >= length) { errno = EINVAL; return 0; }

    neg = 0;
    if (s[i] == '+' || s[i] == '-') { neg = (s[i] == '-'); ++i; }

    base = 10;
    if (i < length) {
        if (s[i] == '%') { base = 2;  ++i; }
        else if (s[i] == '$') { base = 16; ++i; }
    }

    acc = 0;
    any = 0;
    overflowed = 0;

    /* negative-accumulation guards LLONG_MIN properly */
    cutoff = neg ? LLONG_MIN : -LLONG_MAX;     /* negative */
    cutlim = (int)(-(cutoff % (BBLONG)base));  /* 0..base-1 */
    cutoff /= (BBLONG)base;

    digits_start = i;

    for (; i < length; ++i) {
        d = bbGetdigit(s[i], base);

        if (d < 0) break;

        if (!overflowed) {
            if (acc < cutoff || (acc == cutoff && d > cutlim)) {
                overflowed = 1;   /* keep scanning to set end_index correctly */
            } else {
                acc = acc * (BBLONG)base - (BBLONG)d; /* stay negative */
            }
        }
        any = 1;
    }

    if (!any || i == digits_start) { errno = EINVAL; return 0; }

    if (end_index) *end_index = i;  /* first unparsed char (one-past-last) */

    if (overflowed) {
        errno = ERANGE;
        return neg ? LLONG_MIN : LLONG_MAX;
    }

    errno = 0;
    return neg ? acc : -acc;
}

BBULONG bbStrToULong(const BBChar *s, int length, int *end_index) {
    int i, neg, base, any, overflowed, digits_start, d;
    BBULONG acc, cutoff, cutlim;

    if (end_index) *end_index = 0;
    if (!s || length <= 0) { errno = EINVAL; return 0; }

    i = 0;
    while (i < length && bbIsspace(s[i])) ++i;
    if (i >= length) { errno = EINVAL; return 0; }

    /* optional sign */
    neg = 0;
    if (s[i] == '+' || s[i] == '-') { neg = (s[i] == '-'); ++i; }

    /* optional BlitzMax prefix after sign: % (bin) or $ (hex); default base 10 */
    base = 10;
    if (i < length) {
        if (s[i] == '%') { base = 2;  ++i; }
        else if (s[i] == '$') { base = 16; ++i; }
    }

    acc = 0;
    any = 0;
    overflowed = 0;

    /* cutoff/cutlim for unsigned accumulation: acc*base + d must not exceed ULONG_MAX */
    cutoff = ULLONG_MAX / (BBULONG)base;
    cutlim = ULLONG_MAX % (BBULONG)base;

    digits_start = i;

    for (; i < length; ++i) {
        d = bbGetdigit(s[i], base);
        if (d < 0) break;

        if (!overflowed) {
            if (acc > cutoff || (acc == cutoff && (BBULONG)d > cutlim)) {
                overflowed = 1;  /* keep scanning digits to place end_index correctly */
            } else {
                acc = acc * (BBULONG)base + (BBULONG)d;
            }
        }
        any = 1;
    }

    if (!any || i == digits_start) { errno = EINVAL; return 0; }

    if (end_index) *end_index = i;   /* first unparsed character (one-past-last) */

    if (overflowed) {
        errno = ERANGE;
        return ULLONG_MAX;
    }

    errno = 0;
    /* POSIX strtoul semantics: accept '-' and convert via unsigned wrap */
    return neg ? (BBULONG)(0 - acc) : acc;
}

BBSIZET bbStrToSizet(const BBChar *s, int length, int *end_index) {
    errno = 0;
    int last;
    BBULONG v = bbStrToULong(s, length, &last);
    if (end_index) *end_index = last;

    if (last <= 0)              return 0;           // no digits
    if (errno == ERANGE)       return 0;           // overflow/underflow
    if (v > SIZE_T_MAX) {
        errno = ERANGE;
        return 0;               // out of int range
    }
    return (BBSIZET)v;
}

BBDOUBLE bbStrToDouble(const BBChar *s, int length, int *end_index) {
    double value = 0.0;
    int res = bbStrToDoubleEx(s, length, &value, 0, length, 0, &bbEmptyString);
    if (end_index) *end_index = res;
    return value;
}

BBFLOAT bbStrToFloat(const BBChar *s, int length, int *end_index) {
    float value = 0.0f;
    int res = bbStrToFloatEx(s, length, &value, 0, length, 0, &bbEmptyString);
    if (end_index) *end_index = res;
    return value;
}
