#ifndef BRL_REFLECTION_NATIVE_H
#define BRL_REFLECTION_NATIVE_H

BBString *bbRefClassDebugScopeName(BBClass *clas);
BBString *bbDebugScopeName(BBDebugScope *scope);
BBString *bbDebugDeclName(BBDebugDecl *decl);
BBString *bbDebugDeclType(BBDebugDecl *decl);
BBString *bbInterfaceName(BBInterface *ifc);

#endif
