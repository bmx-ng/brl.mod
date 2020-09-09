
SuperStrict

NoDebug

Rem
bbdoc: BASIC/BlitzMax runtime
End Rem
Module BRL.Blitz

ModuleInfo "Version: 1.22"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"
'
ModuleInfo "History: 1.22"
ModuleInfo "History: Update to bdwgc 8.1.0.fbcdf44"
ModuleInfo "History: 1.21"
ModuleInfo "History: Update to bdwgc 7.7.0.d76816e"
ModuleInfo "History: 1.20"
ModuleInfo "History: Update to bdwgc 7.7.0."
ModuleInfo "History: 1.19"
ModuleInfo "History: Added interfaces."
ModuleInfo "History: Added Interface and EndInterface keyword docs"
ModuleInfo "History: 1.18"
ModuleInfo "History: WriteStdout and WriteStderr now write UTF-8"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: Added kludges for Lion llvm"
ModuleInfo "History: Removed Nan/Inf"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: String.Find now converts start index <0 to 0"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Changed ReadStdin so it can handle any length input"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed leak in WriteStdout and WriteStderr"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Added LibStartUp stub"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added GCSuspend and GCResume"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Added experimental dll support"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Added Nan and Inf keyword docs"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: BCC extern CString fix"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Removed printf from 'Throw'"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added AppTitle$ global var"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Restored ReadData"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Lotsa little tidyups"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed C Compiler warnings"

?win32
ModuleInfo "CC_OPTS: -DGC_THREADS -DPARALLEL_MARK -DATOMIC_UNCOLLECTABLE -DLARGE_CONFIG -DUSE_MMAP -DUSE_MUNMAP -DGC_UNMAP_THRESHOLD=3"
?osx
ModuleInfo "CC_OPTS: -DGC_THREADS -DPARALLEL_MARK -DATOMIC_UNCOLLECTABLE -DLARGE_CONFIG -DUSE_MMAP -DUSE_MUNMAP -DGC_UNMAP_THRESHOLD=3"
?linuxx86
ModuleInfo "CC_OPTS: -DGC_THREADS -D_REENTRANT -DPARALLEL_MARK -DATOMIC_UNCOLLECTABLE -DLARGE_CONFIG -DUSE_MMAP -DUSE_MUNMAP -DGC_UNMAP_THRESHOLD=3"
?linuxx64
ModuleInfo "CC_OPTS: -DGC_THREADS -D_REENTRANT -DPARALLEL_MARK -DATOMIC_UNCOLLECTABLE -DLARGE_CONFIG -DUSE_MMAP -DUSE_MUNMAP -DGC_UNMAP_THRESHOLD=3"
?raspberrypi
ModuleInfo "CC_OPTS: -DGC_THREADS -D_REENTRANT -DPARALLEL_MARK -DATOMIC_UNCOLLECTABLE -DUSE_MMAP -DUSE_MUNMAP -DGC_UNMAP_THRESHOLD=3"
?android
ModuleInfo "CC_OPTS: -DGC_THREADS -D_REENTRANT -DATOMIC_UNCOLLECTABLE"
?emscripten
ModuleInfo "CC_OPTS: -DATOMIC_UNCOLLECTABLE"
?ios
ModuleInfo "CC_OPTS: -DGC_THREADS -DATOMIC_UNCOLLECTABLE"
?musl
ModuleInfo "CC_OPTS: -DNO_GETCONTEXT"
?nx
ModuleInfo "CC_OPTS: -DATOMIC_UNCOLLECTABLE -DNN_BUILD_TARGET_PLATFORM_NX"
?
ModuleInfo "CC_OPTS: -DJAVA_FINALIZATION"

?debug
ModuleInfo "CC_OPTS: -DBMX_DEBUG"
?

' uncomment to enable allocation counting
'ModuleInfo "CC_OPTS: -DBBCC_ALLOCCOUNT"

