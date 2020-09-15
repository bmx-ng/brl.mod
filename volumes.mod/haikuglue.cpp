/*
  Copyright (c) 2010-2020 Bruce A Henderson

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation files
  (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge,
  publish, distribute, sublicense, and/or sell copies of the Software,
  and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software. 

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

#include <FindDirectory.h>
#include <Path.h>
#include <VolumeRoster.h>
#include <StorageDefs.h>
#include <brl.mod/blitz.mod/blitz.h>

extern "C" {

BBString * bmx_volumes_getdir(directory_which which) {
	BPath path;
	status_t res = find_directory(which, &path);
	if (res == 0) {
		return bbStringFromUTF8String(path.Path());
	} else {
		return &bbEmptyString;
	}
}

BVolume * bmx_volumes_bvolume_new(BBString * name) {
	char * n = bbStringToUTF8String(name);
	BVolumeRoster roster;
	BVolume vol;
	while (roster.GetNextVolume(&vol) == B_OK) {
		char vname[B_FILE_NAME_LENGTH];
		vol.GetName(vname);
		if (strcmp(n, vname) == 0) {
			bbMemFree(n);
			return new BVolume(vol);
		}
	}
	bbMemFree(n);
	return NULL;
}

BBString * bmx_volumes_bvolume_name(BVolume * vol) {
	char name[B_FILE_NAME_LENGTH];
	if (vol->GetName(name) == B_OK) {
		return bbStringFromUTF8String(name);
	}
	else {
		return &bbEmptyString;
	}
}

BBLONG bmx_volumes_bvolume_size(BVolume * vol) {
	return vol->Capacity();
}

BBLONG bmx_volumes_bvolume_freebytes(BVolume * vol) {
	return vol->FreeBytes();
}

void bmx_volumes_bvolume_free(BVolume * vol) {
	delete vol;
}

BVolumeRoster * bmx_volumes_list_init() {
	return new BVolumeRoster();
}

BVolume * bmx_volumes_next_vol(BVolumeRoster * rost) {
	BVolume vol;
	if (rost->GetNextVolume(&vol) == B_OK) {
		return new BVolume(vol);
	}
	return NULL;
}

void bmx_volumes_list_free(BVolumeRoster * rost) {
	delete rost;
}

}
