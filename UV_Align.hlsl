float3 Nomal;
float3 Location;
float3 n=abs(Nomal);
if(n.x>n.y && n.x>n.z){
    if(Nomal.x>0){
        return -Location.yz;
    }else{
        return float2(Location.y,-Location.z);
    }
}else if(n.y>n.x && n.y>n.z){
    if(Nomal.y>0){
         return float2(Location.x,-Location.z);
    }else{
        return -Location.xz;
    }

}else{
    if(Nomal.z>0){
        return Location.xy;
    }else{
        return float2(Location.x,-Location.y);

    }
}