#define NK_INCLUDE_DEFAULT_ALLOCATOR
#include <nuklear.h>

int smoke(void) {
    struct nk_context context;
    if (!nk_init_default(&context, 0)) {
        return 0;
    }
    nk_clear(&context);
    nk_free(&context);
    return 1;
}
