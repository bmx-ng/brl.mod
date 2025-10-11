
#include "blitz.h"

#ifdef BMX_COVERAGE

BBString * bbCoverageOutputFileName = &bbEmptyString;

Hashmap* BBCoverageLineExecInfoTable;

static int hashmapStringHash(intptr_t key) {
    const char* str = (const char*)key;
    int64_t hash = 0;

    while (*str) {
        hash = (31 * hash + *str++) % 0x7FFFFFFF;
    }

    return (int)(hash % 0x7FFFFFFF);
}

static int hashmapStringEquals(intptr_t keyA, intptr_t keyB) {
    const char* strA = (const char*)keyA;
    const char* strB = (const char*)keyB;

    return strcmp(strA, strB) == 0;
}

void bbCoverageStartup() {
    BBCoverageLineExecInfoTable = hashmapCreate(64, hashmapStringHash, hashmapStringEquals);
}

void bbCoverageRegisterFile(BBCoverageFileInfo * coverage_files) {

    for (int i = 0; coverage_files[i].filename != NULL; i++) {
        BBCoverageFileInfo * coverage_file = &coverage_files[i];
        
        if (coverage_file->line_map == NULL) {
            coverage_file->line_map = hashmapCreate(64, hashmapIntHash, hashmapIntEquals);
            hashmapPut(BBCoverageLineExecInfoTable, (intptr_t)coverage_file->filename, coverage_file);
        }
        
        if (coverage_file->func_map == NULL) {
            coverage_file->func_map = hashmapCreate(64, hashmapIntHash, hashmapIntEquals);
        }
 
        for (int j = 0; j < coverage_file->coverage_lines_count; j++) {
            BBCoverageLineExecInfo* info = (BBCoverageLineExecInfo*) malloc(sizeof(BBCoverageLineExecInfo));
            info->file = coverage_file->filename;
            info->line = coverage_file->coverage_lines[j];
            info->count = 0;
            hashmapPut(coverage_file->line_map, (intptr_t)info->line, info);
        }

        for (int j = 0; j < coverage_file->coverage_functions_count; j++) {
            BBCoverageFuncExecInfo* info = (BBCoverageFuncExecInfo*) malloc(sizeof(BBCoverageFuncExecInfo));
            info->func = coverage_file->coverage_functions[j].func;
            info->line = coverage_file->coverage_functions[j].line;
            info->count = 0;
            hashmapPut(coverage_file->func_map, (intptr_t)info->line, info);
        }
    }
}

void bbCoverageUpdateLineInfo(const char* file, int line) {
    BBCoverageFileInfo * coverage_file = (Hashmap*) hashmapGet(BBCoverageLineExecInfoTable, (intptr_t)file);
    
    if (!coverage_file) {
        // error

        return;
    }

    BBCoverageLineExecInfo* info = (BBCoverageLineExecInfo*) hashmapGet(coverage_file->line_map, (intptr_t)line);
    
    if (!info) {
        info = (BBCoverageLineExecInfo*) malloc(sizeof(BBCoverageLineExecInfo));
        info->file = file;
        info->line = line;
        info->count = 0;
        hashmapPut(coverage_file->line_map, (intptr_t)line, info);
    }

    info->count++;
}

void bbCoverageUpdateFunctionLineInfo(const char* file, const char* func, int line) {
    BBCoverageFileInfo * coverage_file = (Hashmap*) hashmapGet(BBCoverageLineExecInfoTable, (intptr_t)file);
    
    if (!coverage_file) {
        // error

        return;
    }

    BBCoverageFuncExecInfo* info = (BBCoverageFuncExecInfo*) hashmapGet(coverage_file->func_map, (intptr_t)line);
    
    if (!info) {
        info = (BBCoverageFuncExecInfo*) malloc(sizeof(BBCoverageFuncExecInfo));
        info->file = file;
        info->func = func;
        info->line = line;
        info->count = 0;
        hashmapPut(coverage_file->line_map, (intptr_t)line, info);
    }

    info->count++;
}

static int write_line_exec_info(intptr_t key, void* value, void* context) {
    BBCoverageLineExecInfo* info = (BBCoverageLineExecInfo*)value;
    FILE* lcov_file = (FILE*)context;
    fprintf(lcov_file, "DA:%d,%d\n", info->line, info->count);
    return 1;
}

static bool write_file_exec_info(intptr_t key, void* value, void* context) {
    const char* file = (const char*)key;
    BBCoverageFileInfo* coverage_file = (BBCoverageFileInfo*)value;
    FILE* lcov_file = (FILE*)context;

    fprintf(lcov_file, "SF:%s\n", file);

    int lines_hit = 0;
    for (int i=0; i < coverage_file->coverage_lines_count; i++) {
        BBCoverageLineExecInfo* info = (BBCoverageLineExecInfo*) hashmapGet(coverage_file->line_map, (intptr_t)coverage_file->coverage_lines[i]);
        if (info) {
            if (info->count > 0) {
                lines_hit++;
            }
            fprintf(lcov_file, "DA:%d,%d\n", info->line, info->count);
        }
    }

    fprintf(lcov_file, "LF:%d\n", coverage_file->coverage_lines_count);
    fprintf(lcov_file, "LH:%d\n", lines_hit);

    int functions_hit = 0;
    for (int i=0; i < coverage_file->coverage_functions_count; i++) {
        BBCoverageFuncExecInfo* info = (BBCoverageFuncExecInfo*) hashmapGet(coverage_file->func_map, (intptr_t)coverage_file->coverage_functions[i].line);
        if (info) {
            if (info->count > 0) {
                functions_hit++;
            }
            fprintf(lcov_file, "FN:%d,%s\n", info->line, info->func);
            fprintf(lcov_file, "FNDA:%d,%d\n", info->count, info->line);
        }
    }

    fprintf(lcov_file, "FNF:%d\n", coverage_file->coverage_functions_count);
    fprintf(lcov_file, "FNH:%d\n", functions_hit);

    // Write the end of record marker
    fprintf(lcov_file, "end_of_record\n");

    return 1;
}

void bbCoverageGenerateOutput() {

    const char* output_file_name;

    if ( bbCoverageOutputFileName == &bbEmptyString ) {
        output_file_name = "lcov.info";
    } else {
        output_file_name = bbStringToUTF8String(bbCoverageOutputFileName);
    }
    
    FILE* lcov_file = fopen(output_file_name, "w");
    if (!lcov_file) {
        printf("Error: Unable to open output file: %s\n", output_file_name);
        return;
    }

    // Iterate through the global hash table (BBCoverageLineExecInfoTable) and write file coverage data
    hashmapForEach(BBCoverageLineExecInfoTable, write_file_exec_info, lcov_file);

    fclose(lcov_file);
}


#endif // BMX_COVERAGE
