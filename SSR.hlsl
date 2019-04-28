Texture2D<float4> DiffuseTex:register(t0);
Texture2D<float4> FrontDepthTex:register(t1);
Texture2D<float4> BackDepthTex:register(t2);
Texture2D<float4> ViewPosTex:register(t3);
Texture2D<float4> ViewNormalTex:register(t4);
SamplerState SampleWrapLinear:register(s0);
SamplerState SampleClampPoint:register(s1);
 
#define MAX_STEPS 500
 
cbuffer CBMatrix:register(b0)
{
	matrix World;
	matrix View;
	matrix Proj;
	matrix WorldInvTranspose;
	float3 cameraPos;
	float pad1;
	float4 dirLightColor;
	float3 dirLightDir;
	float pad2;
	float3 ambientLight;
	float pad3;
};
 
 
cbuffer CBSSR:register(b1)
{
	float farPlane;
	float nearPlane;
	float2 perspectiveValues;
};
 
struct VertexIn
{
	float3 Pos:POSITION;
	float2 Tex:TEXCOORD;
};
 
struct VertexOut
{
	float4 Pos:SV_POSITION;
	float2 Tex:TEXCOORD0;
};
 
float DepthBufferConvertToViewDepth(float depth)
{
	float viewDepth = perspectiveValues.x / (depth + perspectiveValues.y);
	return viewDepth;
};
 
 
float2 texSize(Texture2D tex)//取得屏幕大小
{
	uint texWidth, texHeight;
	tex.GetDimensions(texWidth, texHeight);
	return float2(texWidth, texHeight);
}
 
//NDC转换为屏幕空间UV坐标
float2 NormalizedDeviceCoordToScreenCoord(float2 ndc, float2 screenSize)
{
	float2 screenCoord;
	screenCoord.x = screenSize.x * (0.5 * ndc.x + 0.5);
	screenCoord.y = screenSize.y * (-0.5 * ndc.y + 0.5);
	return screenCoord;
}
 
float distanceSquared(float2 a, float2 b)//二维距离
{
	a -= b;
	return dot(a, a);
}
 
VertexOut VS(VertexIn ina)//顶点着色器
{
	VertexOut outa;
 
	outa.Pos = float4(ina.Pos.xy,1.0f,1.0f);
	outa.Tex = ina.Tex;
	return outa;
}
 
 
float4 PS(VertexOut outa) : SV_Target
{
	//初始化反射的颜色
	float4 reflectColor = float4(0.0, 0.0, 0.0, 0.0f);
	float2 screenSize = texSize(DiffuseTex);
	float2 texcoord = outa.Tex;
	float3 viewPos = ViewPosTex.Sample(SampleClampPoint, outa.Tex).xyz;//像机空间位置
	float3 viewNormal= ViewNormalTex.Sample(SampleClampPoint, outa.Tex).xyz;//像机空间法线
	float t = 1;//追踪计步
	int2 origin = texcoord * screenSize;//起点像素坐标，以此做基准做偏移采样获取场景颜色
	int2 coord;
 
 
	//像素在相机空间的位置(光线起点)和法线
	float3 v0 = viewPos;
	float3 vsNormal = viewNormal;
 
	//相机到像素的方向
	float3 eyeToPixel = normalize(v0);
 
	//光线反射的方向
	float3 reflRay = normalize(reflect(eyeToPixel, vsNormal));
 
 
	//反射光线终点
	float3 v1 = v0 + reflRay * farPlane;
 
 
	//屏幕空间的坐标
	float4 p0 = mul(float4(v0, 1.0), Proj);
	float4 p1 = mul(float4(v1, 1.0), Proj);
	
 
	//这里参考软光栅器 纹理坐标 世界空间坐标的插值原理(透视纠正)
	//w为相机空间的Z值
	float k0 = 1.0 / p0.w;//透视除法
	float k1 = 1.0 / p1.w;
    
    //透视除法
	p0 *= k0;//NDC空间起点
	p1 *= k1;//NDC空间终点

    //缩放两个坐标,方向不变，使z值在0-1区间
	v0 *= k0;
	v1 *= k1;
 
	//换算到uv空间
	p0.xy = NormalizedDeviceCoordToScreenCoord(p0.xy, screenSize.xy);//uv起点
	p1.xy = NormalizedDeviceCoordToScreenCoord(p1.xy, screenSize.xy);//uv终点
 
 
	//保证屏幕空间的光线起始点终点至少一个单位长度
	float ds = distanceSquared(p1.xy, p0.xy);
	p1 += ds < 0.0001 ? 0.01 : 0.0;
	float divisions = length(p1.xy - p0.xy);//起点到终点的有多少个像素以确定步数
	
	float3 dV = (v1 - v0) / divisions;//追踪步进
	float dK = (k1 - k0) / divisions;//缩放步进
	float2 traceDir = (p1 - p0) / divisions;//UV步进
 
	float maxSteps = min(divisions, MAX_STEPS);//控制最大步数
 
	while (t < maxSteps)
	{
		coord = origin + traceDir * t;
		if (coord.x > screenSize.x || coord.y > screenSize.y || coord.x < 0 || coord.y < 0)
		{
			break;//屏幕以外不计算
		}
 
		float curDepth = (v0 + dV * t).z;//插值深度
		float k = k0 + dK * t;//插值缩放系数
		curDepth /= k;//计算为视图深度
		texcoord = float2(coord) / screenSize;//采样坐标
		float storeFrontDepth = FrontDepthTex.SampleLevel(SampleClampPoint, texcoord, 0).r;//采样
		storeFrontDepth = DepthBufferConvertToViewDepth(storeFrontDepth);
		float storeBackDepth = BackDepthTex.SampleLevel(SampleClampPoint, texcoord, 0).r;
		storeBackDepth = DepthBufferConvertToViewDepth(storeBackDepth);
		if ((curDepth >= storeFrontDepth) && ((curDepth - storeFrontDepth) <= 0.1))
		{
			reflectColor = DiffuseTex.SampleLevel(SampleClampPoint, texcoord, 0);	
			reflectColor.a = 0.4;
			break;	
		}
		t++;
	}
 
	return reflectColor;
}
switch(i){
	case 0:return v1;
}