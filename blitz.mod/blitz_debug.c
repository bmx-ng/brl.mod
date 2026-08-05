
#include "blitz.h"

void bbCAssertEx(){
	bbExThrowCString( "C Assert failed" );
}

static void debugNop(){
}

static void debugStrNop(BBString * o){
}

static void debugStmNop(BBDebugStm * o){
}

static void debugScpNop(BBDebugScope * o){
}

static void debugUnhandledEx( BBObject *ex ){
	bbWriteStderr( ex->clas->ToString( ex ) );
	exit(-1);
}

void (*bbOnDebugStop)()=debugNop;
void (*bbOnDebugLog)( BBString *str )=debugStrNop;
void (*bbOnDebugEnterStm)( BBDebugStm *stm )=debugStmNop;
void (*bbOnDebugEnterScope)( BBDebugScope *scope )=debugScpNop;
void (*bbOnDebugLeaveScope)()=debugNop;
void (*bbOnDebugPushExState)()=debugNop;
void (*bbOnDebugPopExState)()=debugNop;

void (*bbOnDebugUnhandledEx)( BBObject *ex )=debugUnhandledEx;

static unsigned int bpCount = 0;
static unsigned int bpSize = 0;
static BBSource * sources = 0;

void bbRegisterSource(BBULONG sourceId, const char * source) {
	unsigned int first = 0;
	unsigned int last = bpCount;
	while (first < last) {
		unsigned int index = first + (last - first) / 2;
		if (sources[index].id < sourceId) {
			first = index + 1;
		} else {
			last = index;
		}
	}
	/* Every generated unit can reference source locations owned by one of its
	   dependencies. Registering the same stable source id again is harmless and
	   must not grow or repeatedly sort the process-wide table. */
	if (first < bpCount && sources[first].id == sourceId) {
		return;
	}

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

	if (first < bpCount) {
		memmove(sources + first + 1, sources + first, (bpCount - first) * sizeof(BBSource));
	}
	sources[first].id = sourceId;
	sources[first].file = source;
	bpCount++;
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
		
		int i;
		for (i = 0; i < bpCount; i++) {
			if (strcmp(path, sources[i].file) == 0) {
				return &sources[i];
			}
		}
	}
	return 0;
}
