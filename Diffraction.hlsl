
	float3 L = gi.light.dir;//世界光线
	float3 V = viewDir;//世界视线
	float3 T = worldTangent;//世界切线

	float d = _Distance;//微表面间距1600-10000


	float cos_ThetaL = dot(L, T);
	float cos_ThetaV = dot(V, T);
	float u = abs(cos_ThetaL - cos_ThetaV);//相位差 

    fixed3 color = 0;
	if (u == 0)
		return color;

	// Reflection colour散射颜色
	
	for (int n = 1; n <= 8; n++)
	{
		float wavelength = u * d / n;
		color += spectral_zucconi6(wavelength);
	}
	color = saturate(color);

	// Adds the refelection to the material colour
	return color;


//////////////////////////////////////
//////////////

float3 spectral_zucconi (float wavelength)
{
// w: [400, 700]
 // x: [0,   1]
 float x = saturate((wavelength - 400.0)/ 300.0);
 
 const float3 cs = float3(3.54541723, 2.86670055, 2.29421995);
 const float3 xs = float3(0.69548916, 0.49416934, 0.28269708);
 const float3 ys = float3(0.02320775, 0.15936245, 0.53520021);
 
 //return bump3y ( cs * (x - xs), ys);
 float3 x1=cs * (x - xs);
 float3 y = 1 - x1 * x1;
 y = saturate(y-ys);
return y;

}

/////////////////////
////////////////////////////////UE4代码!!!!!
	float3 L = gi.light.dir;//世界光线
	float3 V = viewDir;//世界视线
	float3 T = worldTangent;//世界切线

	float d = _Distance;//微表面间距1600-10000


	float cos_ThetaL = dot(L, T);
	float cos_ThetaV = dot(V, T);
	float u = abs(cos_ThetaL - cos_ThetaV);//相位差 

    fixed3 color = 0;
	if (u == 0)
		return color;

	// Reflection colour散射颜色
	
	for (int n = 1; n <= 8; n++)
	{
		float wavelength = u * d / n;

		//波长到颜色映射
		float x = saturate((wavelength - 400.0)/ 300.0);
  	 	float3 cs = float3(3.54541723, 2.86670055, 2.29421995);
 	 	float3 xs = float3(0.69548916, 0.49416934, 0.28269708);
 		float3 ys = float3(0.02320775, 0.15936245, 0.53520021);

 		float3 x1=cs * (x - xs);
 		float3 y = 1 - x1 * x1;
 		y = saturate(y-ys);

		color += y;
	}
	color = saturate(color);

	// Adds the refelection to the material colour
	return color;