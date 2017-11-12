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
#include <memory>
#include <array>
#include <iomanip>
#include <fstream>

#ifdef _DEBUG
#pragma comment(lib, "./Move3D/3DMoveEngined.lib")
#pragma comment(lib, "./Move3D/lib/pugixml/lib/msvc2017/debug/pugixml.lib")
#else
#pragma comment(lib, "./Move3D/3DMoveEngine.lib")
#pragma comment(lib, "./Move3D/lib/pugixml/lib/msvc2017/pugixml.lib")
#endif

#pragma comment(lib, "./Move3D/lib/lua/lib/msvc2017/lua.lib")
#pragma comment(lib, "./Move3D/lib/glew/lib/glew32.lib")
#pragma comment(lib, "./Move3D/lib/directx/lib/dxerr.lib")

LRESULT CALLBACK MessageProc(int code, WPARAM wParam, LPARAM lParam);

namespace EditorKeys {
	static constexpr std::array<WPARAM, 3> MoveBack = { VK_LEFT, VK_NUMPAD4, VK_BACK };
	static constexpr std::array<WPARAM, 3> MoveForward = { VK_RIGHT, VK_NUMPAD6, VK_RETURN };
	static constexpr std::array<WPARAM, 2> SelectPrevious = { VK_UP, VK_NUMPAD8 };
	static constexpr std::array<WPARAM, 2> SelectNext = { VK_DOWN, VK_NUMPAD2 };

	static constexpr std::array<WPARAM, 1> ExportValues = { VK_END };
	static constexpr std::array<WPARAM, 1> ImportValues = { VK_HOME };

	//static constexpr std::array<WPARAM, 2> Increment = { 0xbb, 0x6b };
	//static constexpr std::array<WPARAM, 2> Decrement = { 0xbd, 0x6d };

	static constexpr std::array<WPARAM, 2> Increment = SelectPrevious;
	static constexpr std::array<WPARAM, 2> Decrement = SelectNext;

	template<typename T>
	static constexpr bool FindKey(T keys, WPARAM key) {
		for (auto k : keys){
			if (key == k) {
				return true;
			}
		}
		return false;
	}
}

struct Editor : public std::enable_shared_from_this<Editor>{
	std::string name;
	std::shared_ptr<Editor> parent = nullptr;

	virtual ~Editor() = default;
	virtual void update(float direction) {}
	virtual void onKeyPress(WPARAM key) {}
	virtual void onKeyRelease(WPARAM key) {}
	virtual std::shared_ptr<Editor> getNext() {
		return nullptr;
	}
	
	std::string getFullPath() {
		auto editor = shared_from_this();
		std::string result = "";

		while (editor != nullptr) {
			result = editor->name + ">" + result;
			editor = editor->parent;
		}
		return result;
	}

	virtual void onEnter() {
		HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
		WORD wOldColorAttrs;
		CONSOLE_SCREEN_BUFFER_INFO csbiInfo;
		GetConsoleScreenBufferInfo(hConsole, &csbiInfo);
		wOldColorAttrs = csbiInfo.wAttributes;
		system("cls");
		SetConsoleTextAttribute(hConsole, 9);
		std::cout << std::endl << "> " <<getFullPath() << std::endl;
		SetConsoleTextAttribute(hConsole, wOldColorAttrs);
	}

	virtual std::shared_ptr<Editor> findEditor(const std::string& path) {
		auto offset = path.find_first_of('>', 0);
		auto n = path.substr(0, offset);
		if (n == name) {
			return shared_from_this();
		}else {
			return nullptr;
		}
	}

	virtual void serialize(std::ostream& stm) {}
	virtual void deserialize(std::istream& stm) {}
};

struct IEditorValueChanged {
	virtual ~IEditorValueChanged() = default;
	virtual void onValueChanged(std::shared_ptr<Editor> editor) = 0;
};

struct FloatEditor : public Editor {
	float min = 0.0f;
	float max = 1.0f;
	float changeSpeed = 0.5f;

	float direction = 0.0f;
	IEditorValueChanged* callback = nullptr;

	FloatEditor(float* value) :_value(value){}

	void printState(std::ostream& stm) {
		stm << *_value << std::endl;
	}

	void onEnter() override {
		Editor::onEnter();
		printState(std::cout);
	}

	void onKeyPress(WPARAM key) override {
		if (EditorKeys::FindKey(EditorKeys::Decrement, key)) { //key -
			direction = -1.0f;
		}
		else if (EditorKeys::FindKey(EditorKeys::Increment, key)) { //key +
			direction = 1.0f;
		}
	}
	void onKeyRelease(WPARAM key) override {
		if (EditorKeys::FindKey(EditorKeys::Decrement, key)) { //key -
			direction = 0;
		}
		else if (EditorKeys::FindKey(EditorKeys::Increment, key)) { //key +
			direction = 0;
		}
	}

