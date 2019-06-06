
#ifndef BLITZ_H
#define BLITZ_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//Which GC to use...

#include "bdwgc/include/gc.h"

# define BB_GC_BDW

//#ifdef THREADED
//# define BB_GC_MS
//#else
//# define BB_GC_RC
//#endif

// exceptions
#include <setjmp.h>

#include "blitz_types.h"
#include "blitz_memory.h"
#ifndef __EMSCRIPTEN__
#include "blitz_thread.h"
#endif
#include "blitz_gc.h"
#include "blitz_ex.h"
#include "blitz_cclib.h"
#include "blitz_debug.h"
#include "blitz_module.h"
#include "blitz_incbin.h"
#include "blitz_object.h"
#include "blitz_string.h"
#include "blitz_array.h"
#include "blitz_handle.h"
#include "blitz_app.h" 
#include "blitz_enum.h"

#ifdef __cplusplus
extern "C"{
#endif

extern void brl_blitz_NullObjectError();
extern void brl_blitz_NullMethodError();
extern void brl_blitz_NullFunctionError();
extern void brl_blitz_ArrayBoundsError();
extern void brl_blitz_OutOfDataError();
extern void brl_blitz_RuntimeError( BBString *error );
extern void brl_blitz_InvalidEnumError();

// BaH
struct BBClass_brl_blitz_TBlitzException;
extern struct BBClass_brl_blitz_TBlitzException brl_blitz_TBlitzException;

struct BBClass_brl_blitz_TNullObjectException;
extern struct BBClass_brl_blitz_TNullObjectException brl_blitz_TNullObjectException;

struct BBClass_brl_blitz_TNullMethodException;
extern struct BBClass_brl_blitz_TNullMethodException brl_blitz_TNullMethodException;

struct BBClass_brl_blitz_TNullFunctionException;
extern struct BBClass_brl_blitz_TNullFunctionException brl_blitz_TNullFunctionException;

struct BBClass_brl_blitz_TArrayBoundsException;
extern struct BBClass_brl_blitz_TArrayBoundsException brl_blitz_TArrayBoundsException;

struct BBClass_brl_blitz_TOutOfDataException;
extern struct BBClass_brl_blitz_TOutOfDataException brl_blitz_TOutOfDataException;

struct BBClass_brl_blitz_TRuntimeException;
extern struct BBClass_brl_blitz_TRuntimeException brl_blitz_TRuntimeExeption;

struct BBClass_brl_blitz_TInvalidEnumException;
extern struct BBClass_brl_blitz_TInvalidEnumException brl_blitz_TInvalidEnumException;


#if 0
extern BBClass brl_blitz_TBlitzException;
extern BBClass brl_blitz_TNullObjectException;
extern BBClass brl_blitz_TNullMethodException;
extern BBClass brl_blitz_TNullFunctionException;
extern BBClass brl_blitz_TArrayBoundsException;
extern BBClass brl_blitz_TOutOfDataException;
extern BBClass brl_blitz_TRuntimeExeption;
#endif

#ifdef __cplusplus
}
#endif

#endif
