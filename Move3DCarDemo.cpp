#include <Windows.h>
#include <cmath>

#include "Move3D/IUserCallback.h"
#include "Move3D/IEngine.h"
#include "Move3D/IScene.h"
#include "Move3D/IDisplayedObject.h"
#include "Move3D/IMaterial.h"

#ifdef _DEBUG
#pragma comment(lib, "./Move3D/3DMoveEngined.lib")
#pragma comment(lib, "./Move3D/lib/pugixml/lib/msvc2015/debug/pugixml.lib")
#else
#pragma comment(lib, "./Move3D/3DMoveEngine.lib")
#pragma comment(lib, "./Move3D/lib/pugixml/lib/msvc2015/pugixml.lib")
#endif

#pragma comment(lib, "./Move3D/lib/lua/lib/msvc2015/lua.lib")
#pragma comment(lib, "./Move3D/lib/glew/lib/glew32.lib")
#pragma comment(lib, "./Move3D/lib/directx/lib/dxerr.lib")

struct EngineCallback : public IUserCallback {
	void Update(float dt) override {
		_time += dt;
	}
	void Setup(IScene* scene) override {
		_scene = scene;
	}
private:
	float _time = 0;
	IScene* _scene = nullptr;
};

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
	IEngine* engine = IEngine::GetEngine();
	EngineCallback callback;
	engine->Run(0, 0, 0, true, &callback);
}