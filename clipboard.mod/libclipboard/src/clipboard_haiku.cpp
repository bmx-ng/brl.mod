
#include <Clipboard.h>

#include "libclipboard.h"

#ifdef LIBCLIPBOARD_BUILD_HAIKU

extern "C" {

/** Haiku Implementation of the clipboard context **/
struct clipboard_c {
	BClipboard * bcb;

    /** malloc **/
    clipboard_malloc_fn malloc;
    /** calloc **/
    clipboard_calloc_fn calloc;
    /** realloc **/
    clipboard_realloc_fn realloc;
    /** free **/
    clipboard_free_fn free;
};

LCB_API clipboard_c *LCB_CC clipboard_new(clipboard_opts *cb_opts) {
	if (!be_app) {
		return NULL;
	}
	
	clipboard_opts defaults = {};
	if (cb_opts == NULL) {
		cb_opts = &defaults;
	}

	clipboard_calloc_fn calloc_fn = cb_opts->user_calloc_fn ? cb_opts->user_calloc_fn : calloc;
	clipboard_c *cb = (clipboard_c*)calloc_fn(1, sizeof(clipboard_c));
	if (cb == NULL) {
		return NULL;
	}
	LCB_SET_ALLOCATORS(cb, cb_opts);

	cb->bcb = new BClipboard("system");
	
	return cb;
}

LCB_API void LCB_CC clipboard_free(clipboard_c *cb) {
	if (cb == NULL) {
		return;
	}
	
	delete cb->bcb;

	cb->free(cb);
}

LCB_API void LCB_CC clipboard_clear(clipboard_c *cb, clipboard_mode mode) {
    if (cb == NULL || cb->bcb == NULL) {
        return;
    }

	cb->bcb->Clear();
}

LCB_API bool LCB_CC clipboard_set_text_ex(clipboard_c *cb, const char *src, int length, clipboard_mode mode) {
	if (cb == NULL || src == NULL || length == 0) {
		return false;
	}

	if (cb->bcb->Lock()) {
		cb->bcb->Clear();
		
		BMessage *clip = cb->bcb->Data();
		clip->AddData("text/plain", B_MIME_TYPE, src, length);
		status_t status = cb->bcb->Commit();
		
		cb->bcb->Unlock();
		
		return status == B_OK;
		
	} else {
		return false;
	}
}

LCB_API char LCB_CC *clipboard_text_ex(clipboard_c *cb, int *length, clipboard_mode mode) {
	if (cb == NULL) {
		return NULL;
	}
	
	if (be_clipboard->Lock()) {
		BMessage *clip = cb->bcb->Data();
		
		const char * s;
		ssize_t len;
		clip->FindData("text/plain", B_MIME_TYPE, (const void **)&s, &len);
		
		char * ret = (char*)cb->malloc(len + 1);
		if (ret != NULL) {
			memcpy(ret, s, len);
			ret[len] = '\0';

			if (length) {
				*length = len;
			}
		}
		return ret;
	}
	return NULL;
}

LCB_API bool LCB_CC clipboard_has_ownership(clipboard_c *cb, clipboard_mode mode) {
	return false;
}

}

#endif /* LIBCLIPBOARD_BUILD_HAIKU */
