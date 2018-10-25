float3 rot;
float3 position;
float3 scale;
float3 translate;
//绽放矩阵
float4x4 scaleMat=float4x4(
    scale.x,0,0,0,
    0,scale.y,0,0,
    0,0,scale.z,0,
    0,0,0,1
);
//旋转矩阵
float4x4 rx=float4x4(
    1,0,0,0,
    0,cos(rot.x),-sin(rot.x),0,
    0,sin(rot.x),cos(rot.x),0,
    0,0,0,1
);
float4x4 ry=float4x4(
    cos(rot.y),0,sin(rot.y),0,
    0,1,0,0,
    -sin(rot.y),0,cos(rot.y),0,
    0,0,0,1
);
float4x4 rz=float4x4(
    cos(rot.z),-sin(rot.z),0,0,
    sin(rot.z),cos(rot.z),0,0,
    0,0,1,0,
    0,0,0,1
);
//移动矩阵
float4x4 trans=float4x4(
    1,0,0,translate.x,
    0,1,0,translate.y,
    0,0,1,translate.z,
    0,0,0,1
);
float4x4 mat=mul(trans,mul(rz,mul(ry,mul(rx,scaleMat))));
return mul(mat,float4(position,1.0));