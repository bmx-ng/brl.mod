
#include "blitz.h"

static void gc_finalizer( void *mem,void *pool ){
	((BBGCPool*)pool)->free( (BBGCMem*)mem );
}

static void gc_warn_proc( char *msg,GC_word arg ){
}

void bbGCStartup( void *spTop ){
	GC_INIT();
	GC_set_warn_proc( gc_warn_proc );
}

BBGCMem *bbGCAlloc( int sz,BBGCPool *pool ){
	GC_finalization_proc ofn;
	void *ocd;
	BBGCMem *q=(BBGCMem*)GC_malloc( sz );
	q->pool=pool;
	//q->refs=-1;
	GC_register_finalizer( q,gc_finalizer,pool,&ofn,&ocd );
	return q;
}

BBObject * bbGCAllocObject( int sz,BBClass *clas,int flags ){
	BBObject *q;
	if( flags & BBGC_ATOMIC ){
		q=(BBObject*)GC_malloc_atomic( sz );
	}else{
		q=(BBObject*)GC_malloc( sz );
	}
	q->clas=clas;
	//q->refs=-1;
	if( flags & BBGC_FINALIZE ){
		GC_finalization_proc ofn;
		void *ocd;
		GC_register_finalizer( q,gc_finalizer,clas,&ofn,&ocd );
	}
	return q;	
}

void bbGCFree( BBGCMem *q ){
}

int bbGCValidate( void *q ){
	return GC_base( q )==q;
}

int bbGCCollect(){
	GC_gcollect();
}

void bbGCSetMode( int mode ){
}

void bbGCSetDebug( int debug ){
}

void bbGCSuspend(){
	GC_disable();
}

void bbGCResume(){
	GC_enable();
}

int bbGCMemAlloced(){
	return GC_get_heap_size();
}