Import "blitz_app.c"
Import "blitz_types.c"
Import "blitz_cclib.c"
Import "blitz_memory.c"
Import "blitz_module.c"
Import "blitz_object.c"
Import "blitz_string.c"
Import "blitz_array.c"
Import "blitz_handle.c"
Import "blitz_debug.c"
Import "blitz_incbin.c"
Import "blitz_thread.c"
Import "blitz_ex.c"
Import "blitz_gc.c"
Import "blitz_unicode.c"
Import "blitz_enum.c"

'?Threaded
'Import "blitz_gc_ms.c"
'?Not Threaded
'Import "blitz_gc_rc.c"
'?

'?Win32X86
'Import "blitz_ex.win32.x86.s"
'Import "blitz_gc.win32.x86.s"
'Import "blitz_ftoi.win32.x86.s"
'?LinuxX86
'Import "blitz_ex.linux.x86.s"
'Import "blitz_gc.linux.x86.s"
'Import "blitz_ftoi.linux.x86.s"
'?MacosX86
'Import "blitz_ex.macos.x86.s"
'Import "blitz_gc.macos.x86.s"
'Import "blitz_ftoi.macos.x86.s"
'?MacosPPC
'Import "blitz_ex.macos.ppc.s"
'Import "blitz_gc.macos.ppc.s"
'?

Import "bdwgc/include/*.h"
Import "bdwgc/libatomic_ops/src/*.h"
Import "bdwgc/reclaim.c"
Import "bdwgc/allchblk.c"
Import "bdwgc/misc.c"
Import "bdwgc/alloc.c"
Import "bdwgc/mach_dep.c"
Import "bdwgc/os_dep.c"
Import "bdwgc/mark_rts.c"
Import "bdwgc/headers.c"
Import "bdwgc/mark.c"
Import "bdwgc/obj_map.c"
Import "bdwgc/blacklst.c"
Import "bdwgc/finalize.c"
Import "bdwgc/new_hblk.c"
Import "bdwgc/dyn_load.c"
Import "bdwgc/dbg_mlc.c"
Import "bdwgc/malloc.c"
Import "bdwgc/checksums.c"
Import "bdwgc/pthread_start.c"
Import "bdwgc/pthread_support.c"
Import "bdwgc/pthread_stop_world.c"
Import "bdwgc/darwin_stop_world.c"
Import "bdwgc/typd_mlc.c"
Import "bdwgc/ptr_chck.c"
Import "bdwgc/mallocx.c"
Import "bdwgc/gcj_mlc.c"
Import "bdwgc/specific.c"
Import "bdwgc/gc_dlopen.c"
Import "bdwgc/backgraph.c"
Import "bdwgc/win32_threads.c"
Import "bdwgc/thread_local_alloc.c"	'bdwgc only? not gc6.7
?nx
Import "blitz_nx.c"
?
Import "tree/tree.c"

Include "builtin.bmx"
Include "iterator.bmx"
Include "comparator.bmx"

Extern
Global OnDebugStop()="bbOnDebugStop"
Global OnDebugLog( message$ )="bbOnDebugLog"
End Extern

Rem
bbdoc: Exception
about: Common base class of the built-in exceptions of the language.
End Rem
Type TBlitzException
End Type

Rem
bbdoc: Null object exception
about: Thrown when a field or method of a Null object is accessed. (only in debug mode)
End Rem
Type TNullObjectException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to access field or method of Null object"
	End Method
End Type

Rem
bbdoc: Null method exception
about: Thrown when an abstract method is called.
End Rem
Type TNullMethodException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to call abstract method"
	End Method
End Type

Rem
bbdoc: Null function exception
about: Thrown when an uninitialized function pointer is called.
End Rem
Type TNullFunctionException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to call uninitialized function pointer"
	End Method
End Type

Rem
bbdoc: Array bounds exception
about: Thrown when an array element with an index outside the valid range of the array (0 to array.length-1) is accessed. (only in debug mode)
End Rem
Type TArrayBoundsException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to index array element beyond array length"
	End Method
End Type

