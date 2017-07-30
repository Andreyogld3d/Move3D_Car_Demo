#ifndef MOVE3D_PLATFORM_INC__
#define MOVE3D_PLATFORM_INC__

#define MOVE3D_GAPI_D3D11

#ifdef MOVE3D_GAPI_D3D11

#define TEXTURE_SAMPLER(_textureName) s##_textureName
#define TEXTURE2D(_name, _register) \
	Texture2D _name : register(t##_register); \
	SamplerState TEXTURE_SAMPLER(_name) : register(s##_register);

#endif

#endif //MOVE3D_PLATFORM_INC__