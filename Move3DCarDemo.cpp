#include <Windows.h>
#include <cmath>

#include "Move3D/IUserCallback.h"
#include "Move3D/IEngine.h"
#include "Move3D/IScene.h"
#include "Move3D/IDisplayedObject.h"
#include "Move3D/IMaterial.h"

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <array>

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

LRESULT CALLBACK MessageProc(int code, WPARAM wParam, LPARAM lParam);

struct ShaderParameterEditor {
	const char* name;
	float value;
	float min;
	float max;
	float changeSpeed;
	bool editing;
	WPARAM editKey;
	IMaterial* material;

	void update(float direction) {
		value += direction * changeSpeed;
		value = (std::max)(min, value);
		value = (std::min)(max, value);
		material->SetShaderConstantValue(name, &value, 1);
	}
};

struct EngineCallback : public IUserCallback {
	void Update(float dt) override {
		_time += dt;

		Sleep(1);

		//update editors
		if (_changeDirection != 0.0f) {
			for (auto& editor : _editors) {
				if (editor.editing) {
					editor.update(dt * _changeDirection);
				}
			}
		}		
	}

	void Setup(IScene* scene) override {
		_scene = scene;
		_inputHook = SetWindowsHookEx(WH_GETMESSAGE, MessageProc, GetModuleHandle(nullptr), GetCurrentThreadId());

		//create shader parameters editors
		auto car = _scene->GetObjectByName("Car_body");
		if (car != nullptr) {
			auto material = car->GetObjectMaterial();

			_editors.push_back({ "roughness0", 0.5f, 0.0f, 1.0f, 1.0f, false, 0x31, material });
			_editors.push_back({ "roughness1", 0.5f, 0.0f, 1.0f, 1.0f, false, 0x32, material });

			//apply default values
			for (auto& editor : _editors) {
				editor.update(0.0f);
			}
		}
	}

	void onKeyPressed(WPARAM key) {
		if (key == 0xbd || key == 0x6d) { //key -
			_changeDirection = -1.0f;
		}else if(key == 0xbb || key == 0x6b) { //key +
			_changeDirection = 1.0f;
		}else {
			for (auto& editor : _editors) {
				if (editor.editKey == key) {
					editor.editing = true;
				}
			}
		}
	}

	void onKeyReleased(WPARAM key) {
		if (key == 0xbd || key == 0x6d || key == 0xbb || key == 0x6b) {
			_changeDirection = 0.0f;
		} else {
			for (auto& editor : _editors) {
				if (editor.editKey == key) {
					editor.editing = false;
				}
			}
		}
	}

private:
	float _time = 0;
	float _changeDirection = 0.0f;
	IScene* _scene = nullptr;
	HHOOK _inputHook = nullptr;
	std::vector<ShaderParameterEditor> _editors;
};

EngineCallback callback;

//Message proc hook -> because no engine input interfaces available at the moment
LRESULT CALLBACK MessageProc(int code, WPARAM wParam, LPARAM lParam) {
	if (code == HC_ACTION) {
		auto message = (MSG*)lParam;
		if (message->message == WM_KEYDOWN) {
			callback.onKeyPressed(message->wParam);
		}
		else if (message->message == WM_KEYUP) {
			callback.onKeyReleased(message->wParam);
		}
	}
	return CallNextHookEx(0, code, wParam, lParam);
}

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
	IEngine* engine = IEngine::GetEngine();
	engine->Run(0, 0, 0, true, &callback);
}