Rem
bbdoc: Out of data exception
about: Thrown when #ReadData is used but not enough data is left to read. (only in debug mode)
End Rem
Type TOutOfDataException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to read beyond end of data"
	End Method
End Type

Rem
bbdoc: Runtime exception
about: Thrown by #RuntimeError.
End Rem
Type TRuntimeException Extends TBlitzException
	Field error$
	Method ToString$() Override
		Return error
	End Method
	Function Create:TRuntimeException( error$ )
		Local t:TRuntimeException=New TRuntimeException
		t.error=error
		Return t
	End Function
End Type

Rem
bbdoc: Invalid enum exception
about: Thrown when attempting to cast an invalid value to an #Enum. (only in debug mode)
End Rem
Type TInvalidEnumException Extends TBlitzException
	Method ToString$() Override
		Return "Attempt to cast invalid value to Enum"
	End Method
End Type

Function NullObjectError()
	Throw New TNullObjectException
End Function

Function NullMethodError()
	Throw New TNullMethodException
End Function

Function NullFunctionError()
	Throw New TNullFunctionException
End Function

Function ArrayBoundsError()
	Throw New TArrayBoundsException
End Function

Function OutOfDataError()
	Throw New TOutOfDataException
End Function

Function InvalidEnumError()
	Throw New TInvalidEnumException
End Function

Rem
bbdoc: Generate a runtime error
about: Throws a #TRuntimeException.
End Rem
Function RuntimeError( message$ )
	Throw TRuntimeException.Create( message )
End Function

Rem
bbdoc: Stop program execution and enter debugger
about: If there is no debugger present, this command is ignored.
end rem
Function DebugStop()
	OnDebugStop
End Function

Rem
bbdoc: Write a string to debug log
about: If there is no debugger present, this command is ignored.
end rem
Function DebugLog( message$ )
	OnDebugLog message
End Function

Extern

Rem
bbdoc: Application directory
about: The #AppDir global variable contains the fully qualified directory of the currently
executing application. An application's initial current directory is also set to #AppDir
when an application starts.

In a compiled DLL, the #AppDir global variable will instead contain the fully qualified
directory of the DLL.
End Rem
Global AppDir$="bbAppDir"

Rem
bbdoc: Application file name
about: The #AppFile global variable contains the fully qualified file name of the currently
executing application.

In a compiled DLL, the #AppFile global variable will instead contain the fully qualified
file name of the DLL.
End Rem
Global AppFile$="bbAppFile"

Rem
bbdoc: Application title
about: The #AppTitle global variable is used by various commands when a
default application title is required - for example, when opening simple 
windows or requesters.<br/>
<br/>
Initially, #AppTitle is set to the value "BlitzMax Application". However, you may change
#AppTitle at any time with a simple assignment.
End Rem
Global AppTitle$="bbAppTitle"

Rem
bbdoc: Arguments passed to the application at startup
about: The #AppArgs global array contains the command line parameters sent to an application
when it was started. The first element of #AppArgs always contains the name of the 
application. However, the format of the name may change depending on how the application
was launched. Use #AppDir or #AppFile for consistent information about the applications name
or directory.
End Rem
Global AppArgs$[]="bbAppArgs"

Rem
bbdoc: Directory from which application was launched
about: The #LaunchDir global variable contains the current directory at the time the
application was launched. This is mostly of use to command line tools which may need to
access the 'shell' current directory as opposed to the application directory.
End Rem
Global LaunchDir$="bbLaunchDir"

Rem
bbdoc: Add a function to be called when the program ends
about: #OnEnd allows you to specify a function to be called when the program ends. OnEnd functions are called
in the reverse order to that in which they were added.
end rem
Function OnEnd( fun() )="bbOnEnd"

Rem
bbdoc: Read a string from stdin
returns: A string read from stdin. The newline terminator, if any, is included in the returned string.
end rem
Function ReadStdin$()="bbReadStdin"

Rem
bbdoc: Write a string to stdout
about: Writes @str to stdout and flushes stdout.
end rem
Function WriteStdout( str$ )="bbWriteStdout"

