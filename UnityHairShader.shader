//////////////////Diffuse Lighting
fixed4 albedo = tex2D(_MainTex, i.uv);
half3 diffuseColor = albedo.rgb * _MainColor.rgb;
////////////////////////////////////
//获取头发高光
fixed StrandSpecular ( fixed3 T, fixed3 V, fixed3 L, fixed exponent)
{
    fixed3 H = normalize(L + V);
    fixed dotTH = dot(T, H);
    fixed sinTH = sqrt(1 - dotTH * dotTH);
    fixed dirAtten = smoothstep(-1, 0, dotTH);
    return dirAtten * pow(sinTH, exponent);
}
            
//沿着法线方向调整Tangent方向
fixed3 ShiftTangent ( fixed3 T, fixed3 N, fixed shift)
{
    return normalize(T + shift * N);
}

fixed3 spec = tex2D(_AnisoDir, i.uv).rgb;
//计算切线方向的偏移度
half shiftTex = spec.g;
half3 t1 = ShiftTangent(worldBinormal, worldNormal, _PrimaryShift + shiftTex);
half3 t2 = ShiftTangent(worldBinormal, worldNormal, _SecondaryShift + shiftTex);
//计算高光强度        
half3 spec1 = StrandSpecular(t1, worldViewDir, worldLightDir, _SpecularMultiplier)* _SpecularColor;
half3 spec2 = StrandSpecular(t2, worldViewDir, worldLightDir, _SpecularMultiplier2)* _SpecularColor2;

//////////////////////////////////////////////
fixed4 finalColor = 0;
finalColor.rgb = diffuseColor + spec1 * _Specular;//第一层高光
finalColor.rgb += spec2 * _SpecularColor2 * spec.b * _Specular;//第二层高光，spec.b用于添加噪点
finalColor.rgb *= _LightColor0.rgb;//受灯光影响
finalColor.a += albedo.a;