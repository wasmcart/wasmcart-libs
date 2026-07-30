#include <xmp.h>

int smoke(void) {
    xmp_context context = xmp_create_context();
    if (!context) {
        return 0;
    }
    xmp_free_context(context);
    return 1;
}
