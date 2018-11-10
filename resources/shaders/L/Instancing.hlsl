#ifndef MOVE3D_INSTANCING_INCLUDE__
#define MOVE3D_INSTANCING_INCLUDE__

#ifdef INSTANCING

    #define VERTEX_INSTANCE_DATA \
	    float4 instanceAxis0 : TRANSFORM0;\
	    float4 instanceAxis1 : TRANSFORM1; \
	    float4 instanceAxis2 : TRANSFORM2;

    #define GET_INSTANCE_MATRIX(_vertex) float4x4( \
	    float4(_vertex.instanceAxis0.x, _vertex.instanceAxis1.x, _vertex.instanceAxis2.x, 0.0f), \
	    float4(_vertex.instanceAxis0.y, _vertex.instanceAxis1.y, _vertex.instanceAxis2.y, 0.0f), \
	    float4(_vertex.instanceAxis0.z, _vertex.instanceAxis1.z, _vertex.instanceAxis2.z, 0.0f), \
	    float4(_vertex.instanceAxis0.w, _vertex.instanceAxis1.w, _vertex.instanceAxis2.w, 1.0f))

#else
    #define VERTEX_INSTANCE_DATA

#endif

#endif //MOVE3D_INSTANCING_INCLUDE__