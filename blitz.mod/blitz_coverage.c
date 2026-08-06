#include "blitz.h"

#ifdef BMX_COVERAGE

BBString * bbCoverageOutputFileName = &bbEmptyString;

typedef struct BBCoverageFileState BBCoverageFileState;

struct BBCoverageFileState {
    const char *filename;
    Hashmap *line_map;
    BBCoverageLineExecInfo **lines;
    size_t lines_count;
    size_t lines_capacity;
    BBCoverageFuncExecInfo **functions;
    size_t functions_count;
    size_t functions_capacity;
    BBCoverageFileState *next;
};

static Hashmap *bbCoverageFileTable;
static BBCoverageFileState *bbCoverageFiles;
static BBCoverageFileState **bbCoverageFilesTail = &bbCoverageFiles;
static bb_mutex_t bbCoverageMutex;

static int hashmapStringHash(intptr_t key) {
    const char *str = (const char *)key;
    int64_t hash = 0;

    while (*str) {
        hash = (31 * hash + *str++) % 0x7FFFFFFF;
    }

    return (int)(hash % 0x7FFFFFFF);
}

static int hashmapStringEquals(intptr_t keyA, intptr_t keyB) {
    return strcmp((const char *)keyA, (const char *)keyB) == 0;
}

static void *bbCoverageGrow(void *items, size_t *capacity, size_t item_size) {
    size_t next_capacity = *capacity ? *capacity * 2 : 16;
    void *next = realloc(items, next_capacity * item_size);
    if (!next) {
        fprintf(stderr, "Coverage bookkeeping allocation failed\n");
        abort();
    }
    *capacity = next_capacity;
    return next;
}

static BBCoverageFileState *bbCoverageFindFile(const char *filename) {
    return (BBCoverageFileState *)hashmapGet(bbCoverageFileTable, (intptr_t)filename);
}

static BBCoverageFileState *bbCoverageAddFile(const char *filename) {
    BBCoverageFileState *state = (BBCoverageFileState *)calloc(1, sizeof(BBCoverageFileState));
    if (!state) {
        fprintf(stderr, "Coverage bookkeeping allocation failed\n");
        abort();
    }
    state->filename = filename;
    state->line_map = hashmapCreate(64, hashmapIntHash, hashmapIntEquals);
    hashmapPut(bbCoverageFileTable, (intptr_t)filename, state);
    *bbCoverageFilesTail = state;
    bbCoverageFilesTail = &state->next;
    return state;
}

static BBCoverageLineExecInfo *bbCoverageAddLine(BBCoverageFileState *state, int line) {
    BBCoverageLineExecInfo *info = (BBCoverageLineExecInfo *)hashmapGet(state->line_map, (intptr_t)line);
    if (info) return info;

    info = (BBCoverageLineExecInfo *)calloc(1, sizeof(BBCoverageLineExecInfo));
    if (!info) {
        fprintf(stderr, "Coverage bookkeeping allocation failed\n");
        abort();
    }
    info->file = state->filename;
    info->line = line;
    hashmapPut(state->line_map, (intptr_t)line, info);
    if (state->lines_count == state->lines_capacity) {
        state->lines = (BBCoverageLineExecInfo **)bbCoverageGrow(state->lines, &state->lines_capacity, sizeof(BBCoverageLineExecInfo *));
    }
    state->lines[state->lines_count++] = info;
    return info;
}

static BBCoverageFuncExecInfo *bbCoverageFindFunction(BBCoverageFileState *state, const char *func, int line) {
    for (size_t i = 0; i < state->functions_count; ++i) {
        BBCoverageFuncExecInfo *info = state->functions[i];
        if (info->line == line && strcmp(info->func, func) == 0) return info;
    }
    return NULL;
}

static BBCoverageFuncExecInfo *bbCoverageAddFunction(BBCoverageFileState *state, const char *func, int line) {
    BBCoverageFuncExecInfo *info = bbCoverageFindFunction(state, func, line);
    if (info) return info;

    info = (BBCoverageFuncExecInfo *)calloc(1, sizeof(BBCoverageFuncExecInfo));
    if (!info) {
        fprintf(stderr, "Coverage bookkeeping allocation failed\n");
        abort();
    }
    info->file = state->filename;
    info->func = func;
    info->line = line;
    if (state->functions_count == state->functions_capacity) {
        state->functions = (BBCoverageFuncExecInfo **)bbCoverageGrow(state->functions, &state->functions_capacity, sizeof(BBCoverageFuncExecInfo *));
    }
    state->functions[state->functions_count++] = info;
    return info;
}

