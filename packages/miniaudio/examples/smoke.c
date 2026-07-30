#include <miniaudio.h>

int smoke(void) {
    ma_decoder_config config = ma_decoder_config_init(ma_format_f32, 2, 48000);
    return config.channels == 2 && config.sampleRate == 48000;
}
