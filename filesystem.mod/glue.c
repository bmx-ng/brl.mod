/*
 Copyright (c) 2022 Bruce A Henderson

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
#include <brl.mod/blitz.mod/blitz.h>

#define WALKRESULT_OK 0
#define WALKRESULT_TERMINATE 1
#define WALKRESULT_SKIP_SUBTREE 2
#define WALKRESULT_SKIP_SIBLINGS 3

#define FILETYPE_FILE 1
#define FILETYPE_DIR 2
#define FILETYPE_SYM 3

#define FOLLOW_LINKS 1

#if _WIN32

#define WINDOWS_TICK 10000000
#define SEC_TO_UNIX_EPOCH 11644473600LL

struct SFileAttributes {
	BBChar name[8192];
    short fileType;
	short depth;
	BBUInt64 size;
	int creationTime;
	int modifiedTime;
};

extern int brl_filesystem__walkFile(BBObject * fileWalker, struct SFileAttributes * attributes);

typedef int (*WalkFile)(BBObject * walker, struct SFileAttributes * attributes);

int bmx_filesystem_walkfilerecurse(BBObject * walker, BBChar * dir, int depth, int maxDepth, int options) {

    int res = WALKRESULT_OK;

    WIN32_FIND_DATAW data;
    HANDLE hnd = INVALID_HANDLE_VALUE;

    struct SFileAttributes attributes;

    BBChar p[8192];
    _snwprintf(p, 8192, L"%s\\*", dir);

    hnd = FindFirstFileW(p, &data);

    if (hnd == INVALID_HANDLE_VALUE) {
        return res;
    }

    do {
        // skip . and ..
        if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            if (wcscmp(data.cFileName, L".") == 0 || wcscmp(data.cFileName, L"..") == 0) {
                continue;
            }
        }

        BBChar fullpath[8192];
        _snwprintf(fullpath, 8192, L"%s/%s", dir, data.cFileName);

        memcpy(attributes.name, fullpath, 8192 * 2);
        attributes.size = data.nFileSizeLow + (BBUInt64)data.nFileSizeHigh * 0xFFFFFFFFULL;
        attributes.creationTime = (int)((((BBInt64)(data.ftCreationTime.dwHighDateTime)<<32) | (BBInt64)(data.ftCreationTime.dwLowDateTime)) / WINDOWS_TICK - SEC_TO_UNIX_EPOCH) / 1000;
        attributes.modifiedTime = (int)((((BBInt64)(data.ftLastWriteTime.dwHighDateTime)<<32) | (BBInt64)(data.ftLastWriteTime.dwLowDateTime)) / WINDOWS_TICK - SEC_TO_UNIX_EPOCH) / 1000;

        if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            attributes.fileType = FILETYPE_DIR;
        } else if (data.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT) {
            attributes.fileType = FILETYPE_SYM;
        } else {
            attributes.fileType = FILETYPE_FILE;
        }

        res = brl_filesystem__walkFile(walker, &attributes);

        if (res == WALKRESULT_TERMINATE) {
            break;
        }

        if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            if (maxDepth && maxDepth < depth + 1) {
                continue;
            }

            if (options != FOLLOW_LINKS && (data.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)) {
                continue;
            }

            res = bmx_filesystem_walkfilerecurse(walker, fullpath, depth + 1, maxDepth, options);
        }

        if (res == WALKRESULT_TERMINATE) {
            break;
        }
    } while (FindNextFileW(hnd, &data) != 0);

    FindClose(hnd);

    return res;
}


int bmx_filesystem_walkfiletree(BBString * path, WalkFile walkFile, BBObject * walker, int options, int maxDepth) {

    BBChar p[8192];
    _snwprintf(p, 8192, L"%s", bbStringToWString(path));

    return bmx_filesystem_walkfilerecurse(walker, p, 0, maxDepth, options);
}

#else

#include<sys/types.h>
#include<sys/stat.h>
#include<fts.h>

struct SFileAttributes {
	char name[8192];
    short fileType;
	short depth;
	BBUInt64 size;
	int creationTime;
	int modifiedTime;
};

extern int brl_filesystem__walkFile(BBObject * fileWalker, struct SFileAttributes * attributes);

typedef int (*WalkFile)(BBObject * walker, struct SFileAttributes * attributes);

int bmx_filesystem_walkfiletree(BBString * path, WalkFile walkFile, BBObject * walker, int options, int maxDepth) {
    FTSENT * child = NULL;
    FTSENT * parent = NULL;

    char * p = (char*)bbStringToUTF8String(path);

    char * paths[2];
    paths[0] = p;
    paths[1] = NULL;

    struct SFileAttributes attributes;

    int opts = FTS_NOCHDIR;

    if (options == FOLLOW_LINKS) {
        opts += FTS_COMFOLLOW | FTS_LOGICAL;
    }

    FTS * fts = fts_open(paths, opts, NULL);

    if (fts != NULL) {
        while( (parent = fts_read(fts)) != NULL) {
            int res = 0;

            child = fts_children(fts,0);

            while (child != NULL) {

                if (maxDepth && maxDepth < child->fts_level) {
                    break;
                }

                snprintf(attributes.name, 8192, "%s%s", child->fts_path, child->fts_name);
                if (child->fts_statp != NULL) {
                    attributes.size = child->fts_statp->st_size;
                    attributes.creationTime = child->fts_statp->st_ctime;
                    attributes.modifiedTime = child->fts_statp->st_mtime;
                }

                switch (child->fts_info) {
                    case FTS_D:
                        attributes.fileType = FILETYPE_DIR;
                        break;
                    case FTS_F:
                        attributes.fileType = FILETYPE_FILE;
                        break;
                    case FTS_SL:
                    case FTS_SLNONE:
                        attributes.fileType = FILETYPE_SYM;
                        break;
                }

                res = brl_filesystem__walkFile(walker, &attributes);

                if (res == WALKRESULT_TERMINATE) {
                    break;
                }

                child = child->fts_link;
            }

            if (res == WALKRESULT_TERMINATE) {
                break;
             }
        }

        fts_close(fts);
    }
    return 0;
}


#endif
