
#ifndef BLITZ_CCLIB_H
#define BLITZ_CCLIB_H

#include "blitz_types.h"


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

int		bbIntAbs( int x );
int		bbIntSgn( int x );
int		bbIntMod( int x,int y );
int		bbIntMin( int x,int y );
int		bbIntMax( int x,int y );
void	bbIntToLong( BBInt64 *r,int x );

double	bbFloatAbs( double x );
double	bbFloatSgn( double x );
double	bbFloatPow( double x,double y );
double	bbFloatMod( double x,double y );
double	bbFloatMin( double x,double y );
double	bbFloatMax( double x,double y );
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
BBInt64	bbLongMin( BBInt64 x,BBInt64 y );
BBInt64	bbLongMax( BBInt64 x,BBInt64 y );
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

BBSIZET bbSizetMin( BBSIZET x,BBSIZET y );
BBSIZET bbSizetMax( BBSIZET x,BBSIZET y );
BBSIZET bbSizetSgn( BBSIZET x );
BBSIZET bbSizetAbs( BBSIZET x );

BBUINT bbUIntMin( BBUINT x, BBUINT y );
BBUINT bbUIntMax( BBUINT x, BBUINT y );
BBUINT bbUIntSgn( BBUINT x );
BBUINT bbUIntAbs( BBUINT x );

BBULONG bbULongMin( BBULONG x, BBULONG y );
BBULONG bbULongMax( BBULONG x, BBULONG y );
BBULONG bbULongSgn( BBULONG x );
BBULONG bbULongAbs( BBULONG x );

#ifdef __cplusplus
}
#endif

#endif
