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

hash_state * bmx_digest_sha1_init() {
	hash_state * state = malloc(sizeof(hash_state));
	sha1_init(state);
	return state;
}

int bmx_digest_sha1_process(hash_state * state, char * buf, int length) {
	return sha1_process(state, buf, length);
}

int bmx_digest_sha1_done(hash_state * state, BBArray * out) {
	BBBYTE * p = (BBBYTE**)BBARRAYDATA(out, 1);

	int res = sha1_done(state, p);
	sha1_init(state);
	return res;
}
