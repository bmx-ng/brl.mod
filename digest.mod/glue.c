/*
  Copyright (C) 2019 Bruce A Henderson

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
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
#include "tomcrypt.h"
#include "brl.mod/blitz.mod/blitz.h"

void bmx_digest_free(void * handle) {
	free(handle);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_digest_bytes_to_hex(char * bytes, int length, int uppercase) {
	char hex[2048];
	unsigned long outlen = sizeof(hex);
	base16_encode(bytes, length, hex, &outlen, uppercase);
	
	return bbStringFromBytes(hex, outlen);
}
