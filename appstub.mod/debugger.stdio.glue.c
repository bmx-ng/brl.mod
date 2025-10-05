
#include "brl.mod/blitz.mod/blitz.h"

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugScopeName(struct BBDebugScope * scope) {
	return bbStringFromCString(scope->name);
}

unsigned int bmx_debugger_DebugScopeKind(struct BBDebugScope * scope) {
	return scope->kind;
}

struct BBDebugDecl * bmx_debugger_DebugScopeDecl(struct BBDebugScope * scope) {
	return &scope->decls[0];
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugDeclName(struct BBDebugDecl * decl) {
	return bbStringFromCString(decl->name);
}

BBString * bmx_debugger_DebugDeclType(struct BBDebugDecl * decl) {
	return bbStringFromCString(decl->type_tag);
}

unsigned int bmx_debugger_DebugDeclKind(struct BBDebugDecl * decl) {
	return decl->kind;
}

struct BBDebugDecl * bmx_debugger_DebugDeclNext( struct BBDebugDecl * decl ) {
	return decl + 1;
}

void * bmx_debugger_DebugDecl_VarAddress( struct BBDebugDecl * decl ) {
	return decl->var_address;
}

BBString * bmx_debugger_DebugDecl_ConstValue(struct BBDebugDecl * decl) {
	return decl->const_value;
}

void * bmx_debugger_DebugDecl_FieldOffset(struct BBDebugDecl * decl, void * inst) {
	return ((char *)inst) + decl->field_offset;
}

BBString * bmx_debugger_DebugDecl_StringFromAddress(BBString * p) {
	return p;
}

BBChar bmx_debugger_DebugDeclTypeChar(struct BBDebugDecl * decl, int index) {
	return decl->type_tag[index];
}

int bmx_debugger_DebugDecl_ArraySize(BBArray * array) {
	return array->scales[0];
}

BBClass * bmx_debugger_DebugDecl_clas( BBObject * inst ) {
	return inst->clas;
}

int bmx_debugger_DebugDecl_isStringClass(BBClass * clas) {
	return clas == &bbStringClass;
}

int bmx_debugger_DebugDecl_isArrayClass(BBClass * clas) {
	return clas == &bbArrayClass;
}

int bmx_debugger_DebugDecl_isBaseObject(BBClass * clas) {
	return clas->super == 0;
}

struct BBDebugDecl * bmx_debugger_DebugDecl_ArrayDecl(BBArray  * arr) {
	struct BBDebugDecl * decl = malloc(sizeof(struct BBDebugDecl));
	
	decl->kind = BBDEBUGDECL_LOCAL;
	decl->name = 0;
	decl->type_tag = arr->type;
	
	return decl;
}

void bmx_debugger_DebugDecl_ArrayDeclIndexedPart(struct BBDebugDecl * decl, BBArray  * arr, int index) {
	decl->var_address = ((char*)BBARRAYDATA(arr, arr->dims)) + arr->data_size * index;
}

void bmx_debugger_DebugDecl_ArrayDeclFree(struct BBDebugDecl * decl) {
	free(decl);
}

BBString * bmx_debugger_DebugEnumDeclValue(BBString * decl_type_tag, void * val) {
	unsigned char * decl_type_tag_cstr = bbStringToCString(decl_type_tag);
	BBEnum * bbEnum = bbEnumGetInfo(decl_type_tag_cstr);
	bbMemFree(decl_type_tag_cstr);
	
	switch( bbEnum->type[0] ){
		case 'b': return bbEnumToString_b(bbEnum, *((BBBYTE*)val));
		case 's': return bbEnumToString_s(bbEnum, *((BBSHORT*)val));
		case 'i': return bbEnumToString_i(bbEnum, *((BBINT*)val));
		case 'u': return bbEnumToString_u(bbEnum, *((BBUINT*)val));
		case 'l': return bbEnumToString_l(bbEnum, *((BBLONG*)val));
		case 'y': return bbEnumToString_y(bbEnum, *((BBULONG*)val));
		case 't': return bbEnumToString_t(bbEnum, *((BBSIZET*)val));
		case 'v': return bbEnumToString_v(bbEnum, *((BBLONGINT*)val));
		case 'e': return bbEnumToString_e(bbEnum, *((BBULONGINT*)val));
	}
	
	return &bbEmptyString;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugStmFile(struct BBDebugStm * stmt) {
	BBSource * src = bbSourceForId(stmt->id);
	return bbStringFromCString(src->file);
}

int bmx_debugger_DebugStmLine(struct BBDebugStm * stmt) {
	return stmt->line_num;
}

int bmx_debugger_DebugStmChar(struct BBDebugStm * stmt) {
	return stmt->char_num;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBClass * bmx_debugger_DebugClassSuper(BBClass * clas) {
	return clas->super;
}

struct BBDebugScope * bmx_debugger_DebugClassScope(BBClass * clas) {
	return clas->debug_scope;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void * bmx_debugger_ref_bbNullObject() {
	return &bbNullObject;
}

void * bmx_debugger_ref_bbEmptyArray() {
	return &bbEmptyArray;
}

void * bmx_debugger_ref_bbEmptyString() {
	return &bbEmptyString;
}

void * bmx_debugger_ref_brl_blitz_NullFunctionError() {
	return brl_blitz_NullFunctionError;
}

