// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader"MyWrite/ShadowMat"
{
   Properties
   {
   
   _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
   _SpecularColor("SpecularColor",Color)=(1,1,1,1)
   _Gloss("_Gloss",Range(8.0,256))=20
   
   
   }
   SubShader
  {

     Pass
	{
	       Tags
	     {
	      "LightMode"="ForwardBase"
	 
	     }
	  CGPROGRAM
	  #pragma vertex vert
	  #pragma fragment frag
	  #pragma multi_compile_fwdbase
	  #include "Lighting.cginc"
	  #include "AutoLight.cginc"
	  fixed4  _DiffuseColor; 
	  fixed4 _SpecularColor;
	  float _Gloss;
	    
       struct a2v
	    {
	      float4 vertex : POSITION;
         float3 normal :NORMAL;
	    };
   
       struct v2f
	    {
	     float4 pos: SV_POSITION;
	    float3 worldNormal :TEXCOORD0;
	    float3 worldPos : TEXCOORD1;
		SHADOW_COORDS(2)
	
	    };
	   v2f vert(a2v v)
	   {
	     v2f o;
	      o.pos=UnityObjectToClipPos(v.vertex);
	       o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
          o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
		  TRANSFER_SHADOW(o);
	       return o;
	    }
	    fixed4 frag(v2f i):SV_Target
	    {
	       fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz;
           fixed3 worldNormal=normalize(i.worldNormal);
	      fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
	       fixed3 diffuse =_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(worldNormal,worldLightDir));
	     fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));
	      fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
	     fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
	      fixed atten=1.0;
		  fixed shadow = SHADOW_ATTENUATION(i);
	      return fixed4(ambient+(diffuse+specular)*atten*shadow,1.0);
	
	    }
	  ENDCG
 }
   
    Pass
	{  Tags
	  {
	   "LightMode"="ForwardAdd"

	   
	  }
	
	 Blend One One
	  CGPROGRAM
	  #pragma multi_compile_fwdadd
	  #pragma vertex vert
	  #pragma fragment frag
	  #include "Lighting.cginc"
	  #include "Autolight.cginc"
	  fixed4  _DiffuseColor; 
	  fixed4 _SpecularColor;
	  float _Gloss;
	    
     struct a2v
	{
	  float4 vertex : POSITION;
	  float3 normal :NORMAL;
	};
   
    struct v2f
	{
	  float4 pos: SV_POSITION;
	  float3 worldNormal :TEXCOORD0;
	  float3 worldPos : TEXCOORD1;
	  
	
	};
	v2f vert(a2v v)
	{
	  v2f o;
	  o.pos=UnityObjectToClipPos(v.vertex);
	  o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
	  o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
	  return o;
	}
	fixed4 frag(v2f i):SV_Target
	{
	 fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz;
    fixed3 worldNormal=normalize(i.worldNormal);

 #ifdef USING_DIRECTIONAL_LIGHT

	 fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

 #else 

	 fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
#endif

    fixed3 diffuse =_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(worldNormal,worldLightDir));
	 fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));
     fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
	fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
#ifdef USING_DIRECTIONAL_LIGHT
	 fixed atten=1.0;
#else 
    float3 lightCoord=mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
	fixed atten=tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif
	 return fixed4(ambient+(diffuse+specular)*atten,1.0);
	
	} 
	  ENDCG
   
	
  
    }
 
}
 Fallback"Specular"



}