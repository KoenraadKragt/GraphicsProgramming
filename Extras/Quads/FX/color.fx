
cbuffer cbPerObject
{
	float4x4 gWorldViewProj; 
	float gGlobalTime;
	float2 gResolution;
	float padding;
};

struct VertexIn
{
	float3 Pos  : POSITION;
};

struct VertexOut
{
	float4 Pos  : SV_POSITION;
};

VertexOut VS(VertexIn vin)
{
	VertexOut vout;
	
	// Transform to homogeneous clip space.
	vout.Pos = mul(float4(vin.Pos, 1.0f), gWorldViewProj);

	return vout;
}


//***************************************************************************************
// Circle from ShaderToy
//***************************************************************************************


float4 PSCircle(VertexOut pin) : SV_Target
{
	float circleX = gResolution.x / 2.0;
	float circleY = gResolution.y / 2.0;

	float deltaX = pin.Pos.x - circleX;
	float deltaY = pin.Pos.y - circleY;
	float dist = sqrt(deltaX*deltaX + deltaY*deltaY);


	float light = 0.5*cos(dist*0.5 - gGlobalTime*80.0) + 0.5;

	float4 color = float4(light, light, light, 1.0);

	return color;
}

//***************************************************************************************
// Flame from ShaderToy
//***************************************************************************************


float noise(float3 p) //Thx to Las^Mercury
{
	float3 i = floor(p);
	float4 a = dot(i, float3(1., 57., 21.)) + float4(0., 57., 21., 78.);
	float3 f = cos((p - i)*acos(-1.))*(-.5) + .5;
	a = lerp(sin(cos(a)*a), sin(cos(1. + a)*(1. + a)), f.x);
	a.xy = lerp(a.xz, a.yw, f.y);
	return lerp(a.x, a.y, f.z);
}

float sphere(float3 p, float4 spr)
{
	return length(spr.xyz - p) - spr.w;
}

float flame(float3 p)
{
	float d = sphere(p*float3(1., .5, 1.), float4(.0, -1., .0, 1.));
	return d + (noise(p + float3(.0, gGlobalTime*2., .0)) + noise(p*3.)*.5)*.25*(p.y);
}

float scene(float3 p)
{
	return min(100. - length(p), abs(flame(p)));
}

float4 raymarch(float3 org, float3 dir)
{
	float d = 0.0, glow = 0.0, eps = 0.02;
	float3  p = org;
	bool glowed = false;

	for (int i = 0; i<64; i++)
	{
		d = scene(p) + eps;
		p += d * dir;
		if (d>eps)
		{
			if (flame(p) < .0)
				glowed = true;
			if (glowed)
				glow = float(i) / 64.;
		}
	}
	return float4(p, glow);
}


float4 PSFlame(VertexOut pin) : SV_Target
{
	float4 color = float4(0,0,0,0);

	float2 v = 1.0 - 2.0 * pin.Pos.xy / gResolution.xy;
	v.x *= gResolution.x / gResolution.y;

	float3 org = float3(0.0f, -2.0f, 4.0f);
	float3 dir = normalize(float3(v.x*1.6, -v.y, -1.5));

	float4 p = raymarch(org, dir);
	float glow = p.w;

	float4 col = lerp(float4(1., .5, .1, 1.), float4(0.1, .5, 1., 1.), p.y*.02 + .4);

	color = lerp(float4(0,0,0,0), col, pow(glow*2., 4.));
	//fragColor = mix(vec4(1.), mix(vec4(1.,.5,.1,1.),vec4(0.1,.5,1.,1.),p.y*.02+.4), pow(glow*2.,4.));
	return color;
}


technique11 ColorTech
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_5_0, PSFlame() ) );
    }
}
