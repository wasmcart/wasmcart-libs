#include <imgui.h>

extern "C" int smoke(void) {
    ImGuiContext *context = ImGui::CreateContext();
    if (!context) {
        return 0;
    }
    ImGui::DestroyContext(context);
    return 1;
}
