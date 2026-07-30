#include <Jolt/Jolt.h>
#include <Jolt/Core/Factory.h>

extern "C" int smoke(void) {
    JPH::Factory::sInstance = new JPH::Factory();
    int ok = JPH::Factory::sInstance != nullptr;
    delete JPH::Factory::sInstance;
    JPH::Factory::sInstance = nullptr;
    return ok;
}
