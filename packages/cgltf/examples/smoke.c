#include <cgltf.h>

int smoke(void) {
    cgltf_options options = {0};
    cgltf_data *data = 0;
    const char json[] = "{\"asset\":{\"version\":\"2.0\"}}";
    cgltf_result result = cgltf_parse(&options, json, sizeof(json) - 1, &data);
    cgltf_free(data);
    return result == cgltf_result_success;
}
