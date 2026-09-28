/* Explicit CPU texture conversion. zlib/libpng licence.
 * Build without fast-math: exceptional input values have defined conversion rules. */
/* BMK appends -ffast-math after module flags on Windows. Override it here. */
#if defined(__GNUC__) && !defined(__clang__)
#pragma GCC optimize ("no-fast-math")
#endif
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <math.h>

int bmx_texture_valid_exposure(double value) {
	uint64_t bits;
	memcpy(&bits,&value,sizeof(bits));
	return (bits & UINT64_C(0x7ff0000000000000))!=UINT64_C(0x7ff0000000000000) && value>=-64 && value<=64;
}

static double half_value(uint16_t bits) {
	int exponent=(bits>>10)&31;
	int mantissa=bits&1023;
	double value;
	if(!exponent) value=ldexp((double)mantissa,-24);
	else if(exponent==31) value=mantissa?NAN:INFINITY;
	else value=ldexp((double)(1024+mantissa),exponent-25);
	return bits&32768?-value:value;
}

static double unit(double value) {
	if(!(value>0)) return 0; /* Includes NaN and negative infinity. */
	return value>=1?1:value;
}

static unsigned char quantize(double value) {
	return (unsigned char)floor(unit(value)*255+0.5);
}

void bmx_texture_convert(const unsigned char *pixels,int pitch,unsigned char *output,int outputPitch,int width,int height,int bits,int sourceEncoding,int outputEncoding,int premultiplied,int toneMap,double exposure) {
	double gain=exp2(exposure);
	for(int y=0;y<height;++y) {
		const unsigned char *row=pixels+(size_t)y*pitch;
		unsigned char *dst=output+(size_t)y*outputPitch;
		for(int x=0;x<width;++x) {
			double rgba[4];
			for(int k=0;k<4;++k) {
				const unsigned char *src=row+((size_t)x*4+k)*(bits/8);
				if(bits==16) {
					uint16_t value;
					memcpy(&value,src,sizeof(value));
					rgba[k]=half_value(value);
				} else if(bits==32) {
					float value;
					memcpy(&value,src,sizeof(value));
					rgba[k]=value;
				} else rgba[k]=*src/255.0;
			}
			double alpha=unit(rgba[3]);
			for(int k=0;k<3;++k) {
				double value=rgba[k];
				/* Unassociate in the source encoding, before transfer decoding. */
				if(premultiplied) value=alpha>0?value/alpha:0;
				if(!(value>0)) value=0;
				if(sourceEncoding) value=value<=0.04045?value/12.92:pow((value+0.055)/1.055,2.4);
				value*=gain;
				if(toneMap) value=isinf(value)?1:value/(1+value);
				value=unit(value);
				if(outputEncoding) value=value<=0.0031308?12.92*value:1.055*pow(value,1.0/2.4)-0.055;
				dst[x*4+k]=quantize(value);
			}
			dst[x*4+3]=quantize(alpha);
		}
	}
}