Rem
bbdoc: Write a string to stderr
about: Writes @str to stderr and flushes stderr.
end rem
Function WriteStderr( str$ )="bbWriteStderr"

Rem
bbdoc: Wait for a given number of milliseconds
about:
#Delay suspends program execution for at least @millis milliseconds.<br/>
<br/>
A millisecond is one thousandth of a second.
End Rem
Function Delay( millis:Int )="bbDelay"

Rem
bbdoc: Wait for a given number of microseconds
about:
#UDelay suspends program execution for at least @microcseconds.<br/>
<br/>
A microsecond is one millionth of a second.
End Rem
Function UDelay( microseconds:Int )="void bbUDelay(int)!"

Rem
bbdoc: Get millisecond counter
returns: Milliseconds since computer turned on.
about:
#MilliSecs returns the number of milliseconds elapsed since the computer
was turned on.<br/>
<br/>
A millisecond is one thousandth of a second.
End Rem
Function MilliSecs:Int()="bbMilliSecs"

Rem
bbdoc: Allocate memory
returns: A new block of memory @size bytes long
End Rem
Function MemAlloc:Byte Ptr( size:Size_T )="void* bbMemAlloc( size_t )"

Rem
bbdoc: Free allocated memory
about: The memory specified by @mem must have been previously allocated by #MemAlloc or #MemExtend.
End Rem
Function MemFree( mem:Byte Ptr )="void bbMemFree( void * )"

Rem
bbdoc: Extend a block of memory
returns: A new block of memory @new_size bytes long
about: An existing block of memory specified by @mem and @size is copied into a new block
of memory @new_size bytes long. The existing block is released and the new block is returned. 
End Rem
Function MemExtend:Byte Ptr( mem:Byte Ptr,size:Size_T,new_size:Size_T )="void* bbMemExtend( void *,size_t ,size_t )"

Rem
bbdoc: Clear a block of memory to 0
End Rem
Function MemClear( mem:Byte Ptr,size:Size_T )="void bbMemClear( void *,size_t )"

Rem
bbdoc: Copy a non-overlapping block of memory
End Rem
Function MemCopy( dst:Byte Ptr,src:Byte Ptr,size:Size_T )="void bbMemCopy( void *,const void *,size_t )"

Rem
bbdoc: Copy a potentially overlapping block of memory
End Rem
Function MemMove( dst:Byte Ptr,src:Byte Ptr,size:Size_T )="void bbMemMove( void *,const void *,size_t )"

Rem
bbdoc: Set garbage collector mode
about:
@mode can be one of the following:<br/>
1 : automatic GC - memory will be automatically garbage collected<br/>
2 : manual GC - no memory will be collected until a call to GCCollect is made<br/>
<br/>
The default GC mode is automatic GC.
End Rem
Function GCSetMode( Mode:Int )="bbGCSetMode"

Rem
bbdoc: Suspend garbage collector
about:
#GCSuspend temporarily suspends the garbage collector. No garbage
collection will be performed following a call to #GCSuspend.<br/>
<br/>
Use #GCResume to resume the garbage collector. Note that #GCSuspend
and #GCResume 'nest', meaning that each call to #GCSuspend must be 
matched by a call to #GCResume.
End Rem
Function GCSuspend()="bbGCSuspend"

Rem
bbdoc: Resume garbage collector
about:
#GCResume resumes garbage collection following a call to #GCSuspend.<br/>
<br/>
See #GCSuspend for more details.
End Rem
Function GCResume()="bbGCResume"

Rem
bbdoc: Run garbage collector
returns: The amount of memory, in bytes, collected.
about:
This function will have no effect if the garbage collector has been
suspended due to #GCSuspend.
End Rem
Function GCCollect:Size_T()="bbGCCollect"

Rem
bbdoc: Run garbage collector, collecting a little
returns: Returns 0 if there is no more to collect.
about:
This function will have no effect if the garbage collector has been
suspended due to #GCSuspend.
End Rem
Function GCCollectALittle:Int()="bbGCCollectALittle"

