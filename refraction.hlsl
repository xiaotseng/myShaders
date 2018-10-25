float3 normalW, cameraW;//法向量和入射向量
float internalIoR;//材质内部IOR
float airIoR = 1.00029;//空气IOR

float n = airIoR / internalIoR;//两种介质IOR之比

float3 tangent = cameraW-dot(normalW, cameraW)*normalW;//入射切向量
tangent*=n;//出射切向量
float3 normalVector=sqrt(1-pow(length(tangent),2))*normalW;//出射法向量
return normalVector-tangent;//向量组合

// Scale UVs from from unit circle in or out from center
// float2 UV, float PupilScale

float2 UVcentered = UV - float2(0.5f, 0.5f);
float UVlength = length(UVcentered);
// UV on circle at distance 0.5 from the center, in direction of original UV
float2 UVmax = normalize(UVcentered)*0.5f;

float2 UVscaled = lerp(UVmax, float2(0.f, 0.f), saturate((1.f - UVlength*2.f)*PupilScale));
return UVscaled + float2(0.5f, 0.5f);





//////////////////////////////////////
float numFrames = XYFrames * XYFrames;
float accumdist = 0;
float curdensity = 0;
float transmittance = 1;
float3 localcamvec = normalize( mul(Parameters.CameraVector, Primitive.WorldToLocal) ) * StepSize;//像素到相机的步进

float3 invlightdir = 1 / LightVector;

float shadowstepsize = 1 / ShadowSteps;//阴影步进
LightVector *= shadowstepsize*0.5;
ShadowDensity *= shadowstepsize;

Density *= StepSize;
float3 lightenergy = 0;
float shadowthresh = -log(ShadowThreshold) / ShadowDensity;

int3 randpos = int3(Parameters.SvPosition.xy, View.StateFrameIndexMod8);
float rand =float(Rand3DPCG16(randpos).x) / 0xffff;
CurPos +=  localcamvec * rand.x * Jitter;


for (int i = 0; i < MaxSteps; i++)
{	

	
	float cursample = PseudoVolumeTexture(Tex, TexSampler, CurPos, XYFrames, numFrames).r;
	
	//Sample Light Absorption and Scattering
	if( (cursample.r) > 0.001)
	{
		float3 lpos = CurPos;
		float shadowdist = 0;

		for (int s = 0; s < ShadowSteps; s++)
		{
			lpos += LightVector;

		

			float lsample = PseudoVolumeTexture(Tex, TexSampler, saturate(lpos), XYFrames, numFrames).r;
			
			float3 shadowboxtest = floor( 0.5 + ( abs( 0.5 - lpos ) ) );
			float exitshadowbox = shadowboxtest .x + shadowboxtest .y + shadowboxtest .z;

       			if(shadowdist > shadowthresh || exitshadowbox >= 1) break;

			shadowdist += lsample;
		}
	
		curdensity = 1 - exp(-cursample.r * Density);


		//curdensity = saturate(cursample * Density);
		//float     shadowterm = exp(-shadowdist * ShadowDensity);
		//float3 absorbedlight = exp(-shadowdist * ShadowDensity) * curdensity;

		lightenergy += exp(-shadowdist * ShadowDensity) * curdensity * transmittance * LightColor;

		transmittance *= 1- (curdensity);
		
		#if 1

		//Sky Lighting
		shadowdist = 0;
		
		lpos = CurPos + float3(0,0,0.025);
		float lsample = PseudoVolumeTexture(Tex, TexSampler, saturate(lpos), XYFrames, numFrames).r;
		shadowdist += lsample;
		lpos = CurPos + float3(0,0,0.05);
		lsample = PseudoVolumeTexture(Tex, TexSampler, saturate(lpos), XYFrames, numFrames).r;
		shadowdist += lsample;
		lpos = CurPos + float3(0,0,0.15);
		lsample = PseudoVolumeTexture(Tex, TexSampler, saturate(lpos), XYFrames, numFrames).r;
		shadowdist += lsample;

		lightenergy    += exp(-shadowdist  * AmbientDensity) * curdensity * SkyColor * transmittance;
		#endif

	}
		

	CurPos -= localcamvec;
}



return float4( lightenergy, transmittance);
