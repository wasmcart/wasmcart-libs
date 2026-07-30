#include <string.h>
#include <zlib.h>

int smoke(void) {
    const unsigned char input[] = "wasmcart";
    unsigned char output[64];
    uLongf output_size = sizeof(output);
    return compress(output, &output_size, input, strlen((const char *)input)) == Z_OK;
}