void bbCoverageStartup() {
    bbCoverageFileTable = hashmapCreate(64, hashmapStringHash, hashmapStringEquals);
    bbCoverageFiles = NULL;
    bbCoverageFilesTail = &bbCoverageFiles;
    bb_mutex_init(&bbCoverageMutex);
}

void bbCoverageRegisterFile(BBCoverageFileInfo *coverage_files) {
    bb_mutex_lock(&bbCoverageMutex);
    for (int i = 0; coverage_files[i].filename != NULL; ++i) {
        BBCoverageFileInfo *coverage_file = &coverage_files[i];
        BBCoverageFileState *state = bbCoverageFindFile(coverage_file->filename);
        if (!state) state = bbCoverageAddFile(coverage_file->filename);

        for (size_t j = 0; j < coverage_file->coverage_lines_count; ++j) {
            bbCoverageAddLine(state, coverage_file->coverage_lines[j]);
        }
        for (size_t j = 0; j < coverage_file->coverage_functions_count; ++j) {
            const BBCoverageFunctionInfo *function = &coverage_file->coverage_functions[j];
            bbCoverageAddFunction(state, function->func, function->line);
        }
    }
    bb_mutex_unlock(&bbCoverageMutex);
}

void bbCoverageUpdateLineInfo(const char *file, int line) {
    bb_mutex_lock(&bbCoverageMutex);
    BBCoverageFileState *state = bbCoverageFindFile(file);
    if (state) bbCoverageAddLine(state, line)->count++;
    bb_mutex_unlock(&bbCoverageMutex);
}

void bbCoverageUpdateFunctionLineInfo(const char *file, const char *func, int line) {
    bb_mutex_lock(&bbCoverageMutex);
    BBCoverageFileState *state = bbCoverageFindFile(file);
    if (state) bbCoverageAddFunction(state, func, line)->count++;
    bb_mutex_unlock(&bbCoverageMutex);
}

void bbCoverageGenerateOutput() {
    const char *output_file_name;
    char *allocated_output_file_name = NULL;

    if (bbCoverageOutputFileName == &bbEmptyString) {
        output_file_name = "lcov.info";
    } else {
        allocated_output_file_name = bbStringToUTF8String(bbCoverageOutputFileName);
        output_file_name = allocated_output_file_name;
    }

    FILE *lcov_file = fopen(output_file_name, "w");
    if (!lcov_file) {
        fprintf(stderr, "Error: Unable to open coverage output file: %s\n", output_file_name);
        if (allocated_output_file_name) bbMemFree(allocated_output_file_name);
        return;
    }

    bb_mutex_lock(&bbCoverageMutex);
    for (BBCoverageFileState *state = bbCoverageFiles; state; state = state->next) {
        int lines_hit = 0;
        int functions_hit = 0;
        fprintf(lcov_file, "SF:%s\n", state->filename);

        for (size_t i = 0; i < state->functions_count; ++i) {
            BBCoverageFuncExecInfo *info = state->functions[i];
            if (info->count > 0) ++functions_hit;
            fprintf(lcov_file, "FN:%d,%s\n", info->line, info->func);
        }
        for (size_t i = 0; i < state->functions_count; ++i) {
            BBCoverageFuncExecInfo *info = state->functions[i];
            fprintf(lcov_file, "FNDA:%d,%s\n", info->count, info->func);
        }
        fprintf(lcov_file, "FNF:%zu\n", state->functions_count);
        fprintf(lcov_file, "FNH:%d\n", functions_hit);

        for (size_t i = 0; i < state->lines_count; ++i) {
            BBCoverageLineExecInfo *info = state->lines[i];
            if (info->count > 0) ++lines_hit;
            fprintf(lcov_file, "DA:%d,%d\n", info->line, info->count);
        }
        fprintf(lcov_file, "LF:%zu\n", state->lines_count);
        fprintf(lcov_file, "LH:%d\n", lines_hit);
        fprintf(lcov_file, "end_of_record\n");
    }
    bb_mutex_unlock(&bbCoverageMutex);

    fclose(lcov_file);
    if (allocated_output_file_name) bbMemFree(allocated_output_file_name);
}

#endif // BMX_COVERAGE
