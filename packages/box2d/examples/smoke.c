#include <box2d/box2d.h>

int smoke(void)
{
    b2WorldDef def = b2DefaultWorldDef();
    def.gravity = (b2Vec2){ 0.0f, -10.0f };
    b2WorldId world = b2CreateWorld(&def);
    b2World_Step(world, 1.0f / 60.0f, 4);
    b2DestroyWorld(world);
    return 0;
}

