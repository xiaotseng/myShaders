float3 worldPositon;
float3 cameraPosition;
float3 cameraForward;
float3 cameraRight;
float orthoWidth;
float orthoHeight;

sampler2D DepthTexture;
float3 worldNormal;
float3 worldTangent;
/////////////////////////////////////////////////////////////////////////////////////
float dis=length(ddx(worldPositon.xyz))+length(ddy(worldPositon.xyz));//步进距
float3 worldBinormal=normalize(cross(worldNormal.xyz,worldTangent.xyz));
float3 cameraUP=cross(cameraForward.xyz,cameraRight.xyz);
//世界空间计算到正交相机
float3 position=worldPositon.xyz-cameraPosition.xyz;
float3 pos=float3(dot(position.xyz,cameraRight.xyz),dot(position.xyz,-cameraUP.xyz),dot(position.xyz,cameraForward.xyz));
pos.x=pos.x/orthoWidth+0.5;
pos.y=pos.y/orthoHeight+0.5;
if(floor(pos.x)!=0||floor(pos.y)!=0)){return 1.0;}//超出部分

float ret=smoothstep(-2,2,Texture2DSample(DepthTexture,DepthTextureSampler,pos.xy).r-pos.b);//返回值
int n=2;
int i=0;
float tempDis=dis;
for(i=0;i<n;i++)
{
    tempDis=float(n+1)*dis;

    position=worldPositon.xyz+worldTangent.xyz*tempDis-cameraPosition.xyz;
    pos=float3(dot(position.xyz,cameraRight.xyz),dot(position.xyz,-cameraUP.xyz),dot(position.xyz,cameraForward.xyz));
    pos.x=pos.x/orthoWidth+0.5;
    pos.y=pos.y/orthoHeight+0.5;
    ret+=smoothstep(-2,2,Texture2DSample(DepthTexture,DepthTextureSampler,pos.xy).r-pos.b);

    position=worldPositon.xyz-worldTangent.xyz*tempDis-cameraPosition.xyz;
    pos=float3(dot(position.xyz,cameraRight.xyz),dot(position.xyz,-cameraUP.xyz),dot(position.xyz,cameraForward.xyz));
    pos.x=pos.x/orthoWidth+0.5;
    pos.y=pos.y/orthoHeight+0.5;
    ret+=smoothstep(-2,2,Texture2DSample(DepthTexture,DepthTextureSampler,pos.xy).r-pos.b);

    position=worldPositon.xyz+worldBinormal.xyz*tempDis-cameraPosition.xyz;
    pos=float3(dot(position.xyz,cameraRight.xyz),dot(position.xyz,-cameraUP.xyz),dot(position.xyz,cameraForward.xyz));
    pos.x=pos.x/orthoWidth+0.5;
    pos.y=pos.y/orthoHeight+0.5;
    ret+=smoothstep(-2,2,Texture2DSample(DepthTexture,DepthTextureSampler,pos.xy).r-pos.b);

    position=worldPositon.xyz-worldBinormal.xyz*tempDis-cameraPosition.xyz;
    pos=float3(dot(position.xyz,cameraRight.xyz),dot(position.xyz,-cameraUP.xyz),dot(position.xyz,cameraForward.xyz));
    pos.x=pos.x/orthoWidth+0.5;
    pos.y=pos.y/orthoHeight+0.5;
    ret+=smoothstep(-2,2,Texture2DSample(DepthTexture,DepthTextureSampler,pos.xy).r-pos.b);
}
return ret/(n*4+1);


max(1-pow(value*(len/0.5)-1,2),0)