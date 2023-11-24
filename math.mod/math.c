
#include <bbMath.h>

#define RAD_TO_DEG 57.2957795130823208767981548141052
#define DEG_TO_RAD 0.0174532925199432957692369076848861

#if __STDC_VERSION__ >= 199901L
extern int bbIsNan( double x );
extern int bbIsInf( double x );
extern double bbSqr( double x );
extern double bbSin( double x );
extern double bbCos( double x );
extern double bbTan( double x );
extern double bbASin( double x );
extern double bbACos( double x );
extern double bbATan( double x );
extern double bbATan2( double y,double x );
extern double bbSinh( double x );
extern double bbCosh( double x );
extern double bbTanh( double x );
extern double bbExp( double x );
extern double bbFloor( double x );
extern double bbLog( double x );
extern double bbLog10( double x );
extern double bbCeil( double x );
extern double bbRound( double x );
extern double bbTrunc( double x );

extern int bbIsNanf( float x );
extern int bbIsInff( float x );
extern float bbSqrf( float x );
extern float bbSinf( float x );
extern float bbCosf( float x );
extern float bbTanf( float x );
extern float bbASinf( float x );
extern float bbACosf( float x );
extern float bbATanf( float x );
extern float bbATan2f( float y,float x );
extern float bbSinhf( float x );
extern float bbCoshf( float x );
extern float bbTanhf( float x );
extern float bbExpf( float x );
extern float bbFloorf( float x );
extern float bbLogf( float x );
extern float bbLog10f( float x );
extern float bbCeilf( float x );
extern float bbRoundf( float x );
extern float bbTruncf( float x );

#else

int bbIsNan( double x ){
	return isnan(x) ? 1 : 0;
}
int bbIsInf( double x ){
	return isinf(x) ? 1 : 0;
}
double bbSqr( double x ){
	return sqrt( x );
}
double bbSin( double x ){
	return sin( x*DEG_TO_RAD );
}
double bbCos( double x ){
	return cos( x*DEG_TO_RAD );
}
double bbTan( double x ){
	return tan( x*DEG_TO_RAD );
}
double bbASin( double x ){
	return asin( x ) * RAD_TO_DEG;
}
double bbACos( double x ){
	return acos( x ) * RAD_TO_DEG;
}
double bbATan( double x ){
	return atan( x ) * RAD_TO_DEG;
}
double bbATan2( double y,double x ){
	return atan2( y,x ) * RAD_TO_DEG;
}
double bbSinh( double x ){
	return sinh( x );
}
double bbCosh( double x ){
	return cosh( x );
}
double bbTanh( double x ){
	return tanh( x );
}
double bbExp( double x ){
	return exp( x );
}
double bbFloor( double x ){
	return floor( x );
}
double bbLog( double x ){
	return log(x);
}
double bbLog10( double x ){
	return log10(x);
}
double bbCeil( double x ){
	return ceil( x );
}
double bbRound( double x ){
	return round( x );
}
double bbTrunc( double x ){
	return trunc( x );
}

#define RAD_TO_DEGF RAD_TO_DEG
#define DEG_TO_RADF DEG_TO_RAD

#define sqrtf sqrt
#define sinf sin
#define cosf cos
#define tanf tan
#define asinf asin
#define acosf acos
#define atanf atan
#define atan2f atan2
#define sinhf sinh
#define coshf cosh
#define tanhf tanh
#define expf exp
#define floorf floor
#define logf log
#define log10f log10
#define ceilf ceil
#define roundf round
#define truncf trunc

float bbSqrf( float x ){
	return sqrtf( x );
}
float bbSinf( float x ){
	return sinf( x*DEG_TO_RADF );
}
float bbCosf( float x ){
	return cosf( x*DEG_TO_RADF );
}
float bbTanf( float x ){
	return tanf( x*DEG_TO_RADF );
}
float bbASinf( float x ){
	return asinf( x ) * RAD_TO_DEGF;
}
float bbACosf( float x ){
	return acosf( x ) * RAD_TO_DEGF;
}
float bbATanf( float x ){
	return atanf( x ) * RAD_TO_DEGF;
}
float bbATan2f( float y,float x ){
	return atan2f( y,x ) * RAD_TO_DEGF;
}
float bbSinhf( float x ){
	return sinhf( x );
}
float bbCoshf( float x ){
	return coshf( x );
}
float bbTanhf( float x ){
	return tanhf( x );
}
float bbExpf( float x ){
	return expf( x );
}
float bbFloorf( float x ){
	return floorf( x );
}
float bbLogf( float x ){
	return logf(x);
}
float bbLog10f( float x ){
	return log10f(x);
}
float bbCeilf( float x ){
	return ceilf( x );
}
float bbRoundf( float x ){
	return roundf( x );
}
float bbTruncf( float x ){
	return truncf( x );
}
#endif
