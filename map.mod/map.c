#include "brl.mod/blitz.mod/blitz.h"
#include "brl.mod/blitz.mod/tree/tree.h"

#define generic_compare(x, y) (((x) > (y)) - ((x) < (y)))


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ */

struct longmap_node {
	struct avl_root link;
	BBLONG key;
	BBOBJECT value;
};

static int compare_longmap_nodes(const void *x, const void *y) {

        struct longmap_node * node_x = (struct longmap_node *)x;
        struct longmap_node * node_y = (struct longmap_node *)y;

        return generic_compare(node_x->key, node_y->key);
}

void bmx_map_longmap_clear(struct avl_root ** root) {
	struct longmap_node *node;
	struct longmap_node *tmp;
	avl_for_each_entry_safe(node, tmp, *root, link) {
		avl_del(&node->link, root);
		GC_FREE(node);
	}
}

int bmx_map_longmap_isempty(struct avl_root ** root) {
	return *root == 0;
}

void bmx_map_longmap_insert( BBLONG key, BBObject *value, struct avl_root ** root ) {
	struct longmap_node * node = (struct longmap_node *)GC_malloc_uncollectable(sizeof(struct longmap_node));
	node->key = key;
	node->value = value;
	
	struct longmap_node * old_node = (struct longmap_node *)avl_map(&node->link, compare_longmap_nodes, root);

	if (&node->link != &old_node->link) {
		// key already exists. Store the value in this node.
		old_node->value = value;
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

int bmx_map_longmap_contains(BBLONG key, struct avl_root ** root) {
	struct longmap_node node;
	node.key = key;
	
	struct longmap_node * found = (struct longmap_node *)tree_search(&node, compare_longmap_nodes, *root);
	if (found) {
		return 1;
	} else {
		return 0;
	}
}

BBObject * bmx_map_longmap_valueforkey(BBLONG key, struct avl_root ** root) {
	struct longmap_node node;
	node.key = key;
	
	struct longmap_node * found = (struct longmap_node *)tree_search(&node, compare_longmap_nodes, *root);
	
	if (found) {
		return found->value;
	}
	
	return &bbNullObject;
}

int bmx_map_longmap_remove(BBLONG key, struct avl_root ** root) {
	struct longmap_node node;
	node.key = key;
	
	struct longmap_node * found = (struct longmap_node *)tree_search(&node, compare_longmap_nodes, *root);
	
	if (found) {
		avl_del(&found->link, root);
		GC_FREE(found);
		return 1;
	} else {
		return 0;
	}
}

struct longmap_node * bmx_map_longmap_nextnode(struct longmap_node * node) {
	return tree_successor(node);
}

struct longmap_node * bmx_map_longmap_firstnode(struct avl_root * root) {
	return tree_min(root);
}

BBLONG bmx_map_longmap_key(struct longmap_node * node) {
	return node->key;
}

BBObject * bmx_map_longmap_value(struct longmap_node * node) {
	return node->value;
}

int bmx_map_longmap_hasnext(struct longmap_node * node, struct avl_root * root) {
	if (!root) {
		return 0;
	}
	
	if (!node) {
		return 1;
	}
	
	return (tree_successor(node) != 0) ? 1 : 0;
}

void bmx_map_longmap_copy(struct avl_root ** dst_root, struct avl_root * src_root) {
	struct longmap_node *src_node;
	struct longmap_node *tmp;
	avl_for_each_entry_safe(src_node, tmp, src_root, link) {
		bmx_map_longmap_insert(src_node->key, src_node->value, dst_root);
	}
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ */

struct intmap_node {
	struct avl_root link;
	int key;
	BBOBJECT value;
};

static int compare_intmap_nodes(const void *x, const void *y) {

        struct intmap_node * node_x = (struct intmap_node *)x;
        struct intmap_node * node_y = (struct intmap_node *)y;

        return generic_compare(node_x->key, node_y->key);
}

void bmx_map_intmap_clear(struct avl_root ** root) {
	struct intmap_node *node;
	struct intmap_node *tmp;
	if (*root == 0) return; // already cleared?
	avl_for_each_entry_safe(node, tmp, *root, link)
	{
		avl_del(&node->link, root);
		GC_FREE(node);
	}
}

int bmx_map_intmap_isempty(struct avl_root * root) {
	return root == 0;
}

void bmx_map_intmap_insert( int key, BBObject *value, struct avl_root ** root ) {
	struct intmap_node * node = (struct intmap_node *)GC_malloc_uncollectable(sizeof(struct intmap_node));
	node->key = key;
	node->value = value;
	
	struct intmap_node * old_node = (struct intmap_node *)avl_map(&node->link, compare_intmap_nodes, root);

	if (&node->link != &old_node->link) {
		// key already exists. Store the value in this node.
		old_node->value = value;
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

int bmx_map_intmap_contains(int key, struct avl_root * root) {
	struct intmap_node node;
	node.key = key;
	
	struct intmap_node * found = (struct intmap_node *)TREE_SEARCH(&node, compare_intmap_nodes, root);
	if (found) {
		return 1;
	} else {
		return 0;
	}
}

BBObject * bmx_map_intmap_valueforkey(int key, struct avl_root * root) {
	struct intmap_node node;
	node.key = key;
	
	struct intmap_node * found = (struct intmap_node *)TREE_SEARCH(&node, compare_intmap_nodes, root);
	
	if (found) {
		return found->value;
	}
	
	return &bbNullObject;
}

int bmx_map_intmap_remove(int key, struct avl_root ** root) {
	struct intmap_node node;
	node.key = key;
	
	struct intmap_node * found = (struct intmap_node *)TREE_SEARCH(&node, compare_intmap_nodes, *root);
	
	if (found) {
		avl_del(&found->link, root);
		GC_FREE(found);
		return 1;
	} else {
		return 0;
	}
}

struct intmap_node * bmx_map_intmap_nextnode(struct intmap_node * node) {
	return (struct intmap_node *)TREE_SUCCESSOR(node);
}

struct intmap_node * bmx_map_intmap_firstnode(struct avl_root * root) {
	return (struct intmap_node *)TREE_MIN(root);
}

int bmx_map_intmap_key(struct intmap_node * node) {
	return node->key;
}

BBObject * bmx_map_intmap_value(struct intmap_node * node) {
	return node->value;
}

int bmx_map_intmap_hasnext(struct intmap_node * node, struct avl_root * root) {
	if (!root) {
		return 0;
	}
	
	if (!node) {
		return 1;
	}
	
	return (TREE_SUCCESSOR(node) != 0) ? 1 : 0;
}

void bmx_map_intmap_copy(struct avl_root ** dst_root, struct avl_root * src_root) {
	struct intmap_node *src_node;
	struct intmap_node *tmp;
	avl_for_each_entry_safe(src_node, tmp, src_root, link) {
		bmx_map_intmap_insert(src_node->key, src_node->value, dst_root);
	}
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ */

struct ptrmap_node {
	struct avl_root link;
	void * key;
	BBOBJECT value;
};

static int compare_ptrmap_nodes(const void *x, const void *y) {

        struct ptrmap_node * node_x = (struct ptrmap_node *)x;
        struct ptrmap_node * node_y = (struct ptrmap_node *)y;

        return generic_compare(node_x->key, node_y->key);
}

void bmx_map_ptrmap_clear(struct avl_root ** root) {
	struct ptrmap_node *node;
	struct ptrmap_node *tmp;
	if (*root == 0) return; // already cleared?
	avl_for_each_entry_safe(node, tmp, *root, link) {
		avl_del(&node->link, root);
		GC_FREE(node);
	}
}

int bmx_map_ptrmap_isempty(struct avl_root * root) {
	return root == 0;
}

void bmx_map_ptrmap_insert( void * key, BBObject *value, struct avl_root ** root ) {
	struct ptrmap_node * node = (struct ptrmap_node *)GC_malloc_uncollectable(sizeof(struct ptrmap_node));
	node->key = key;
	node->value = value;
	
	struct ptrmap_node * old_node = (struct ptrmap_node *)avl_map(&node->link, compare_ptrmap_nodes, root);

	if (&node->link != &old_node->link) {
		// key already exists. Store the value in this node.
		old_node->value = value;
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

int bmx_map_ptrmap_contains(void * key, struct avl_root * root) {
	struct ptrmap_node node;
	node.key = key;
	
	struct ptrmap_node * found = (struct ptrmap_node *)TREE_SEARCH(&node, compare_ptrmap_nodes, root);
	if (found) {
		return 1;
	} else {
		return 0;
	}
}

BBObject * bmx_map_ptrmap_valueforkey(void * key, struct avl_root * root) {
	struct ptrmap_node node;
	node.key = key;
	
	struct ptrmap_node * found = (struct ptrmap_node *) TREE_SEARCH(&node, compare_ptrmap_nodes, root);
	
	if (found) {
		return found->value;
	}

	return &bbNullObject;
}

int bmx_map_ptrmap_remove(void * key, struct avl_root ** root) {
	struct ptrmap_node node;
	node.key = key;
	
	struct ptrmap_node * found = (struct ptrmap_node *)TREE_SEARCH(&node, compare_ptrmap_nodes, *root);
	
	if (found) {
		avl_del(&found->link, root);
		GC_FREE(found);
		return 1;
	} else {
		return 0;
	}
}

struct ptrmap_node * bmx_map_ptrmap_nextnode(struct ptrmap_node * node) {
	return (struct ptrmap_node *)TREE_SUCCESSOR(node);
}

struct ptrmap_node * bmx_map_ptrmap_firstnode(struct avl_root * root) {
	return (struct ptrmap_node *)TREE_MIN(root);
}

void * bmx_map_ptrmap_key(struct ptrmap_node * node) {
	return node->key;
}

BBObject * bmx_map_ptrmap_value(struct ptrmap_node * node) {
	return node->value;
}

int bmx_map_ptrmap_hasnext(struct ptrmap_node * node, struct avl_root * root) {
	if (!root) {
		return 0;
	}
	
	if (!node) {
		return 1;
	}
	
	return (TREE_SUCCESSOR(node) != 0) ? 1 : 0;
}

void bmx_map_ptrmap_copy(struct avl_root ** dst_root, struct avl_root * src_root) {
	struct ptrmap_node *src_node;
	struct ptrmap_node *tmp;
	avl_for_each_entry_safe(src_node, tmp, src_root, link) {
		bmx_map_ptrmap_insert(src_node->key, src_node->value, dst_root);
	}
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ */

struct stringmap_node {
	struct avl_root link;
	BBString * key;
	BBOBJECT value;
};

static int compare_stringmap_nodes(const void *x, const void *y) {
        struct stringmap_node * node_x = (struct stringmap_node *)x;
        struct stringmap_node * node_y = (struct stringmap_node *)y;

		return generic_compare(node_x->key->hash, node_y->key->hash);
}

void bmx_map_stringmap_clear(struct avl_root ** root) {
	struct stringmap_node *node;
	struct stringmap_node *tmp;
	if (*root == 0) return; // already cleared?
	avl_for_each_entry_safe(node, tmp, *root, link) {
		avl_del(&node->link, root);
		GC_FREE(node);
	}
}

int bmx_map_stringmap_isempty(struct avl_root * root) {
	return root == 0;
}

void bmx_map_stringmap_insert( BBString * key, BBObject *value, struct avl_root ** root) {
	struct stringmap_node * node = (struct stringmap_node *)GC_malloc_uncollectable(sizeof(struct stringmap_node));
	node->key = key;
	node->value = value;
	
	struct stringmap_node * old_node = (struct stringmap_node *)avl_map(&node->link, compare_stringmap_nodes, root);

	if (&node->link != &old_node->link) {
		// key already exists. Store the value in this node.
		old_node->value = value;
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

int bmx_map_stringmap_contains(BBString * key, struct avl_root * root) {
	struct stringmap_node node;
	node.key = key;
	
	struct stringmap_node * found = (struct stringmap_node *)TREE_SEARCH(&node, compare_stringmap_nodes, root);
	if (found) {
		return 1;
	} else {
		return 0;
	}
}

BBObject * bmx_map_stringmap_valueforkey(BBString * key, struct avl_root * root) {
	struct stringmap_node node;
	node.key = key;
	
	struct stringmap_node * found = (struct stringmap_node *)TREE_SEARCH(&node, compare_stringmap_nodes, root);
	
	if (found) {
		return found->value;
	}
	
	return &bbNullObject;
}

int bmx_map_stringmap_remove(BBString * key, struct avl_root ** root) {
	struct stringmap_node node;
	node.key = key;
	
	struct stringmap_node * found = (struct stringmap_node *)TREE_SEARCH(&node, compare_stringmap_nodes, *root);
	
	if (found) {
		avl_del(&found->link, root);
		GC_FREE(found);
		return 1;
	} else {
		return 0;
	}
}

struct stringmap_node * bmx_map_stringmap_nextnode(struct stringmap_node * node) {
	return (struct stringmap_node *)TREE_SUCCESSOR(node);
}

struct stringmap_node * bmx_map_stringmap_firstnode(struct avl_root * root) {
	return (struct stringmap_node *)TREE_MIN(root);
}

BBString * bmx_map_stringmap_key(struct stringmap_node * node) {
	return node->key;
}

BBObject * bmx_map_stringmap_value(struct stringmap_node * node) {
	return node->value;
}

int bmx_map_stringmap_hasnext(struct stringmap_node * node, struct avl_root * root) {
	if (!root) {
		return 0;
	}
	
	if (!node) {
		return 1;
	}
	
	return (TREE_SUCCESSOR(node) != 0) ? 1 : 0;
}

void bmx_map_stringmap_copy(struct avl_root ** dst_root, struct avl_root * src_root) {
	struct stringmap_node *src_node;
	struct stringmap_node *tmp;
	avl_for_each_entry_safe(src_node, tmp, src_root, link) {
		bmx_map_stringmap_insert(src_node->key, src_node->value, dst_root);
	}
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ */

struct objectmap_node {
	struct avl_root link;
	BBOBJECT key;
	BBOBJECT value;
};

static int compare_objectmap_nodes(const void *x, const void *y) {
        struct objectmap_node * node_x = (struct objectmap_node *)x;
        struct objectmap_node * node_y = (struct objectmap_node *)y;

        return node_x->key->clas->Compare(node_x->key, node_y->key);
}

void bmx_map_objectmap_clear(struct avl_root ** root) {
	struct objectmap_node *node;
	struct objectmap_node *tmp;
	if (*root == 0) return; // already cleared?
	avl_for_each_entry_safe(node, tmp, *root, link) {
		avl_del(&node->link, root);
		GC_FREE(node);
	}
}

int bmx_map_objectmap_isempty(struct avl_root * root) {
	return root == 0;
}

void bmx_map_objectmap_insert( BBObject * key, BBObject *value, struct avl_root ** root) {
	struct objectmap_node * node = (struct objectmap_node *)GC_malloc_uncollectable(sizeof(struct objectmap_node));
	node->key = key;
	node->value = value;
	
	struct objectmap_node * old_node = (struct objectmap_node *)avl_map(&node->link, compare_objectmap_nodes, root);

	if (&node->link != &old_node->link) {
		// key already exists. Store the value in this node.
		old_node->value = value;
		// delete the new node, since we don't need it
		GC_FREE(node);
	}
}

int bmx_map_objectmap_contains(BBObject * key, struct avl_root * root) {
	struct objectmap_node node;
	node.key = key;
	
	struct objectmap_node * found = (struct objectmap_node *)TREE_SEARCH(&node, compare_objectmap_nodes, root);
	if (found) {
		return 1;
	} else {
		return 0;
	}
}

BBObject * bmx_map_objectmap_valueforkey(BBObject * key, struct avl_root * root) {
	struct objectmap_node node;
	node.key = key;
	
	struct objectmap_node * found = (struct objectmap_node *)TREE_SEARCH(&node, compare_objectmap_nodes, root);
	
	if (found) {
		return found->value;
	}
	
	return &bbNullObject;
}

int bmx_map_objectmap_remove(BBObject * key, struct avl_root ** root) {
	struct objectmap_node node;
	node.key = key;
	
	struct objectmap_node * found = (struct objectmap_node *)TREE_SEARCH(&node, compare_objectmap_nodes, *root);
	
	if (found) {
		avl_del(&found->link, root);
		GC_FREE(found);
		return 1;
	} else {
		return 0;
	}
}

struct objectmap_node * bmx_map_objectmap_nextnode(struct objectmap_node * node) {
	return (struct objectmap_node *)TREE_SUCCESSOR(node);
}

struct objectmap_node * bmx_map_objectmap_firstnode(struct avl_root * root) {
	return (struct objectmap_node *)TREE_MIN(root);
}

BBObject * bmx_map_objectmap_key(struct objectmap_node * node) {
	return node->key;
}

BBObject * bmx_map_objectmap_value(struct objectmap_node * node) {
	return node->value;
}

int bmx_map_objectmap_hasnext(struct objectmap_node * node, struct avl_root * root) {
	if (!root) {
		return 0;
	}
	
	if (!node) {
		return 1;
	}
	
	return (TREE_SUCCESSOR(node) != 0) ? 1 : 0;
}

void bmx_map_objectmap_copy(struct avl_root ** dst_root, struct avl_root * src_root) {
	struct objectmap_node *src_node;
	struct objectmap_node *tmp;
	avl_for_each_entry_safe(src_node, tmp, src_root, link) {
		bmx_map_objectmap_insert(src_node->key, src_node->value, dst_root);
	}
}
