#include "test2.h"
float roughness_to_phong_power(float roughness)
{
	return (2.0f / pow(roughness, 4.0f)) - 2.0f;
}