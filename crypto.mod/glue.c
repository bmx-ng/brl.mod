/*
 * Copyright (c) 2019 Bruce A Henderson
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#include "hydrogen.h"
#include "brl.mod/blitz.mod/blitz.h"

void bmx_hydro_hash_keygen(uint8_t * key) {
	hydro_hash_keygen(key);
}

hydro_hash_state * bmx_hydro_hash_init(BBString * context, uint8_t * key) {
	char * c = bbStringToUTF8String(context);
	hydro_hash_state * state = malloc(sizeof(hydro_hash_state));
	int res = hydro_hash_init(state, c, key);
	bbMemFree(c);
	return state;
}

int bmx_hydro_hash_update(hydro_hash_state * state, void * in, size_t inLen) {
	return hydro_hash_update(state, in, inLen);
}

int bmx_hydro_hash_final(hydro_hash_state * state, uint8_t * out, size_t outLen) {
	return hydro_hash_final(state, out, outLen);
}

void bmx_hydro_hash_state_free(hydro_hash_state * state) {
	free(state);
}

int bmx_hydro_hash_hash(uint8_t * out, size_t outLen, uint8_t * in, size_t inLen, BBString * context, uint8_t * key) {
	char * c = bbStringToUTF8String(context);
	int res = hydro_hash_hash(out, outLen, in, inLen, c, key);
	bbMemFree(c);
	return res;
}

// --------------------------------------------------------

void bmx_hydro_secretbox_keygen(uint8_t * key) {
	hydro_secretbox_keygen(key);
}

int bmx_hydro_secretbox_encrypt(uint8_t * c, const void * m, size_t mLen, uint64_t msgId, BBString * context, uint8_t * key) {
	char * ctx = bbStringToUTF8String(context);
	int res = hydro_secretbox_encrypt(c, m, mLen, msgId, ctx, key);
	bbMemFree(ctx);
	return res == 0;
}

int bmx_hydro_secretbox_decrypt(void * m, const uint8_t * c, size_t cLen, uint64_t msgId, BBString * context, uint8_t * key) {
	char * ctx = bbStringToUTF8String(context);
	int res = hydro_secretbox_decrypt(m, c, cLen, msgId, ctx, key);
	bbMemFree(ctx);
	return res == 0;
}

void bmx_hydro_secretbox_probe_create(uint8_t * probe, uint8_t * c, size_t cLen, BBString * context, uint8_t * key) {
	char * ctx = bbStringToUTF8String(context);
	hydro_secretbox_probe_create(probe, c, cLen, ctx, key);
	bbMemFree(ctx);
}

int bmx_hydro_secretbox_probe_verify(uint8_t * probe, const uint8_t * c, size_t cLen, BBString * context, uint8_t * key) {
	char * ctx = bbStringToUTF8String(context);
	int res = hydro_secretbox_probe_verify(probe, c, cLen, ctx, key);
	bbMemFree(ctx);
	return res == 0;	
}

// --------------------------------------------------------

void bmx_hydro_pwhash_keygen(uint8_t * key) {
	hydro_pwhash_keygen(key);
}

int bmx_hydro_pwhash_create(uint8_t * stored, BBString * password, uint8_t * masterKey, uint64_t opsLimit, size_t memLimit, int threads) {
	char * p = bbStringToUTF8String(password);
	int res = hydro_pwhash_create(stored, p, strlen(p), masterKey, opsLimit, memLimit, threads);
	hydro_memzero(p, strlen(p));
	bbMemFree(p);
	return res == 0;
}

int bmx_hydro_pwhash_verify(uint8_t * stored, BBString * password, uint8_t * masterKey, uint64_t opsLimitMax, size_t memLimitMax, int threadsMax) {
	char * p = bbStringToUTF8String(password);
	int res = hydro_pwhash_verify(stored, p, strlen(p), masterKey, opsLimitMax, memLimitMax, threadsMax);
	hydro_memzero(p, strlen(p));
	bbMemFree(p);
	return res == 0;
}

int bmx_hydro_pwhash_derive_static_key(uint8_t * staticKey, size_t staticKeyLen, uint8_t * stored, BBString * password, BBString * context, uint8_t * masterKey, uint64_t opsLimit, size_t memLimit, int threads) {
	char * p = bbStringToUTF8String(password);
	char * c = bbStringToUTF8String(context);
	int res = hydro_pwhash_derive_static_key(staticKey, staticKeyLen, stored, p, strlen(p), c, masterKey, opsLimit, memLimit, threads);
	hydro_memzero(p, strlen(p));
	bbMemFree(p);
	bbMemFree(c);
	return res == 0;
}

int bmx_hydro_pwhash_reencrypt(uint8_t * stored, uint8_t * masterKey, uint8_t * newMasterKey) {
	return hydro_pwhash_reencrypt(stored, masterKey, newMasterKey) == 0;
}

int bmx_hydro_pwhash_upgrade(uint8_t * stored, uint8_t * masterKey, uint64_t opsLimit, size_t memLimit, int threads) {
	return hydro_pwhash_upgrade(stored, masterKey, opsLimit, memLimit, threads) == 0;
}

int bmx_hydro_pwhash_deterministic(uint8_t * h, size_t hLen, BBString * password, BBString * context, uint8_t * masterKey, uint64_t opsLimit, size_t memLimit, int threads) {
	char * p = bbStringToUTF8String(password);
	char * c = bbStringToUTF8String(context);
	int res = hydro_pwhash_deterministic(h, hLen, p, strlen(p), c, masterKey, opsLimit, memLimit, threads);
	hydro_memzero(p, strlen(p));
	bbMemFree(p);
	bbMemFree(c);
	return res == 0;
}

// --------------------------------------------------------

void bmx_hydro_sign_keygen(uint8_t * secretKey, uint8_t * publicKey) {
	hydro_sign_keypair key_pair;
	hydro_sign_keygen(&key_pair);
	memcpy(secretKey, key_pair.sk, hydro_sign_SECRETKEYBYTES);
	memcpy(publicKey, key_pair.pk, hydro_sign_PUBLICKEYBYTES);
}

int bmx_hydro_sign_create(uint8_t * csig, void * m, size_t mLen, BBString * context, uint8_t * sk) {
	char * c = bbStringToUTF8String(context);
	int res = hydro_sign_create(csig, m, mLen, c, sk);
	bbMemFree(c);
	return res == 0;
}

int bmx_hydro_sign_verify(uint8_t * csig, void * m, size_t mLen, BBString * context, uint8_t * pk) {
	char * c = bbStringToUTF8String(context);
	int res = hydro_sign_verify(csig, m, mLen, c, pk);
	bbMemFree(c);
	return res == 0;
}

hydro_sign_state * bmx_hydro_sign_init(BBString * context) {
	char * c = bbStringToUTF8String(context);
	hydro_sign_state * state = malloc(sizeof(hydro_sign_state));
	int res = hydro_sign_init(state, c);
	bbMemFree(c);
	return state;
}

void bmx_hydro_sign_state_free(hydro_sign_state * state) {
	free(state);
}

int bmx_hydro_sign_update(hydro_sign_state * state, const void * m, size_t mLen) {
	return hydro_sign_update(state, m, mLen) == 0;
}

int bmx_hydro_sign_final_create(hydro_sign_state * state, uint8_t * csig, uint8_t * sk) {
	return hydro_sign_final_create(state, csig, sk) == 0;
}

int bmx_hydro_sign_final_verify(hydro_sign_state * state, uint8_t * csig, uint8_t * pk) {
	return hydro_sign_final_verify(state, csig, pk) == 0;
}

// --------------------------------------------------------

void bmx_hydro_kx_keygen(uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_keypair key_pair;
	hydro_kx_keygen(&key_pair);
	memcpy(secretKey, key_pair.sk, hydro_kx_SECRETKEYBYTES);
	memcpy(publicKey, key_pair.pk, hydro_kx_PUBLICKEYBYTES);
}

int bmx_hydro_kx_n_1(uint8_t * rx, uint8_t * tx, uint8_t * packet1, uint8_t * preSharedKey, uint8_t * publicKey) {
	hydro_kx_session_keypair session;
	
	int res = hydro_kx_n_1(&session, packet1, preSharedKey, publicKey);
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);
	
	return res == 0;
}

int bmx_hydro_kx_n_2(uint8_t * rx, uint8_t * tx, uint8_t * packet1, uint8_t * preSharedKey, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_session_keypair session;

	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);
	
	int res = hydro_kx_n_2(&session, packet1, preSharedKey, &kp);
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);
	
	return res == 0;
}

hydro_kx_state * bmx_hydro_kx_state_new() {
	hydro_kx_state * state = calloc(1, sizeof(hydro_kx_state));
	return state;
}

void bmx_hydro_kx_state_free(hydro_kx_state * state) {
	free(state);
}

int bmx_hydro_kx_kk_1(hydro_kx_state * state, uint8_t * packet1, uint8_t * peerPublicKey, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);

	return hydro_kx_kk_1(state, packet1, peerPublicKey, &kp) == 0;
}

int bmx_hydro_kx_kk_2(uint8_t * rx, uint8_t * tx, uint8_t * packet2, uint8_t * packet1, uint8_t * peerPublicKey, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_session_keypair session;

	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);

	int res = hydro_kx_kk_2(&session, packet2, packet1, peerPublicKey, &kp);
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);

	return res == 0;
}

int bmx_hydro_kx_kk_3(hydro_kx_state * state, uint8_t * rx, uint8_t * tx, uint8_t * packet2, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_session_keypair session;

	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);

	int res = hydro_kx_kk_3(state, &session, packet2, &kp);
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);

	return res == 0;
}

int bmx_hydro_kx_xx_1(hydro_kx_state * state, uint8_t * packet1, uint8_t * preSharedKey) {
	return hydro_kx_xx_1(state, packet1, preSharedKey) == 0;
}

int bmx_hydro_kx_xx_2(hydro_kx_state * state, uint8_t * packet2, uint8_t * packet1, uint8_t * preSharedKey, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);

	return hydro_kx_xx_2(state, packet2, packet1, preSharedKey, &kp) == 0;
}

int bmx_hydro_kx_xx_3(hydro_kx_state * state, uint8_t * rx, uint8_t * tx, uint8_t * packet3, uint8_t * peerPublicKey, uint8_t * packet2, uint8_t * preSharedKey, uint8_t * secretKey, uint8_t * publicKey) {
	hydro_kx_session_keypair session;

	hydro_kx_keypair kp;
	memcpy(kp.pk, publicKey, hydro_kx_PUBLICKEYBYTES);
	memcpy(kp.sk, secretKey, hydro_kx_SECRETKEYBYTES);

	int res = hydro_kx_xx_3(state, &session, packet3, peerPublicKey, packet2, preSharedKey, &kp);
	
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);

	return res == 0;
}

int bmx_hydro_kx_xx_4(hydro_kx_state * state, uint8_t * rx, uint8_t * tx, uint8_t * peerPublicKey, uint8_t * packet3, uint8_t * preSharedKey) {
	hydro_kx_session_keypair session;

	int res = hydro_kx_xx_4(state, &session, peerPublicKey, packet3, preSharedKey);
	
	memcpy(rx, session.rx, hydro_kx_SESSIONKEYBYTES);
	memcpy(tx, session.tx, hydro_kx_SESSIONKEYBYTES);

	return res == 0;
}