Rem
bbdoc: Memory allocated by application
returns: The amount of memory, in bytes, currently allocated by the application
about:
This function only returns 'managed memory'. This includes all objects, strings and
arrays in use by the application.
End Rem
Function GCMemAlloced:Size_T()="bbGCMemAlloced"

Rem
bbdoc: Private: do not use
End Rem
Function GCEnter()="bbGCEnter"

Rem
bbdoc: Private: do not use
End Rem
Function GCLeave()="bbGCLeave"

Rem
bbdoc: Retains a reference to the specified #Object, preventing it from being collected.
End Rem
Function GCRetain(obj:Object)="bbGCRetain"

Rem
bbdoc: Releases a reference from the specified #Object.
End Rem
Function GCRelease(obj:Object)="void bbGCRelease(BBObject*)!"

Rem
bbdoc: Returns #True if the current thread is registered with the garbage collector.
End Rem
Function GCThreadIsRegistered:Int()="bbGCThreadIsRegistered"

Rem
bbdoc: Registers the current thread with the garbage collector.
returns: 0 on success, 1 if the thread was already registered, or -1 if threads are not supported.
End Rem
Function GCRegisterMyThread:Int()="bbGCRegisterMyThread"

Rem
bbdoc: Unregisters the previously registered current thread.
about: Note, that any memory allocated by the garbage collector from the current thread will no longer be
accessible after the thread is unregistered.
End Rem
Function GCUnregisterMyThread:Int()="bbGCUnregisterMyThread"

Rem
bbdoc: Convert object to integer handle
returns: An integer object handle
about:
After converting an object to an integer handle, you must later
release it using the #Release command.
End Rem
Function HandleFromObject:Size_T( obj:Object )="bbHandleFromObject"

Rem
bbdoc: Convert integer handle to object
returns: The object associated with the integer handle
End Rem
Function HandleToObject:Object( handle:Size_T )="bbHandleToObject"

Rem
bbdoc: Copies an array from the specified @src array, starting at the position @srcPos, to the position @dstPos of the destination array.
End Rem
Function ArrayCopy(src:Object, srcPos:Int, dst:Object, dstPos:Int, length:Int)="void bbArrayCopy(BBARRAY, int, BBARRAY, int, int)!"

Rem
bbdoc: Determines whether the #Object @obj is an empty array.
returns: #True if @obj is an empty array, or #False otherwise.
End Rem
Function IsEmptyArray:Int(obj:Object)="int bbObjectIsEmptyArray(BBOBJECT)!"
Rem
bbdoc: Determines whether the #Object @obj is an empty #String.
returns: #True if @obj is an empty #String, or #False otherwise.
End Rem
Function IsEmptyString:Int(obj:Object)="int bbObjectIsEmptyString(BBOBJECT)!"

Rem
bbdoc: Determines whether the #Object @obj is a #String.
returns: #True if @obj is a #String, or #False otherwise.
End Rem
Function ObjectIsString:Int(obj:Object)="int bbObjectIsString(BBOBJECT)!"

Function DumpObjectCounts(buffer:Byte Ptr, size:Int, includeZeros:Int)="bbObjectDumpInstanceCounts"
Global CountObjectInstances:Int="bbCountInstances"

End Extern

Rem
bbdoc: Provides a mechanism for releasing resources.
End Rem
Interface IDisposable

	Rem
	bbdoc: Performs application-defined tasks associated with freeing, releasing, or resetting resources.
	End Rem
	Method Dispose()

End Interface

'BlitzMax keyword definitions

Rem
bbdoc: Set strict mode
about:
See the <a href="../../../../doc/bmxlang/compatibility.html">BlitzMax Language Reference</a> for more information on Strict mode programming.
keyword: "Strict"
End Rem

Rem
bbdoc: Set SuperStrict mode
keyword: "SuperStrict"
End Rem

