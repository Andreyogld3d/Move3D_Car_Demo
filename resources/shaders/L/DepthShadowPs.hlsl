//
struct PS  {
   float4 Pos: POSITION;
   float2 Depth: TEXCOORD0;
};

//
float4 psMain(in PS In) : COLOR
{
	return float4(In.Depth.x, In.Depth.x, In.Depth.x, In.Depth.x);
}
