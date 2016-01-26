cbuffer cbPerObject {
	float4x4 gWorldViewProj;
}; 

struct VertexIn {
	float3 PosL     : POSITION;
	float3 NormalL  : NORMAL;
};

struct VertexOut {
	float4 PosH : SV_POSITION;
};
 
VertexOut VS(VertexIn vin) {
	VertexOut vout;
	vout.PosH = mul(float4(vin.PosL, 1.0f), gWorldViewProj);

	return vout;
}

RasterizerState Depth {
	DepthBias = 10000;
	DepthBiasClamp = 0.0f;
	SlopeScaledDepthBias = 1.0f;
};

void PS(VertexOut pin) { }

technique11 BuildShadowMapTech {
    pass P0 {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_5_0, PS() ) );

		SetRasterizerState(Depth);
    }
}