	void setValue(float newValue) {
		float& value = *_value;
		value = newValue;
		value = (std::max)(min, (std::min)(max, value));
		if (callback != nullptr) {
			callback->onValueChanged(shared_from_this());
		}
		onEnter();
	}

	void update(float dt) override {
		if (direction != 0) {
			setValue(*_value + direction * dt * changeSpeed);
		}
	}

	void serialize(std::ostream& stm) override {
		stm << getFullPath() << std::endl;
		printState(stm);
	}

	void deserialize(std::istream& stm) override {
		std::string valueString;
		std::getline(stm, valueString);
		setValue(std::stof(valueString));
	}

private:
	float* _value;
};

struct EditorGroup : public Editor {
	
	void addItem(std::shared_ptr<Editor> item) {
		items.push_back(item);
		item->parent = shared_from_this();
	}
	
	std::vector<std::shared_ptr<Editor>> getItems() {
		return items;
	}

	void onEnter() override {
		Editor::onEnter();

		std::cout << "    Child editors [" << items.size() << "]:" << std::endl;
		for (size_t i = 0; i < items.size(); ++i) {
			if (i == _selectedID) {
				std::cout << "--> ";
			}else {
				std::cout << "    ";
			}
			std::cout << i << ": " << items[i]->name << std::endl;
		}
	}

	void onKeyPress(WPARAM key) override {
		if (EditorKeys::FindKey(EditorKeys::SelectNext, key)) {
			_selectedID = (_selectedID + 1) % items.size();
		}
		else if (EditorKeys::FindKey(EditorKeys::SelectPrevious, key)) {
			_selectedID = (_selectedID == 0) ? (items.size() - 1) : _selectedID - 1;
		}
		onEnter();
	}

	std::shared_ptr<Editor> getNext() override {
		if (_selectedID >= items.size()) {
			return items[0];
		}
		return items[_selectedID];
	}
	void serialize(std::ostream& stm) override {
		for (auto i : items) {
			i->serialize(stm);
		}
	}
	std::shared_ptr<Editor> findEditor(const std::string& path) override {
		auto offset0 = path.find_first_of('>', 0);
		auto n = path.substr(0, offset0);
		if (n == name) {
			offset0++;
			auto offset1 = path.find_first_of('>', offset0);
			if (offset1 != std::string::npos) {
				auto n2 = path.substr(offset0, offset1 - offset0);
				for (size_t i = 0; i < items.size(); ++i) {
					if (items[i]->name == n2) {
						return items[i]->findEditor(path.substr(offset0));
					}
				}
			}else {
				return shared_from_this();
			}
		}
		return nullptr;
	}
private:
	size_t _selectedID = 0;
	std::vector<std::shared_ptr<Editor>> items;
};

struct ShaderParameterEditor : public EditorGroup, public IEditorValueChanged {
	std::vector<float> value;

	void onValueChanged(std::shared_ptr<Editor> editor) override {
		apply();
	}

	static std::shared_ptr<ShaderParameterEditor> create(IDisplayedObject* object, const char* name, size_t size){
		auto result = std::shared_ptr<ShaderParameterEditor>(new ShaderParameterEditor(object, name, size));
		result->value.resize(size);

		const char* names[] = { "X", "Y", "Z", "W" };

		for (size_t i = 0; i < size; ++i) {
			auto f = std::make_shared<FloatEditor>(&result->value[i]);
			f->name = names[i];
			f->parent = result;
			f->callback = result.get();
			result->addItem(f);
		}

		return result;
	}
private:
	IDisplayedObject* _object;
	void apply() {
		_object->GetObjectMaterial()->SetShaderConstantValue(name, &value[0], value.size());
	}
	ShaderParameterEditor(IDisplayedObject* object, const char* name, size_t size) :_object(object) {
		this->name = name;
	}
};

struct PositionEditor : public Editor {
	PositionEditor(IDisplayedObject* object) {

	}

	void update(float direction) override {

	}
};

struct EditableObject : public EditorGroup {

