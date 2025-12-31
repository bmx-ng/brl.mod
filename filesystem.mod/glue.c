/*
 Copyright (c) 2022-2025 Bruce A Henderson

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

        memset(&attributes, 0, sizeof(attributes));

        memcpy(attributes.name, fullpath, 8192 * 2);
        attributes.depth = (short)(depth + 1);
        attributes.size = data.nFileSizeLow + (BBUInt64)data.nFileSizeHigh * 0xFFFFFFFFULL;
        attributes.creationTime = (int)((((BBInt64)(data.ftCreationTime.dwHighDateTime)<<32) | (BBInt64)(data.ftCreationTime.dwLowDateTime)) / WINDOWS_TICK - SEC_TO_UNIX_EPOCH);
        attributes.modifiedTime = (int)((((BBInt64)(data.ftLastWriteTime.dwHighDateTime)<<32) | (BBInt64)(data.ftLastWriteTime.dwLowDateTime)) / WINDOWS_TICK - SEC_TO_UNIX_EPOCH);

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

        if (res == WALKRESULT_SKIP_SIBLINGS) {
            /* stop iterating this directory */
            break;
        }

        if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {

            if (res == WALKRESULT_SKIP_SUBTREE) {
                /* do not descend */
                continue;
            }
            
            /* maxDepth: don't descend further once child dir is at maxDepth */
            if (maxDepth && (depth + 1) >= maxDepth) {
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

static const struct SFileAttributes emptyAttributes;

extern int brl_filesystem__walkFile(BBObject * fileWalker, struct SFileAttributes * attributes);

typedef int (*WalkFile)(BBObject * walker, struct SFileAttributes * attributes);

static int get_parent_dir_from_ent(const FTSENT *e, char *out, size_t outsz) {
    if (!e || !e->fts_path || outsz == 0) return 0;

    size_t pathlen = (size_t)e->fts_pathlen;
    size_t namelen = (size_t)e->fts_namelen;

    if (pathlen == 0 || pathlen >= outsz) {
        /* If the fts path is too long for our buffer, truncate safely.
            (You may prefer to treat as failure instead.) */
        pathlen = outsz - 1;
    }

    /* parent prefix includes trailing slash */
    if (pathlen <= namelen) {
        out[0] = 0;
        return 0;
    }

    size_t parentLen = pathlen - namelen;

    /* Trim trailing slashes (keep "/" as-is) */
    while (parentLen > 1 && e->fts_path[parentLen - 1] == '/') {
        parentLen--;
    }

    if (parentLen >= outsz) parentLen = outsz - 1;

    memcpy(out, e->fts_path, parentLen);
    out[parentLen] = 0;
    return 1;
}

int bmx_filesystem_walkfiletree(BBString * path, WalkFile walkFile, BBObject * walker, int options, int maxDepth) {
    FTSENT * ent = NULL;

    char * p = (char*)bbStringToUTF8String(path);

    char * paths[2];
    paths[0] = p;
    paths[1] = NULL;

    struct SFileAttributes attributes;

    int opts = FTS_NOCHDIR;

    if (options == FOLLOW_LINKS) {
        opts |= FTS_COMFOLLOW | FTS_LOGICAL;
    } else {
        opts |= FTS_PHYSICAL;
    }

    FTS * fts = fts_open(paths, opts, NULL);

    if (fts == NULL) {
        return 0;
    }

    char skipSiblingsParentPath[8192];
    skipSiblingsParentPath[0] = 0;
    int skipSiblingsLevel = -1;

    while( (ent = fts_read(fts)) != NULL) {

        /* Skip post-order directory visits */
        if (ent->fts_info == FTS_DP) {
            continue;
        }

        /* If we are skipping siblings, skip any entries that are siblings at the same level
        under the same parent directory. */
        if (skipSiblingsLevel >= 0) {

            /* Once we move above that level, we're no longer in that directory. */
            if (ent->fts_level < skipSiblingsLevel) {
                skipSiblingsLevel = -1;
                skipSiblingsParentPath[0] = 0;
            } else if (ent->fts_level == skipSiblingsLevel) {
                 char parentPath[8192];
                parentPath[0] = 0;

                get_parent_dir_from_ent(ent, parentPath, sizeof(parentPath));

                if (skipSiblingsParentPath[0] && parentPath[0] &&
                    strcmp(parentPath, skipSiblingsParentPath) == 0) {

                    /* Skip this sibling (and prevent descending into it if it's a directory). */
                    if (ent->fts_info == FTS_D) {
                        fts_set(fts, ent, FTS_SKIP);
                    }
                    continue;
                }
            }
        }

        /* Enforce maxDepth: if we're at/over depth on a directory, skip descending */
        if (maxDepth && ent->fts_level > maxDepth) {
            if (ent->fts_info == FTS_D) {
                fts_set(fts, ent, FTS_SKIP);
            }
            continue;
        }

        memset(&attributes, 0, sizeof(attributes));

        snprintf(attributes.name, 8192, "%s", ent->fts_path);
        attributes.depth = (short)ent->fts_level;

        if (ent->fts_statp != NULL) {
            attributes.creationTime = (int)ent->fts_statp->st_ctime;
            attributes.modifiedTime = (int)ent->fts_statp->st_mtime;
        }

        switch (ent->fts_info) {
            case FTS_D:
                attributes.fileType = FILETYPE_DIR;
                break;
            case FTS_F:
                attributes.fileType = FILETYPE_FILE;
                if (ent->fts_statp != NULL) {
                    attributes.size = (BBUInt64)ent->fts_statp->st_size;
                }
                break;
            case FTS_SL:
            case FTS_SLNONE:
                attributes.fileType = FILETYPE_SYM;
                break;
            default:
                break;
        }

        int res = brl_filesystem__walkFile(walker, &attributes);

        if (res == WALKRESULT_TERMINATE) {
            break;
        }

        if (res == WALKRESULT_SKIP_SUBTREE) {
            if (ent->fts_info == FTS_D) {
                fts_set(fts, ent, FTS_SKIP);
            }
            continue;
        }

        if (res == WALKRESULT_SKIP_SIBLINGS) {
            skipSiblingsLevel = ent->fts_level;

            /* Record the *containing directory* of this entry, based on its full path. */
            if (!get_parent_dir_from_ent(ent, skipSiblingsParentPath, sizeof(skipSiblingsParentPath))) {
                skipSiblingsParentPath[0] = 0;
            }

            continue;
        }        
    }

    fts_close(fts);
    
    return 0;
}


#endif
