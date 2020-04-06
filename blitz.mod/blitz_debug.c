
#include "blitz.h"

void bbCAssertEx(){
	bbExThrowCString( "C Assert failed" );
}

static void debugNop(){
}

static void debugUnhandledEx( BBObject *ex ){
	bbWriteStderr( ex->clas->ToString( ex ) );
	exit(-1);
}

void (*bbOnDebugStop)()=debugNop;
void (*bbOnDebugLog)( BBString *str )=debugNop;
void (*bbOnDebugEnterStm)( BBDebugStm *stm )=debugNop;
void (*bbOnDebugEnterScope)( BBDebugScope *scope )=debugNop;
void (*bbOnDebugLeaveScope)()=debugNop;
void (*bbOnDebugPushExState)()=debugNop;
void (*bbOnDebugPopExState)()=debugNop;

void (*bbOnDebugUnhandledEx)( BBObject *ex )=debugUnhandledEx;

static unsigned int bpCount = 0;
static unsigned int bpSize = 0;
static BBSource * sources = 0;

static void swap(BBSource* a, BBSource* b) {
	BBSource s = *a;
	*a = *b;
	*b = s;
}

static int partition (BBSource arr[], int low, int high) {
	BBULONG pivot = arr[high].id;
	int i = (low - 1);
	for (int j = low; j <= high- 1; j++) {
		if (arr[j].id < pivot) {
			i++;
			swap(&arr[i], &arr[j]);
		}
	}
	swap(&arr[i + 1], &arr[high]);
	return (i + 1);
}

static void sort(BBSource arr[], int low, int high) {
	if (low < high) {
		int part = partition(arr, low, high);
		sort(arr, low, part - 1);
		sort(arr, part + 1, high);
	}
}

void bbRegisterSource(BBULONG sourceId, const char * source) {
	if (sources == 0) {
		bpSize = 32;
		sources = calloc(bpSize, sizeof(BBSource));
	} else {
		if (bpCount == bpSize) {
			BBSource * bp = calloc(bpSize * 2, sizeof(BBSource));
			memcpy(bp, sources, bpSize * sizeof(BBSource));
			BBSource * old = sources;
			sources = bp;
			free(old);
			bpSize *= 2;
		}
	}
	
	sources[bpCount].id = sourceId;
	sources[bpCount].file = source;
	
	bpCount++;
	
	if (bpCount > 1) {
		sort(sources, 0, bpCount - 1);
	}
}

BBSource * bbSourceForId(BBULONG id) {
	if (bpCount > 0) {
		unsigned int first = 0;
		unsigned int last = bpCount - 1;
		unsigned int index = 0;
		
		while (first <= last) {
			index = (first + last) / 2;
			if (sources[index].id == id) {
				return &sources[index];
			} else {
				if (sources[index].id < id) {
					first = index + 1;
				} else {
					if (index == 0) {
						return 0;
					}
					last = index - 1;
				}
			}
		}
	}
	return 0;
}

BBSource * bbSourceForName(BBString * filename) {
	if (bpCount > 0) {
		char path[512];
		size_t len = 512;
		bbStringToUTF8StringBuffer(filename, path, &len);
		path[len] = 0;
		
		for (int i = 0; i < bpCount; i++) {
			if (strcmp(path, sources[i].file) == 0) {
				return &sources[i];
			}
		}
	}
	return 0;
}