	IDisplayedObject* _object = nullptr;
	static std::shared_ptr<EditableObject> create(IDisplayedObject* object) {
		auto result = std::shared_ptr<EditableObject>(new EditableObject(object));
		result->name = object->GetObjectName();

		auto color1 = ShaderParameterEditor::create(object, "layer1Color", 4); 
		result->addItem(color1);

		auto fresnel = ShaderParameterEditor::create(object, "materialParams0", 4);
		result->addItem(fresnel);

		auto params = fresnel->getItems();

		auto roughness0 = std::static_pointer_cast<FloatEditor>(params[0]);
		roughness0->name = "roughness0";
		roughness0->min = 0;
		roughness0->max = 1;
		roughness0->setValue(0.2f);

		auto roughness1 = std::static_pointer_cast<FloatEditor>(params[1]);
		roughness1->name = "roughness1";
		roughness1->min = 0;
		roughness1->max = 1;
		roughness1->setValue(0.5f);

		auto metallic = std::static_pointer_cast<FloatEditor>(params[2]);
		metallic->name = "metallic";
		metallic->min = 0;
		metallic->max = 1;
		metallic->setValue(0.5f);

		auto fresnelIOR = std::static_pointer_cast<FloatEditor>(params[3]);
		fresnelIOR->name = "fresnelIOR";
		fresnelIOR->min = 0;
		fresnelIOR->max = 4;
		fresnelIOR->setValue(1.0f);



		auto params1 = ShaderParameterEditor::create(object, "materialParams1", 4);
		result->addItem(params1);

		auto params1Elements = params1->getItems();

		auto ks = std::static_pointer_cast<FloatEditor>(params1Elements[0]);
		ks->name = "kS";
		ks->min = 0;
		ks->max = 1;
		ks->setValue(0.5f);


		return result;
	}
private:
	EditableObject(IDisplayedObject* object) :_object(object) {	}
};

struct EngineCallback : public IUserCallback {
	void Update(float dt) override {
		_time += dt;

		Sleep(1);//Slow down rendering -> no working vsync support in engine found :(

		if (_activeEditor != nullptr) {
			_activeEditor->update(dt);
		}
	}

	void Setup(IScene* scene) override {
		FILE* newStdout;
		freopen_s(&newStdout, "CONOUT$", "w", stdout);

		_scene = scene;
		_rootEditor = std::make_shared<EditorGroup>();
		_rootEditor->name = "SceneObjects";

		std::vector<IDisplayedObject*> objects;
		scene->GetObjects(objects);

		for (auto obj : objects) {
			std::string name = obj->GetObjectName();
			if (name.find("Car_", 0) != std::string::npos) {
				_rootEditor->addItem(EditableObject::create(obj));
			}
		}

		_activeEditor = _rootEditor;
		_activeEditor->onEnter();

		loadState();

		_inputHook = SetWindowsHookEx(WH_GETMESSAGE, MessageProc, GetModuleHandle(nullptr), GetCurrentThreadId());
	}

	const char* stateFileName = "settings_dump.txt";
	void saveState() {
		std::ofstream dump(stateFileName, std::ios::trunc);
		if (!dump.good()) {
			std::cout << "# Failed to save state" << std::endl;
			return;
		}
		_rootEditor->serialize(dump);
		dump.close();
		std::cout << "# State saved" << std::endl;
	}

	void loadState() {
		std::ifstream dump(stateFileName);
		if (!dump.good()) {
			std::cout << "# Failed to load state" << std::endl;
			return;
		}

		std::string path;
		while (std::getline(dump, path)) {
			auto editor = _rootEditor->findEditor(path);
			if (editor != nullptr) {
				editor->deserialize(dump);
			}
		}
		dump.close();
		_activeEditor = _rootEditor;
		_activeEditor->onEnter();
		std::cout << "# State loaded" << std::endl;
	}

	void onKeyPressed(WPARAM key) {
		if (EditorKeys::FindKey(EditorKeys::MoveBack, key)) {
			if (_activeEditor->parent != nullptr) {
				_activeEditor = _activeEditor->parent;
				_activeEditor->onEnter();
			}
		}else if (EditorKeys::FindKey(EditorKeys::MoveForward, key)) {
			auto next = _activeEditor->getNext();
			if (next != nullptr) {
				_activeEditor = next;
				_activeEditor->onEnter();
			}
		}else if (EditorKeys::FindKey(EditorKeys::ExportValues, key)) {
			saveState();
		}
		else if (EditorKeys::FindKey(EditorKeys::ImportValues, key)) {
			loadState();
		}
		else {
			_activeEditor->onKeyPress(key);
		}
	}

	void onKeyReleased(WPARAM key) {
		_activeEditor->onKeyRelease(key);
	}

private:
	float _time = 0;
	IScene* _scene = nullptr;
	HHOOK _inputHook = nullptr;
	std::shared_ptr<Editor> _activeEditor = nullptr;
	std::shared_ptr<EditorGroup> _rootEditor;
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