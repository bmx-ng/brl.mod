
#include "blitz.h"

/*
#define HASH_SIZE 1024
#define HASH_SLOT(X) (((X)/8)&(HASH_SIZE-1))	// divide-by-8 for better void* mapping.

static int _handle_id;

typedef struct Hash Hash;

struct Hash{
	Hash *succ;
	int key,value;
};

static Hash *object_hash[HASH_SIZE];
static Hash *handle_hash[HASH_SIZE];

static int hashFind( Hash **table,int key ){
	Hash *t,**p;
	int t_key=HASH_SLOT(key);
	for( p=&table[t_key];(t=*p) && t->key!=key;p=&t->succ ){}
	return t ? t->value : 0;
}

static int hashRemove( Hash **table,int key ){
	Hash *t,**p;
	int t_key=HASH_SLOT(key),n;
	for( p=&table[t_key];(t=*p) && key!=t->key;p=&t->succ ){}
	if( !t ) return 0;
	n=t->value;
	*p=t->succ;
	bbMemFree( t );
	return n;
}

static void hashInsert( Hash **table,int key,int value ){
	int t_key=HASH_SLOT(key);
	Hash *t=(Hash*)bbMemAlloc( sizeof(Hash) );
	t->key=key;
	t->value=value;
	t->succ=table[t_key];
	table[t_key]=t;
}

int bbHandleFromObject( BBObject *o ){
	int		n;
	if( o==&bbNullObject ) return 0;
	n=hashFind( object_hash,(int)o );
	if( n ) return n/8;
	BBRETAIN( o );
	_handle_id+=8;
	if( !(_handle_id/8) ) _handle_id+=8;	//just-in-case!
	hashInsert( object_hash,(int)o,_handle_id );
	hashInsert( handle_hash,_handle_id,(int)o );
	return _handle_id/8;
}

BBObject *bbHandleToObject( int handle ){
	BBObject *o=(BBObject*)hashFind( handle_hash,handle*8 );
	return o ? o : &bbNullObject;
}

void bbHandleRelease( int  handle ){
	BBObject *o=(BBObject*)hashRemove( handle_hash,handle*8 );
	if( !o ) return;
	hashRemove( object_hash,(int)o );
	BBRELEASE( o );
}

*/

struct handle_node {
	struct avl_root link;
	BBOBJECT obj;
};

static struct avl_root *handle_root = 0;

#define generic_compare(x, y) (((x) > (y)) - ((x) < (y)))

static int node_compare(const void *x, const void *y) {

        struct handle_node * node_x = (struct handle_node *)x;
        struct handle_node * node_y = (struct handle_node *)y;

        return generic_compare(node_x->obj, node_y->obj);
}

size_t bbHandleFromObject( BBObject *o ) {
	struct handle_node * node = (struct handle_node *)GC_malloc_uncollectable(sizeof(struct handle_node));
	node->obj = o;
	
	struct handle_node * old_node = (struct handle_node *)avl_map(&node->link, node_compare, &handle_root );

	if (&node->link != &old_node->link) {
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
	
	return (size_t)o;
}

BBObject *bbHandleToObject( size_t handle ) {
	struct handle_node node;
	node.obj = (BBOBJECT)handle;
	
	struct handle_node * found = (struct handle_node *)tree_search((struct tree_root_np *)&node, node_compare, (struct tree_root_np *)handle_root );

	if (found) {
		return (BBOBJECT)handle;
	}
	
	return &bbNullObject;
}

void bbHandleRelease( size_t handle ) {
	struct handle_node node;
	node.obj = (BBOBJECT)handle;
	
	struct handle_node * found = (struct handle_node *)tree_search((struct tree_root_np *)&node, node_compare, (struct tree_root_np *)handle_root);
	
	if (found) {
		avl_del(&found->link, &handle_root);
		GC_FREE(found);
	}
}
