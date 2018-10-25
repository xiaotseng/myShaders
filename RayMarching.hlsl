float numFrames = XYFrames * XYFrames;
float accumdist = 0;

float3 localcamvec = normalize( mul(Parameters.CameraVector, Primitive.WorldToLocal) );//相机方向转换到局部坐标

float StepSize = 1 / MaxSteps;

for (int i = 0; i < MaxSteps; i++)
{
    float cursample = PseudoVolumeTexture(Tex, TexSampler, saturate(CurPos), XYFrames, numFrames).r;//采样
    accumdist += cursample * StepSize;//积分
    CurPos += -localcamvec * StepSize;//位置推进
}

return accumdist;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////Plane Alignment平面对齐
// get object scale factor得到物体绽放比例
//NOTE: This assumes the volume will only be UNIFORMLY scaled. Non uniform scale would require tons of little changes.
float scale = length( TransformLocalVectorToWorld(Parameters, float3(1.00000000,0.00000000,0.00000000)).xyz);//x轴的缩放
float worldstepsize = scale * Primitive.LocalObjectBoundsMax.x*2 / MaxSteps;//平分最大尺寸

float camdist = length( ResolvedView.WorldCameraOrigin - GetObjectWorldPosition(Parameters) );//物体到相机的距离
float planeoffset = GetScreenPosition(Parameters).w / worldstepsize;
float actoroffset = camdist / worldstepsize;
planeoffset = frac( planeoffset - actoroffset);

float3 localcamvec = normalize( mul(Parameters.CameraVector, Primitive.WorldToLocal) );

float3 offsetvec = localcamvec * StepSize * planeoffset;



return float4(offsetvec, planeoffset * worldstepsize);

