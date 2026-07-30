#include <flecs.h>

int smoke(void) {
    ecs_world_t *world = ecs_init();
    ecs_entity_t entity = ecs_new(world);
    int ok = entity != 0;
    ecs_fini(world);
    return ok;
}
