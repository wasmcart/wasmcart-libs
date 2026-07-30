#include <png.h>
#include <string.h>

int smoke(void) {
    static const unsigned char pixels[16] = {
        255, 0, 0, 255, 0, 255, 0, 255,
        0, 0, 255, 255, 255, 255, 255, 255
    };
    unsigned char encoded[4096];
    unsigned char decoded[sizeof pixels];
    png_alloc_size_t encoded_size = sizeof encoded;
    png_image image;

    memset(&image, 0, sizeof image);
    image.version = PNG_IMAGE_VERSION;
    image.width = 2;
    image.height = 2;
    image.format = PNG_FORMAT_RGBA;
    if (!png_image_write_to_memory(
            &image, encoded, &encoded_size, 0, pixels, 0, 0)) {
        return 1;
    }

    memset(&image, 0, sizeof image);
    image.version = PNG_IMAGE_VERSION;
    if (!png_image_begin_read_from_memory(&image, encoded, encoded_size)) {
        return 2;
    }
    image.format = PNG_FORMAT_RGBA;
    if (!png_image_finish_read(&image, 0, decoded, 0, 0)) {
        return 3;
    }
    if (image.width != 2 || image.height != 2 ||
        memcmp(decoded, pixels, sizeof pixels) != 0) {
        return 4;
    }
    png_image_free(&image);

    /* Invalid input must travel through libpng's setjmp/longjmp error path and
       return a normal API failure instead of trapping the cart. */
    memset(&image, 0, sizeof image);
    image.version = PNG_IMAGE_VERSION;
    if (png_image_begin_read_from_memory(&image, "not a png", 9)) {
        png_image_free(&image);
        return 5;
    }

    return 42;
}
