
#include "blitz.h"

#if __STDC_VERSION__ >= 199901L

extern int bbIntAbs( int x );
extern int bbIntSgn( int x );
extern int bbIntMod( int x,int y );
extern void bbIntToLong( BBInt64 *r,int x );

extern double bbFloatAbs( double x );
extern double bbFloatSgn( double x );
extern double bbFloatPow( double x,double y );
extern double bbFloatMod( double x,double y );
extern int bbFloatToInt( double x );
extern void bbFloatToLong( BBInt64 *r,double x );

extern BBInt64 bbLongNeg( BBInt64 x );
extern BBInt64 bbLongNot( BBInt64 x );
extern BBInt64 bbLongAbs( BBInt64 x );
extern BBInt64 bbLongSgn( BBInt64 x );
extern void bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y );
extern void bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y );
extern int bbLongSlt( BBInt64 x,BBInt64 y );
extern int bbLongSgt( BBInt64 x,BBInt64 y );
extern int bbLongSle( BBInt64 x,BBInt64 y );
extern int bbLongSge( BBInt64 x,BBInt64 y );
extern int bbLongSeq( BBInt64 x,BBInt64 y );
extern int bbLongSne( BBInt64 x,BBInt64 y );
extern double bbLongToFloat( BBInt64 x );

extern BBSIZET bbSizetSgn( BBSIZET x );
extern BBSIZET bbSizetAbs( BBSIZET x );

extern BBUINT bbUIntSgn( BBUINT x );
extern BBUINT bbUIntAbs( BBUINT x );

extern BBULONG bbULongSgn( BBULONG x );
extern BBULONG bbULongAbs( BBULONG x );


#else

int bbIntAbs( int x ){
	return x>=0 ? x : -x;
}
int bbIntSgn( int x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
int bbIntMod( int x,int y ){
	return x % y;
}
void bbIntToLong( BBInt64 *r,int x ){
	*r=x;
}

double bbFloatAbs( double x ){
	return fabs( x );
}
double bbFloatSgn( double x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
double bbFloatPow( double x,double y ){
	return pow(x,y);
}
double bbFloatMod( double x,double y ){
	return fmod( x,y );
}
void bbFloatToLong( BBInt64 *r,double x ){
	*r=x;
}

BBInt64 bbLongNeg( BBInt64 x ){
	return -x;
}
BBInt64 bbLongNot( BBInt64 x ){
	return ~x;
}
BBInt64 bbLongAbs( BBInt64 x ){
	return x>=0 ? x : -x;
}
BBInt64 bbLongSgn( BBInt64 x ){
	return x>0 ? 1 : (x<0 ? -1 : 0);
}
void bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x+y;
}
void bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x-y;
}
void bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x*y;
}
void bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x/y;
}
void bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x%y;
}
void bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x&y;
}
void bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x|y;
}
void bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x^y;
}
void bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x<<y;
}
void bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=(BBUInt64)x>>(BBUInt64)y;
}
void bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x>>y;
}
int bbLongSlt( BBInt64 x,BBInt64 y ){
	return x<y;
}
int bbLongSgt( BBInt64 x,BBInt64 y ){
	return x>y;
}
int bbLongSle( BBInt64 x,BBInt64 y ){
	return x<=y;
}
int bbLongSge( BBInt64 x,BBInt64 y ){
	return x>=y;
}
int bbLongSeq( BBInt64 x,BBInt64 y ){
	return x==y;
}
int bbLongSne( BBInt64 x,BBInt64 y ){
	return x!=y;
}
double bbLongToFloat( BBInt64 x ){
	return (double)x;
}

BBSIZET bbSizetAbs( BBSIZET x ){
	return x>=0 ? x : -x;
}
BBSIZET bbSizetSgn( BBSIZET x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}

BBUINT bbUIntAbs( BBUINT x ){
	return x>=0 ? x : -x;
}
BBUINT bbUIntSgn( BBUINT x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}

BBULONG bbULongAbs( BBULONG x ){
	return x>=0 ? x : -x;
}
BBULONG bbULongSgn( BBULONG x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}

#endif

BBLONG bbLongPow(BBLONG base, BBBYTE exp) {
    static const BBBYTE highest_bit_set[] = {
        0, 1, 2, 2, 3, 3, 3, 3,
        4, 4, 4, 4, 4, 4, 4, 4,
        5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5,
        6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 255, // anything past 63 is a guaranteed overflow with base > 1
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255,
    };

    BBLONG result = 1;

    switch (highest_bit_set[exp]) {
    case 255: // we use 255 as an overflow marker and return 0 on overflow/underflow
        if (base == 1) {
            return 1;
        }
        
        if (base == -1) {
            return 1 - 2 * (exp & 1);
        }
        
        return 0;
    case 6:
        if (exp & 1) result *= base;
        exp >>= 1;
        base *= base;
    case 5:
        if (exp & 1) result *= base;
        exp >>= 1;
        base *= base;
    case 4:
        if (exp & 1) result *= base;
        exp >>= 1;
        base *= base;
    case 3:
        if (exp & 1) result *= base;
        exp >>= 1;
        base *= base;
    case 2:
        if (exp & 1) result *= base;
        exp >>= 1;
        base *= base;
    case 1:
        if (exp & 1) result *= base;
    default:
        return result;
    }
}