Rem
bbdoc: End program execution
keyword: "End"
End Rem

Rem
bbdoc: Begin a remark block
keyword: "Rem"
End Rem

Rem
bbdoc: End a remark block
keyword: "EndRem"
End Rem

Rem
bbdoc: Constant integer of value 1
keyword: "True"
End Rem

Rem
bbdoc: Constant integer of value 0
keyword: "False"
End Rem

Rem
bbdoc: Constant pi value: 3.1415926535897932384626433832795
keyword: "Pi"
End Rem

Rem
bbdoc: Get Null value (default value for types)
keyword: "Null"
End Rem

Rem
bbdoc: Unsigned 8 bit integer type
keyword: "Byte"
End Rem

Rem
bbdoc: Unsigned 16 bit integer type
keyword: "Short"
End Rem

Rem
bbdoc: Signed 32 bit integer type
keyword: "Int"
End Rem

Rem
bbdoc: Unsigned 32 bit integer type
keyword: "UInt"
End Rem

Rem
bbdoc: Signed 64 bit integer type
keyword: "Long"
End Rem

Rem
bbdoc: Unsigned 64 bit integer type
keyword: "ULong"
End Rem

Rem
bbdoc: Unsigned 32/64 bit integer type
keyword: "Size_T"
End Rem

Rem
bbdoc: Signed 32/64 bit LPARAM WinAPI type
keyword: "LParam"
about: Only available on Windows.
End Rem

Rem
bbdoc: Unsigned 32/64 bit WPARAM WinAPI type
keyword: "WParam"
about: Only available on Windows.
End Rem

Rem
bbdoc: 32 bit floating point type
keyword: "Float"
End Rem

Rem
bbdoc: 64 bit floating point type
keyword: "Double"
End Rem

Rem
bbdoc: 128 bit integer intrinsic type
about: Only available on x64.
keyword: "Int128"
End Rem

Rem
bbdoc: 64 bit floating point intrinsic type
about: Only available on x64.
keyword: "Float64"
End Rem

Rem
bbdoc: 128 bit floating point intrinsic type
about: Only available on x64.
keyword: "Float128"
End Rem

Rem
bbdoc: 128 bit floating point intrinsic type
about: Only available on x64.
keyword: "Double128"
End Rem

Rem
bbdoc: String type
keyword: "String"
End Rem

Rem
bbdoc: Object type
keyword: "Object"
End Rem

Rem
bbdoc: Composite type specifier for 'by reference' types
keyword: "Var"
End Rem

Rem
bbdoc: Composite type specifier for pointer types
keyword: "Ptr"
End Rem

Rem
bbdoc: Begin a conditional block.
keyword: "If"
End Rem

Rem
bbdoc: Optional separator between the condition and associated code in an If statement.
keyword: "Then"
End Rem

Rem
bbdoc: Else provides the ability for an If-Then construct to execute a second block of code when the If condition is false.
keyword: "Else"
End Rem

Rem
bbdoc: ElseIf provides the ability to test and execute a section of code if the initial condition failed.
keyword: "ElseIf"
End Rem

Rem
bbdoc: Marks the End of an If-Then construct.
keyword: "EndIf"
End Rem

Rem
bbdoc: Marks the start of a loop that uses an iterator to execute a section of code repeatedly.
keyword: "For"
End Rem

Rem
bbdoc: Followed by a constant which is used to calculate when to exit a For..Next loop.
keyword: "To"
End Rem

Rem
bbdoc: Specifies an optional constant that is used to increment the For iterator.
keyword: "Step"
End Rem

Rem
bbdoc: End a For block
keyword: "Next"
End Rem

Rem
bbdoc: Iterate through an array or collection
keyword: "EachIn"
End Rem

Rem
bbdoc: Execute a block of code while a condition is true
keyword: "While"
End Rem

Rem
bbdoc: End a While block
keyword: "Wend"
End Rem

Rem
bbdoc: End a While block
keyword: "EndWhile"
End Rem

