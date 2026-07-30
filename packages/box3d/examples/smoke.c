#include <box3d/box3d.h>

int smoke(void)
{
    b3WorldDef def = b3DefaultWorldDef();
    def.gravity = (b3Vec3){ 0.0f, -10.0f, 0.0f };
    b3WorldId world = b3CreateWorld(&def);
    b3World_Step(world, 1.0f / 60.0f, 4);
    b3DestroyWorld(world);
    return 0;
}

