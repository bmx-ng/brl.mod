
#include "blitz.h"

#ifdef __APPLE__
#include <mach-o/getsect.h>
#endif

#ifdef _WIN32
#ifdef __x86_64__
extern void *__bss_end__;
extern void *__data_start__;
#else
extern void *_bss_end__;
extern void *_data_start__;
#endif
#endif

#ifdef __linux
#ifdef __ANDROID__
extern int __data_start[];
extern int _end[];
#else
extern void *__data_start;
extern void *_end;
#endif
#endif

static void gc_finalizer( void *mem,void *pool ){
	((BBGCPool*)pool)->free( (BBGCMem*)mem );
}

static void gc_warn_proc( char *msg,GC_word arg ){
	/*printf(msg,arg);fflush(stdout);*/
}

void bbGCStartup( void *spTop ){
/*	GC_set_no_dls(1);
	GC_clear_roots();
#ifdef _WIN32
#ifdef __x86_64__
	GC_add_roots(&__data_start__, &__bss_end__);
#else
	GC_add_roots(&_data_start__, &_bss_end__);
#endif
#endif

#ifdef __APPLE__
#ifndef __LP64__
	struct segment_command * seg;
#else
	struct segment_command_64 * seg;
#endif
	
	seg = getsegbyname( "__DATA" );

//	GC_add_roots((void*)seg->vmaddr, (void*)(seg->vmaddr + seg->vmsize));
#endif

#ifdef __linux
	GC_add_roots(&__data_start, &_end);
#endif
*/
	GC_INIT();
	GC_allow_register_threads();
	GC_set_warn_proc( gc_warn_proc );
}

BBGCMem *bbGCAlloc( int sz,BBGCPool *pool ){
	GC_finalization_proc ofn;
	void *ocd;
	BBGCMem *q=(BBGCMem*) GC_MALLOC( sz );
	q->pool=pool;
	//q->refs=-1;
	GC_REGISTER_FINALIZER( q,gc_finalizer,pool,&ofn,&ocd );
	return q;
}

BBObject * bbGCAllocObject( int sz,BBClass *clas,int flags ){
	BBObject *q;
	if( flags & BBGC_ATOMIC ){
		q=(BBObject*)GC_MALLOC_ATOMIC( sz );
	}else{
		q=(BBObject*)GC_MALLOC( sz );
	}
	q->clas=clas;
	//q->refs=-1;
	if( flags & BBGC_FINALIZE ){
		GC_finalization_proc ofn;
		void *ocd;
		GC_REGISTER_FINALIZER( q,gc_finalizer,clas,&ofn,&ocd );
	}
	return q;	
}

void bbGCFree( BBGCMem *q ){
}

int bbGCValidate( void *q ){
	if (GC_is_heap_ptr( q )) {
		BBClass * clas = ((BBObject*)q)->clas;
		int count;
		BBClass ** classes = bbObjectRegisteredTypes(&count);
		while (count--) {
			if (classes[count] == clas) {
				return 1;
			}
		}
		// maybe an array?
		if (clas == &bbArrayClass) {
			return 1;
		}
	}
	return 0;
}

int bbGCCollect(){
	GC_gcollect();
}

int bbGCCollectALittle() {
	return GC_collect_a_little();
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

static struct avl_root *retain_root = 0;

#define generic_compare(x, y) (((x) > (y)) - ((x) < (y)))

int node_compare(const void *x, const void *y) {

        struct retain_node * node_x = (struct retain_node *)x;
        struct retain_node * node_y = (struct retain_node *)y;

        return generic_compare(node_x->obj, node_y->obj);
}

void bbGCRetain( BBObject *p ) {
	struct retain_node * node = (struct retain_node *)GC_MALLOC(sizeof(struct retain_node));
	node->count = 1;
	node->obj = p;
	
	struct retain_node * old_node = (struct retain_node *)avl_map(&node->link, node_compare, &retain_root);
	if (&node->link != &old_node->link) {
		// this object already exists here... increment our reference count
		old_node->count++;
		
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

void bbGCRelease( BBObject *p ) {
	// create something to look up
	struct retain_node node;
	node.obj = p;
	
	struct retain_node * found = (struct retain_node *)tree_search(&node, node_compare, retain_root);

	if (found) {
		// found a retained object!
		
		found->count--;
		if (found->count <=0) {
			// remove from the tree
			avl_del(&found->link, &retain_root);
			// free the node
			found->obj = 0;
			GC_FREE(found);
		}
	}
}
