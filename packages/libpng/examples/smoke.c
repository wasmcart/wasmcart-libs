#include <png.h>

int smoke(void) {
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, 0, 0, 0);
    if (!png) {
        return 0;
    }
    png_destroy_read_struct(&png, 0, 0);
    return 1;
}
