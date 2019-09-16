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

crc32_state * bmx_digest_crc32_init() {
	crc32_state * state = malloc(sizeof(crc32_state));
	crc32_init(state);
	return state;
}

void bmx_digest_crc32_update(crc32_state * state, char * buf, int length) {
	crc32_update(state, buf, length);
}

void bmx_digest_crc32_finish(crc32_state * state, void * out, int size) {
	crc32_finish(state, out, size);
	crc32_init(state);
}

void bmx_digest_crc32_finish_int(crc32_state * state, int * out) {
	int res = 0;
	crc32_finish(state, &res, 4);
	crc32_init(state);
	res = ((res << 8) & 0xff00ff00 ) | ((res >> 8) & 0xff00ff ); 
	*out = (res << 16) | (res >> 16) & 0xFFFF;
}
