#include <ogg/ogg.h>

int smoke(void) {
    ogg_sync_state state;
    int result = ogg_sync_init(&state);
    ogg_sync_clear(&state);
    return result == 0;
}
