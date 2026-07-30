#include <vorbis/codec.h>

int smoke(void) {
    vorbis_info info;
    vorbis_info_init(&info);
    vorbis_info_clear(&info);
    return 1;
}
