float2 convert_xyz_to_cube_uv(float x, float y, float z)
{
  float absX = abs(x);
  float absY = abs(y);
  float absZ = abs(z);
  
  int isXPositive = x > 0 ? 1 : 0;
  int isYPositive = y > 0 ? 1 : 0;
  int isZPositive = z > 0 ? 1 : 0;
  
  float maxAxis, uc, vc,index;
  float3 forwardDir;
  float rate;
  
  // POSITIVE X
  if (isXPositive && absX >= absY && absX >= absZ) {
    // u (0 to 1) goes from +z to -z
    // v (0 to 1) goes from -y to +y
    //
    forwardDir=float3(1,0,0);

    //
    maxAxis = absX;
    uc = -z;
    vc = y;
    index = 0;
  }
  // NEGATIVE X
  if (!isXPositive && absX >= absY && absX >= absZ) {
    // u (0 to 1) goes from -z to +z
    // v (0 to 1) goes from -y to +y
    //
    forwardDir=float3(-1,0,0);
rate=dot(forwardDir,float3(x,y,z));
    //
    maxAxis = absX;
    uc = z;
    vc = y;
    index = 1;
  }
  // POSITIVE Y
  if (isYPositive && absY >= absX && absY >= absZ) {
    // u (0 to 1) goes from -x to +x
    // v (0 to 1) goes from +z to -z
    //
    forwardDir=float3(0,1,0);

    //
    maxAxis = absY;
    uc = x;
    vc = -z;
    index = 2;
  }
  // NEGATIVE Y
  if (!isYPositive && absY >= absX && absY >= absZ) {
    // u (0 to 1) goes from -x to +x
    // v (0 to 1) goes from -z to +z
    //
    forwardDir=float3(0,-1,0);

    //
    maxAxis = absY;
    uc = x;
    vc = z;
    index = 3;
  }
  // POSITIVE Z
  if (isZPositive && absZ >= absX && absZ >= absY) {
    // u (0 to 1) goes from -x to +x
    // v (0 to 1) goes from -y to +y
    //
    forwardDir=float3(0,0,1);

    //
    maxAxis = absZ;
    uc = x;
    vc = y;
    index = 4;
  }
  // NEGATIVE Z
  if (!isZPositive && absZ >= absX && absZ >= absY) {
    // u (0 to 1) goes from +x to -x
    // v (0 to 1) goes from -y to +y
    //
    forwardDir=float3(0,0,-1);
  
    //
    maxAxis = absZ;
    uc = -x;
    vc = y;
    index = 5;
  }

uc/=rate;
vc/=rate;

  // Convert range from -1 to 1 to 0 to 1
  return float2(0.5f * (uc / maxAxis + 1.0f),0.5f * (vc / maxAxis + 1.0f));
}