Rem
bbdoc: Execute a block of code until a termination condition is met, or forever
keyword: "Repeat"
End Rem

Rem
bbdoc: Conditionally continue a Repeat block
keyword: "Until"
End Rem

Rem
bbdoc: Continue a Repeat block forever
keyword: "Forever"
End Rem

Rem
bbdoc: Begin a Select block
keyword: "Select"
End Rem

Rem
bbdoc: End a Select block
keyword: "EndSelect"
End Rem

Rem
bbdoc: Conditional code inside a Select block
keyword: "Case"
End Rem

Rem
bbdoc: Default code inside a Select block
keyword: "Default"
End Rem

Rem
bbdoc: Exit enclosing loop
keyword: "Exit"
End Rem

Rem
bbdoc: Continue execution of enclosing loop
keyword: "Continue"
End Rem

Rem
bbdoc: Declare a constant
keyword: "Const"
End Rem

Rem
bbdoc: Declare a local variable
keyword: "Local"
End Rem

Rem
bbdoc: Declare a global variable
keyword: "Global"
End Rem

Rem
bbdoc: Declare a field variable
keyword: "Field"
End Rem

Rem
bbdoc: Begin a function declaration
keyword: "Function"
End Rem

Rem
bbdoc: End a function declaration
keyword: "EndFunction"
End Rem

Rem
bbdoc: Begin a method declaration
keyword: "Method"
End Rem

Rem
bbdoc: End a method declaration
keyword: "EndMethod"
End Rem

Rem
bbdoc: Return from a method or function
keyword: "Return"
End Rem

Rem
bbdoc: Begin a user defined class declaration
keyword: "Type"
End Rem

Rem
bbdoc: End a user defined class declaration
keyword: "EndType"
End Rem

Rem
bbdoc: Begin a user defined interface declaration
keyword: "Interface"
End Rem

Rem
bbdoc: End a user defined interface declaration
keyword: "EndInterface"
End Rem

Rem
bbdoc: Begin a user defined structure declaration
keyword: "Struct"
End Rem

Rem
bbdoc: End a user defined structure declaration
keyword: "EndStruct"
End Rem

Rem
bbdoc: Begin an enumeration declaration
keyword: "Enum"
End Rem

Rem
bbdoc: End an enumeration declaration
keyword: "EndEnum"
End Rem

Rem
bbdoc: Specify supertype(s) of a user defined type
keyword: "Extends"
End Rem

Rem
bbdoc: Specify implemented interface(s) of a user defined type
keyword: "Implements"
End Rem

Rem
bbdoc: Denote a class, function or method as abstract
keyword: "Abstract"
End Rem

Rem
bbdoc: Denote a class, function or method as final
keyword: "Final"
End Rem

Rem
bbdoc: Denote a field as read only, where the value may only be set in its declaration or in the type constructor
keyword: "ReadOnly"
End Rem

Rem
bbdoc: Denote a function for export to a shared library. The generated function name will not be mangled.
keyword: "Export"
End Rem

Rem
bbdoc: Indicates that a method declaration is intended to override a method declaration in a supertype.
about: Use of #Override on a method that does not override a method will result in a compilation error.
keyword: "Override"
End Rem

Rem
bbdoc: Specify constraints on the types that can be used as arguments for a type parameter defined in a generic declaration
keyword: "Where"
End Rem

Rem
bbdoc: Create an instance of a user defined type, or specify a custom constructor
keyword: "New"
End Rem

Rem
bbdoc: Specify a custom finalizer
keyword: "Delete"
End Rem

Rem
bbdoc: Reference to this method's type instance
keyword: "Self"
End Rem

Rem
bbdoc: Reference to the super type instance
keyword: "Super"
End Rem

Rem
bbdoc: Release an integer object handle
keyword: "Release"
End Rem

Rem
bbdoc: Make types, constants, global variables, functions or type members accessible from outside the current source file (default)
keyword: "Public"
End Rem

Rem
bbdoc: Make types, constants, global variables, functions or type members only accessible from within the current source file.
keyword: "Private"
End Rem

