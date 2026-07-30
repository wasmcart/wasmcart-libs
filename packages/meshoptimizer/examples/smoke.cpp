#include <meshoptimizer.h>

extern "C" int smoke(void) {
    unsigned int indices[3] = {0, 1, 2};
    meshopt_optimizeVertexCache(indices, indices, 3, 3);
    return indices[0] < 3 && indices[1] < 3 && indices[2] < 3;
}
