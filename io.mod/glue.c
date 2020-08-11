/*
  Copyright (c) 2020 Bruce A Henderson
  
  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
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
#include "physfs.h"
#include "brl.mod/blitz.mod/blitz.h"

struct MaxFilesEnumeration {
	char ** files;
	int index;
};

int bmx_PHYSFS_init() {
	return PHYSFS_init(bbArgv0);
}

BBString * bmx_PHYSFS_getLastError() {
	int code = PHYSFS_getLastErrorCode();
	if (code == PHYSFS_ERR_OK) {
		return &bbEmptyString;
	}
	return bbStringFromUTF8String(PHYSFS_getErrorByCode(code));
}

int bmx_PHYSFS_mount(BBString * newDir, BBString * mountPoint, int appendToPath) {
	char dbuf[1024];
	size_t dlen = 1024;
	bbStringToUTF8StringBuffer(newDir, dbuf, &dlen);
	char mbuf[256];
	size_t mlen = 256;
	if (mountPoint != &bbEmptyString) {
		bbStringToUTF8StringBuffer(mountPoint, mbuf, &mlen);
		return PHYSFS_mount(dbuf, mbuf, appendToPath);
	}
	return PHYSFS_mount(dbuf, NULL, appendToPath);
}

BBString * bmx_PHYSFS_getBaseDir() {
	return bbStringFromUTF8String(PHYSFS_getBaseDir());
}

BBString * bmx_PHYSFS_getPrefDir(BBString * org, BBString * app) {
	char obuf[128];
	size_t olen = 128;
	bbStringToUTF8StringBuffer(org, obuf, &olen);

	char abuf[128];
	size_t alen = 128;
	bbStringToUTF8StringBuffer(app, abuf, &alen);

	return bbStringFromUTF8String(PHYSFS_getPrefDir(obuf, abuf));
}

int bmx_PHYSFS_mountMemory(void * dirPtr, int dirLen, BBString * newDir, BBString * mountPoint, int appendToPath) {
	char dbuf[1024];
	size_t dlen = 1024;
	bbStringToUTF8StringBuffer(newDir, dbuf, &dlen);
	char mbuf[256];
	size_t mlen = 256;
	if (mountPoint != &bbEmptyString) {
		bbStringToUTF8StringBuffer(mountPoint, mbuf, &mlen);
		return PHYSFS_mountMemory(dirPtr, dirLen, NULL, dbuf, mbuf, appendToPath);
	}
	return PHYSFS_mountMemory(dirPtr, dirLen, NULL, dbuf, NULL, appendToPath);
}

PHYSFS_File * bmx_PHYSFS_openAppend(BBString * path) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(path, buf, &len);
	return PHYSFS_openAppend(buf);
}

PHYSFS_File * bmx_PHYSFS_openWrite(BBString * path) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(path, buf, &len);
	return PHYSFS_openWrite(buf);
}

PHYSFS_File * bmx_PHYSFS_openRead(BBString * path) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(path, buf, &len);
	return PHYSFS_openRead(buf);
}

int bmx_PHYSFS_stat(BBString * filename, PHYSFS_Stat * stat) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(filename, buf, &len);
	return PHYSFS_stat(buf, stat);
}

int bmx_PHYSFS_delete(BBString * filename) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(filename, buf, &len);
	return PHYSFS_delete(buf);
}

int bmx_PHYSFS_mkdir(BBString * dirName) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(dirName, buf, &len);
	return PHYSFS_mkdir(buf);
}

struct MaxFilesEnumeration * bmx_blitzio_readdir(BBString * dir) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(dir, buf, &len);
	
	char ** files = PHYSFS_enumerateFiles(buf);
	
	if (files == NULL)
		return NULL;

	struct MaxFilesEnumeration * mfe = malloc(sizeof(struct MaxFilesEnumeration));
	mfe->files = files;
	mfe->index = 0;
	
	return mfe;
}

BBString * bmx_blitzio_nextFile(struct MaxFilesEnumeration * mfe) {
	char * f = mfe->files[mfe->index];
	if (f) {
		mfe->index++;
		return bbStringFromUTF8String(f);
	}
	return &bbEmptyString;
}

void bmx_blitzio_closeDir(struct MaxFilesEnumeration * mfe) {
	PHYSFS_freeList(mfe->files);
	free(mfe);
}

int bmx_PHYSFS_setWriteDir(BBString * newDir) {
	char buf[1024];
	size_t len = 1024;
	bbStringToUTF8StringBuffer(newDir, buf, &len);
	return PHYSFS_setWriteDir(buf);
}