Rem
bbdoc: Make type members only accessible from within the current source file and within subtypes.
keyword: "Protected"
End Rem

Rem
bbdoc: Begin an Extern section (a list of imported external declarations)
keyword: "Extern"
End Rem

Rem
bbdoc: End an Extern section
keyword: "EndExtern"
End Rem

Rem
bbdoc: Declare module scope and identifier
about:
See the <a href="../../../../doc/bmxlang/modules.html">BlitzMax Language Reference</a> for more information on BlitzMax Modules.
keyword: "Module"
End Rem

Rem
bbdoc: Define module properties
keyword: "ModuleInfo"
End Rem

Rem
bbdoc: Embed a data file
keyword: "Incbin"
End Rem

Rem
bbdoc: Get start address of embedded data file
keyword: "IncbinPtr"
End Rem

Rem
bbdoc: Get length of embedded data file
keyword: "IncbinLen"
End Rem

Rem
bbdoc: Include effectively 'inserts' the specified file into the file being compiled.
keyword: "Include"
End Rem

Rem
bbdoc: Framework builds the BlitzMax application with only the module(s) specified rather than the standard set of modules.
keyword: "Framework"
End Rem

Rem
bbdoc: Import declarations from a module or source file
keyword: "Import"
End Rem

Rem
bbdoc: Throw a RuntimeError if a condition is false
keyword: "Assert"
End Rem

Rem
bbdoc: Transfer program flow to specified label
keyword: "Goto"
End Rem

Rem
bbdoc: Begin declaration of a Try block
keyword: "Try"
End Rem

Rem
bbdoc: Catch an exception object in a Try block
keyword: "Catch"
End Rem

Rem
bbdoc: Execute a block of code upon exiting a Try or Catch block
keyword: "Finally"
End Rem

Rem
bbdoc: End declaration of a Try block
keyword: "EndTry"
End Rem

Rem
bbdoc: Throw an exception object to the enclosing Try block
keyword: "Throw"
End Rem

Rem
bbdoc: Define classic BASIC style data
keyword: "DefData"
End Rem

Rem
bbdoc: Read classic BASIC style data
keyword: "ReadData"
End Rem

Rem
bbdoc: Restore classic BASIC style data
keyword: "RestoreData"
End Rem

Rem
bbdoc: Conditional 'And' binary operator
keyword: "And"
End Rem

Rem
bbdoc: Conditional 'Or' binary operator
keyword: "Or"
End Rem

Rem
bbdoc: Conditional 'Not' binary operator
keyword: "Not"
End Rem

Rem
bbdoc: Bitwise 'Shift left' binary operator
keyword: "Shl"
End Rem

Rem
bbdoc: Bitwise 'Shift right' binary operator
keyword: "Shr"
End Rem

Rem
bbdoc: Bitwise 'Shift arithmetic right' binary operator
keyword: "Sar"
End Rem

Rem
bbdoc: Number of characters in a string or elements in an array
keyword: "Len"
End Rem

Rem
bbdoc: Numeric 'modulus' or 'remainder' binary operator
keyword: "Mod"
End Rem

Rem
bbdoc: Find the address of a variable
keyword: "Varptr"
End Rem

Rem
bbdoc: Size, in bytes, occupied by a variable, string, array or object
keyword: "SizeOf"
End Rem

Rem
bbdoc: Get character value of the first character of a string
keyword: "Asc"
End Rem

Rem
bbdoc: Create a string of length 1 with a character code
keyword: "Chr"
End Rem

Rem
bbdoc: Allocates memory from the stack.
keyword: "StackAlloc"
about: This memory is automatically freed on leaving the function where it was created.
It should not be freed, or returned from the function.
End Rem

Rem
bbdoc: Returns the offset in bytes for a field of the specified #Type or #Struct.
keyword: "FieldOffset"
End Rem

Rem
bbdoc: Denotes an array as a static array, with its content allocated on the stack.
keyword: "StaticArray"
End Rem
