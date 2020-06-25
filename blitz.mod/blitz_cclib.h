
#ifndef BLITZ_CCLIB_H
#define BLITZ_CCLIB_H

#include "blitz_types.h"
#include <math.h>

#ifdef __cplusplus
extern "C"{
#endif

#define bbPOSNANf (0.0f/0.0f)
#define bbPOSNANd (0.0/0.0)
#define bbNEGNANf (-0.0f/0.0f)
#define bbNEGNANd (-0.0/0.0)
#define bbPOSINFf (1.0f/0.0f)
#define bbPOSINFd (1.0/0.0)
#define bbNEGINFf (-1.0f/0.0f)
#define bbNEGINFd (-1.0/0.0)

#ifndef __STDC_VERSION__
	#define __STDC_VERSION__ 0
#endif

#if __STDC_VERSION__ >= 199901L

inline int bbIntAbs( int x ){
	return x>=0 ? x : -x;
}
inline int bbIntSgn( int x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
inline int bbIntMod( int x,int y ){
	return x % y;
}
inline int bbIntMin( int x,int y ){
	return x<y ? x : y;
}
inline int bbIntMax( int x,int y ){ 
	return x>y ? x : y;
}
inline void bbIntToLong( BBInt64 *r,int x ){
	*r=x;
}

inline double bbFloatAbs( double x ){
	return fabs( x );
}
inline double bbFloatSgn( double x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
inline double bbFloatPow( double x,double y ){
	return pow(x,y);
}
inline double bbFloatMod( double x,double y ){
	return fmod( x,y );
}
inline double bbFloatMin( double x,double y ){
	return x<y ? x : y;
}
inline double bbFloatMax( double x,double y ){
	return x>y ? x : y;
}
inline void bbFloatToLong( BBInt64 *r,double x ){
	*r=x;
}

inline BBInt64 bbLongNeg( BBInt64 x ){
	return -x;
}
inline BBInt64 bbLongNot( BBInt64 x ){
	return ~x;
}
inline BBInt64 bbLongAbs( BBInt64 x ){
	return x>=0 ? x : -x;
}
inline BBInt64 bbLongSgn( BBInt64 x ){
	return x>0 ? 1 : (x<0 ? -1 : 0);
}
inline void bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x+y;
}
inline void bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x-y;
}
inline void bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x*y;
}
inline void bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x/y;
}
inline void bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x%y;
}
inline BBInt64 bbLongMin( BBInt64 x,BBInt64 y ){
	return x<y ? x : y;
}
inline BBInt64 bbLongMax( BBInt64 x,BBInt64 y ){
	return x>y ? x : y;
}
inline void bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x&y;
}
inline void bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x|y;
}
inline void bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x^y;
}
inline void bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x<<y;
}
inline void bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=(BBUInt64)x>>(BBUInt64)y;
}
inline void bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x>>y;
}
inline int bbLongSlt( BBInt64 x,BBInt64 y ){
	return x<y;
}
inline int bbLongSgt( BBInt64 x,BBInt64 y ){
	return x>y;
}
inline int bbLongSle( BBInt64 x,BBInt64 y ){
	return x<=y;
}
inline int bbLongSge( BBInt64 x,BBInt64 y ){
	return x>=y;
}
inline int bbLongSeq( BBInt64 x,BBInt64 y ){
	return x==y;
}
inline int bbLongSne( BBInt64 x,BBInt64 y ){
	return x!=y;
}
inline double bbLongToFloat( BBInt64 x ){
	return (double)x;
}

inline BBSIZET bbSizetAbs( BBSIZET x ){
	return x>=0 ? x : -x;
}
inline BBSIZET bbSizetSgn( BBSIZET x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
inline BBSIZET bbSizetMin( BBSIZET x,BBSIZET y ){
	return x<y ? x : y;
}
inline BBSIZET bbSizetMax( BBSIZET x,BBSIZET y ){ 
	return x>y ? x : y;
}

inline BBUINT bbUIntAbs( BBUINT x ){
	return x>=0 ? x : -x;
}
inline BBUINT bbUIntSgn( BBUINT x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
inline BBUINT bbUIntMin( BBUINT x,BBUINT y ){
	return x<y ? x : y;
}
inline BBUINT bbUIntMax( BBUINT x,BBUINT y ){ 
	return x>y ? x : y;
}

inline BBULONG bbULongAbs( BBULONG x ){
	return x>=0 ? x : -x;
}
inline BBULONG bbULongSgn( BBULONG x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
inline BBULONG bbULongMin( BBULONG x,BBULONG y ){
	return x<y ? x : y;
}
inline BBULONG bbULongMax( BBULONG x,BBULONG y ){ 
	return x>y ? x : y;
}


#else

int		bbIntAbs( int x );
int		bbIntSgn( int x );
int		bbIntMod( int x,int y );
void	bbIntToLong( BBInt64 *r,int x );

double	bbFloatAbs( double x );
double	bbFloatSgn( double x );
double	bbFloatPow( double x,double y );
double	bbFloatMod( double x,double y );
int		bbFloatToInt( double x );
void	bbFloatToLong( BBInt64 *r,double x );

BBInt64	bbLongNeg( BBInt64 x );
BBInt64	bbLongNot( BBInt64 x );
BBInt64	bbLongAbs( BBInt64 x );
BBInt64	bbLongSgn( BBInt64 x );
void	bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y );
int		bbLongSlt( BBInt64 x,BBInt64 y );
int		bbLongSgt( BBInt64 x,BBInt64 y );
int		bbLongSle( BBInt64 x,BBInt64 y );
int		bbLongSge( BBInt64 x,BBInt64 y );
int		bbLongSeq( BBInt64 x,BBInt64 y );
int		bbLongSne( BBInt64 x,BBInt64 y );
double	bbLongToFloat( BBInt64 x );

BBSIZET bbSizetSgn( BBSIZET x );
BBSIZET bbSizetAbs( BBSIZET x );

BBUINT bbUIntSgn( BBUINT x );
BBUINT bbUIntAbs( BBUINT x );

BBULONG bbULongSgn( BBULONG x );
BBULONG bbULongAbs( BBULONG x );

#endif

BBLONG bbLongPow(BBLONG base, BBBYTE exp);

#ifdef __cplusplus
}
#endif

#endif
