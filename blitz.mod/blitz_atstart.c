#include <stdlib.h>
#include "blitz_atstart.h"

typedef struct bb_node {
    bb_startup_fn fn;
    int priority;
    struct bb_node *next;
} bb_node;

static bb_node *g_head = NULL; // sorted: higher priority first, FIFO within ties
static int      g_ran  = 0; // has the startup pass completed?

int bbAtstart(bb_startup_fn fn, int priority) {
    if (!fn) {
        return 0;
    }

    // If startup already ran, run immediately.
    if (g_ran) {
        fn(); return 1;
    }

    bb_node *n = (bb_node *)malloc(sizeof(*n));
    if (!n) {
        return 0;
    }
    n->fn = fn; n->priority = priority; n->next = NULL;

    // Insert at head if list is empty or higher priority than head.
    if (!g_head || priority > g_head->priority) {
        n->next = g_head;
        g_head = n;
        return 1;
    }

    // Walk past strictly higher priorities...
    bb_node *cur = g_head;
    while (cur->next && cur->next->priority > priority) cur = cur->next;
    // ...then past equals to keep FIFO for ties.
    while (cur->next && cur->next->priority == priority) cur = cur->next;

    n->next = cur->next;
    cur->next = n;
    return 1;
}

void bbRunAtstart(void) {
    // Pop-and-run until empty.
    while (g_head) {
        bb_node *n = g_head;
        g_head = n->next;

        bb_startup_fn fn = n->fn;
        free(n);
        fn();
    }
    g_ran = 1;
}
