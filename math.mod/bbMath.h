#include <math.h>

#define RAD_TO_DEG 57.2957795130823208767981548141052
#define DEG_TO_RAD 0.0174532925199432957692369076848861

#ifndef __STDC_VERSION__
	#define __STDC_VERSION__ 0
#endif


#if __STDC_VERSION__ >= 199901L

inline int bbIsNan( double x ){
	return isnan(x) ? 1 : 0;
}
inline int bbIsInf( double x ){
	return isinf(x) ? 1 : 0;
}
inline double bbSqr( double x ){
	return sqrt( x );
}
inline double bbSin( double x ){
	return sin( x*DEG_TO_RAD );
}
inline double bbCos( double x ){
	return cos( x*DEG_TO_RAD );
}
inline double bbTan( double x ){
	return tan( x*DEG_TO_RAD );
}
inline double bbASin( double x ){
	return asin( x ) * RAD_TO_DEG;
}
inline double bbACos( double x ){
	return acos( x ) * RAD_TO_DEG;
}
inline double bbATan( double x ){
	return atan( x ) * RAD_TO_DEG;
}
inline double bbATan2( double y,double x ){
	return atan2( y,x ) * RAD_TO_DEG;
}
inline double bbSinh( double x ){
	return sinh( x );
}
inline double bbCosh( double x ){
	return cosh( x );
}
inline double bbTanh( double x ){
	return tanh( x );
}
inline double bbExp( double x ){
	return exp( x );
}
inline double bbFloor( double x ){
	return floor( x );
}
inline double bbLog( double x ){
	return log(x);
}
inline double bbLog10( double x ){
	return log10(x);
}
inline double bbCeil( double x ){
	return ceil( x );
}
inline double bbRound( double x ){
	return round( x );
}
inline double bbTrunc( double x ){
	return trunc( x );
}

#define RAD_TO_DEGF 57.2957795
#define DEG_TO_RADF 0.0174532

inline float bbSqrf( float x ){
	return sqrtf( x );
}
inline float bbSinf( float x ){
	return sinf( x*DEG_TO_RADF );
}
inline float bbCosf( float x ){
	return cosf( x*DEG_TO_RADF );
}
inline float bbTanf( float x ){
	return tanf( x*DEG_TO_RADF );
}
inline float bbASinf( float x ){
	return asinf( x ) * RAD_TO_DEGF;
}
inline float bbACosf( float x ){
	return acosf( x ) * RAD_TO_DEGF;
}
inline float bbATanf( float x ){
	return atanf( x ) * RAD_TO_DEGF;
}
inline float bbATan2f( float y,float x ){
	return atan2f( y,x ) * RAD_TO_DEGF;
}
inline float bbSinhf( float x ){
	return sinhf( x );
}
inline float bbCoshf( float x ){
	return coshf( x );
}
inline float bbTanhf( float x ){
	return tanhf( x );
}
inline float bbExpf( float x ){
	return expf( x );
}
inline float bbFloorf( float x ){
	return floorf( x );
}
inline float bbLogf( float x ){
	return logf(x);
}
inline float bbLog10f( float x ){
	return log10f(x);
}
inline float bbCeilf( float x ){
	return ceilf( x );
}
inline float bbRoundf( float x ){
	return roundf( x );
}
inline float bbTruncf( float x ){
	return truncf( x );
}
#else
int bbIsNan( double x );
int bbIsInf( double x );
double bbSqr( double x );
double bbSin( double x );
double bbCos( double x );
double bbTan( double x );
double bbASin( double x );
double bbACos( double x );
double bbATan( double x );
double bbATan2( double y,double x );
double bbSinh( double x );
double bbCosh( double x );
double bbTanh( double x );
double bbExp( double x );
double bbFloor( double x );
double bbLog( double x );
double bbLog10( double x );
double bbCeil( double x );
double bbRound( double x );
double bbTrunc( double x );

int bbIsNanf( float x );
int bbIsInff( float x );
float bbSqrf( float x );
float bbSinf( float x );
float bbCosf( float x );
float bbTanf( float x );
float bbASinf( float x );
float bbACosf( float x );
float bbATanf( float x );
float bbATan2f( float y,float x );
float bbSinhf( float x );
float bbCoshf( float x );
float bbTanhf( float x );
float bbExpf( float x );
float bbFloorf( float x );
float bbLogf( float x );
float bbLog10f( float x );
float bbCeilf( float x );
float bbRoundf( float x );
float bbTruncf( float x );
#endif
