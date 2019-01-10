/*
Copyright 2019 Bruce A Henderson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/ 

#include "pub.mod/mxml.mod/mxml/mxml.h"
#include "brl.mod/blitz.mod/blitz.h"

extern int brl_xml__xmlstream_read(void *, void *, unsigned int);
extern int brl_xml__xmlstream_write(void *, const void *, unsigned int);

static int bmx_mxml_stream_read(void * ctxt, void *buf, unsigned int length) {
	return brl_xml__xmlstream_read(ctxt, buf, length);
}

static int bmx_mxml_stream_write(void * ctxt, const void *buf, unsigned int length) {
	return brl_xml__xmlstream_write(ctxt, buf, length);
}

mxml_node_t * bmx_mxmlNewXML(BBString * version) {
	char * v = bbStringToUTF8String(version);
	mxml_node_t * node = mxmlNewXML(v);
	bbMemFree(v);
	return node;
}

mxml_node_t * bmx_mxmlNewElement(mxml_node_t * parent, BBString * name) {
	char * n = bbStringToUTF8String(name);
	if (!parent) {
		parent = MXML_NO_PARENT;
	}
	mxml_node_t * node = mxmlNewElement(parent, n);
	bbMemFree(n);
	return node;
}

void bmx_mxmlDelete(mxml_node_t * node) {
	mxmlDelete(node);
}

mxml_node_t * bmx_mxmlGetRootElement(mxml_node_t * node) {
	mxml_node_t * n = mxmlWalkNext(node, node, MXML_DESCEND);
	while (n && mxmlGetType(n) != MXML_ELEMENT) {
		n = mxmlWalkNext(n, node, MXML_DESCEND);
	}
	return n;
}

mxml_node_t * bmx_mxmlSetRootElement(mxml_node_t * parent, mxml_node_t * root) {
	mxml_node_t * r = bmx_mxmlGetRootElement(parent);
	if (r) {
		mxmlRemove(r);
	}
	mxmlAdd(parent, MXML_ADD_AFTER, MXML_ADD_TO_PARENT, root);
	return r;
}

void bmx_mxmlAdd(mxml_node_t * parent, int where, mxml_node_t * child, mxml_node_t * node) {
	if (!child) {
		child = MXML_ADD_TO_PARENT;
	}
	mxmlAdd(parent, where, child, node);
}

BBString * bmx_mxmlGetElement(mxml_node_t * node) {
	char * n = mxmlGetElement(node);
	if (n) {
		return bbStringFromUTF8String(n);
	}
	
	return &bbEmptyString;
}

int bmx_mxmlSaveStdout(mxml_node_t * node) {
	return mxmlSaveFile(node, stdout, MXML_NO_CALLBACK);
}

void bmx_mxmlSetContent(mxml_node_t * node, BBString * content) {
	mxml_node_t * child = mxmlGetFirstChild(node);
	while (child != NULL) {
		mxml_node_t * txt = NULL;
		if (mxmlGetType(child) == MXML_TEXT) {
			txt = child;
		}
		child = mxmlGetNextSibling(child);
		if (txt) {
			mxmlDelete(txt);
		}
	}
	char * c = bbStringToUTF8String(content);
	mxmlNewText(node, 0, c);
	bbMemFree(c);
}

BBString * bmx_mxmlSaveString(mxml_node_t * node) {
	char tmp[1];
	int size = mxmlSaveString(node, tmp, 1, MXML_NO_CALLBACK);
	char * buf = bbMemAlloc(size);
	mxmlSaveString(node, buf, size, MXML_NO_CALLBACK);
	buf[size-1] = 0;
	BBString * s = bbStringFromUTF8String(buf);
	bbMemFree(buf);
	return s;
}

void bmx_mxmlElementSetAttr(mxml_node_t * node, BBString * name, BBString * value) {
	char * n = bbStringToUTF8String(name);
	char * v = bbStringToUTF8String(value);
	mxmlElementSetAttr(node, n, v);
	bbMemFree(v);
	bbMemFree(n);
}

BBString * bmx_mxmlElementGetAttr(mxml_node_t * node, BBString * name) {
	char * n = bbStringToUTF8String(name);
	char * v = mxmlElementGetAttr(node, n);
	bbMemFree(n);
	if (v) {
		return bbStringFromUTF8String(v);
	}
	return &bbEmptyString;
}

void bmx_mxmlElementDeleteAttr(mxml_node_t * node, BBString * name) {
	char * n = bbStringToUTF8String(name);
	mxmlElementDeleteAttr(node, n);
	bbMemFree(n);
}

int bmx_mxmlElementHasAttr(mxml_node_t * node, BBString * name) {
	char * n = bbStringToUTF8String(name);
	char * v = mxmlElementGetAttr(node, n);
	bbMemFree(n);
	return v != NULL;
}

void bmx_mxmlSetElement(mxml_node_t * node, BBString * name) {
	char * n = bbStringToUTF8String(name);
	mxmlSetElement(node, n);
	bbMemFree(n);
}

int bmx_mxmlElementGetAttrCount(mxml_node_t * node) {
	return mxmlElementGetAttrCount(node);
}

BBString * bmx_mxmlElementGetAttrByIndex(mxml_node_t * node, int index, BBString ** name) {
	char * n;
	char * v = mxmlElementGetAttrByIndex(node, index, &n);
	if (v) {
		*name = bbStringFromUTF8String(n);
		return bbStringFromUTF8String(v);
	} else {
		*name = &bbEmptyString;
		return &bbEmptyString;
	}
}

mxml_node_t * bmx_mxmlLoadStream(BBObject * stream) {
	return mxmlLoadStream(NULL, bmx_mxml_stream_read, stream, NULL);
}

mxml_node_t * bmx_mxmlWalkNext(mxml_node_t * node, mxml_node_t * top, int descend) {
	return mxmlWalkNext(node, top, descend);
}

int bmx_mxmlGetType(mxml_node_t * node) {
	return mxmlGetType(node);
}

void bmx_mxmlAddContent(mxml_node_t * node, BBString * content) {
	char * c = bbStringToUTF8String(content);
	mxmlNewText(node, 0, c);
	bbMemFree(c);
}

mxml_node_t * bmx_mxmlGetParent(mxml_node_t * node) {
	return mxmlGetParent(node);
}

mxml_node_t * bmx_mxmlGetFirstChild(mxml_node_t * node) {
	mxml_node_t * n = mxmlGetFirstChild(node);
	while (n && mxmlGetType(n) != MXML_ELEMENT) {
		n = mxmlGetNextSibling(n);
	}
	return n;
}

mxml_node_t * bmx_mxmlGetLastChild(mxml_node_t * node) {
	mxml_node_t * n = mxmlGetLastChild(node);
	while (n && mxmlGetType(n) != MXML_ELEMENT) {
		n = mxmlGetPrevSibling(n);
	}
	return n;
}

mxml_node_t * bmx_mxmlGetNextSibling(mxml_node_t * node) {
	mxml_node_t * n = mxmlGetNextSibling(node);
	while (n && mxmlGetType(n) != MXML_ELEMENT) {
		n = mxmlGetNextSibling(n);
	}
	return n;
}

mxml_node_t * bmx_mxmlGetPrevSibling(mxml_node_t * node) {
	mxml_node_t * n = mxmlGetPrevSibling(node);
	while (n && mxmlGetType(n) != MXML_ELEMENT) {
		n = mxmlGetPrevSibling(n);
	}
	return n;
}

int bmx_mxmlSaveStream(mxml_node_t * node, BBObject * stream) {
	return mxmlSaveStream(node, bmx_mxml_stream_write, stream, NULL);
}

struct _string_buf {
	BBString * txt;
	int txtOffset;
	char padding[2];
	int padCount;
};

// direct string to utf-8 stream
static int bmx_mxml_string_read(void * ctxt, void *buf, unsigned int length) {
	struct _string_buf * data = (struct _string_buf*)ctxt;

	int txtLength = data->txt->length;
	int count = 0;
	
	unsigned short *p = data->txt->buf + data->txtOffset;
	char *q = buf;
	char *a = data->padding;
	
	while (data->txtOffset < txtLength && count < length) {
		
		while (data->padCount > 0) {
			*q++ = a[--data->padCount];
			count++;
		}
		
		unsigned int c=*p++;
		if( c<0x80 ){
			*q++ = c;
			count++;
		}else if( c<0x800 ){
			*q++ = 0xc0|(c>>6);
			if (++count < length) {
				*q++ = 0x80|(c&0x3f);
				count++;
			} else {
				data->padding[data->padCount++] = 0x80|(c&0x3f);
				continue;
			}
		}else{
			*q++ = 0xe0|(c>>12);
			if (++count < length) {
				*q++ = 0x80|((c>>6)&0x3f);
				
				if (++count < length) {
					*q++ = 0x80|(c&0x3f);
					count++;
				} else {
					data->padding[data->padCount++] = 0x80|(c&0x3f);
					continue;
				}
			} else {
				data->padding[1] = 0x80|((c>>6)&0x3f);
				data->padding[0] = 0x80|(c&0x3f);
				data->padCount = 2;
				continue;
			}
		}
		data->txtOffset++;
	}
	return count;
}

mxml_node_t * bmx_mxmlLoadString(BBString * txt) {
	if (txt == &bbEmptyString) {
		return NULL;
	}
	
	struct _string_buf buf = {txt = txt};

	return mxmlLoadStream(NULL, bmx_mxml_string_read, &buf, NULL);
}
