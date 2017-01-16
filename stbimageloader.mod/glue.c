
#include "pub.mod/stbimage.mod/stb/stb_image.h"

#include "brl.mod/blitz.mod/blitz.h"

#ifdef BMX_NG
#define CB_PREF(func) func
#else
#define CB_PREF(func) _##func
#endif


int CB_PREF(brl_stbimageloader_TStbioCallbacks__Read)(BBObject * cb, char * data,int size);
void CB_PREF(brl_stbimageloader_TStbioCallbacks__Skip)(BBObject * cb, int n);
int CB_PREF(brl_stbimageloader_TStbioCallbacks__Eof)(BBObject * cb);



stbi_uc * bmx_stbi_load_image(BBObject * cb, int * width, int * height, int * channels) {

	stbi_io_callbacks callbacks;
	callbacks.read = brl_stbimageloader_TStbioCallbacks__Read;
	callbacks.skip = brl_stbimageloader_TStbioCallbacks__Skip;
	callbacks.eof = brl_stbimageloader_TStbioCallbacks__Eof;

	return stbi_load_from_callbacks(&callbacks, cb, width, height, channels, 0);

}
