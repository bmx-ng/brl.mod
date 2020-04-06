
#ifndef BLITZ_DEBUG_H
#define BLITZ_DEBUG_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#ifndef NDEBUG
#define bbassert( x ) if( !(x) ) bbCAssertEx()
#else
#define bbassert( x )
#endif

typedef struct BBDebugStm BBDebugStm;
typedef struct BBDebugDecl BBDebugDecl;
typedef struct BBDebugScope BBDebugScope;

enum{
	BBDEBUGDECL_END=0,
	BBDEBUGDECL_CONST=1,
	BBDEBUGDECL_LOCAL=2,
	BBDEBUGDECL_FIELD=3,
	BBDEBUGDECL_GLOBAL=4,
	BBDEBUGDECL_VARPARAM=5,

	BBDEBUGDECL_TYPEMETHOD=6,
	BBDEBUGDECL_TYPEFUNCTION=7
};

struct BBDebugDecl{
	unsigned int     kind;
	const char       *name,*type_tag;
	union{
		BBString*    const_value;
		unsigned int field_offset;
		void*        var_address;
	};
};

enum{
	BBDEBUGSCOPE_FUNCTION=1,
	BBDEBUGSCOPE_USERTYPE=2,
	BBDEBUGSCOPE_LOCALBLOCK=3,
	BBDEBUGSCOPE_USERINTERFACE=4,
	BBDEBUGSCOPE_USERSTRUCT=5,
	BBDEBUGSCOPE_USERENUM=6,
};

struct BBDebugScope{
	unsigned int	kind;
	const char		*name;
	BBDebugDecl		decls[1];
};

struct BBDebugStm{
	BBULONG      id;
	int          line_num,char_num;
};

typedef struct BBSource {
	BBULONG id;
	char * file;
	unsigned int count;
	unsigned int lines[32];
} BBSource;

extern void bbCAssertEx();

extern void (*bbOnDebugStop)();
extern void (*bbOnDebugLog)( BBString *msg );
extern void (*bbOnDebugEnterStm)( BBDebugStm *stm );
extern void (*bbOnDebugEnterScope)( BBDebugScope *scope );//,void *inst );
extern void (*bbOnDebugLeaveScope)();
extern void (*bbOnDebugPushExState)();
extern void (*bbOnDebugPopExState)();
extern void (*bbOnDebugUnhandledEx)( BBObject *ex );

void bbRegisterSource(BBULONG sourceId, const char * source);
BBSource * bbSourceForId(BBULONG id);
BBSource * bbSourceForName(BBString * filename);

#ifdef __cplusplus
}
#endif

#endif
