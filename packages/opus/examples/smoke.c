#include <opus/opus.h>

int smoke(void) {
    int error = OPUS_OK;
    OpusDecoder *decoder = opus_decoder_create(48000, 2, &error);
    if (decoder != 0) {
        opus_decoder_destroy(decoder);
    }
    return error;
}
