﻿Shader"MyWrite/MaskShader"
{
   Properties
  {
    _Color("Color Tint",Color)=(1,1,1,1)
	_MainTex("Main Tex",2D)="white"{}
	_BumpMap("NormalMap",2D)="bump"{}
	_BumpScale("BumpScale",float)=1.0
	_SpecularMask("SpecularMask",2D)="white"{}
	_SpecularScale("SpecularScale",float)=1.0
	_Specular("SpecularColor",Color)=(1,1,1,1)
	_Gloss("Gloss",Range(8.0,256))=20
  }
  SubShader
  {
   LOD 300
   Pass
   {
    Tags{"LightMode"="ForWardBase"}

    CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "Lighting.cginc"
	fixed4 _Color;
	sampler2D _MainTex;
	sampler2D _BumpMap;
	float _BumpScale;
	sampler2D _SpecularMask;
	float _SpecularScale;
	fixed4 _Specular;
	float _Gloss;
	float4 _MainTex_ST;

	struct a2v
	{
	 float4 vertex : POSITION;
	 float3 normal : NORMAL;
	 float4 tangent : TANGENT;
	 float4 texcoord : TEXCOORD0;
	};

	struct v2f
	{
	  float4 pos : SV_POSITION;
	  float2 uv : TEXCOORD0;
	  float3 lightDir : TEXCOORD1;
	  float3 viewDir : TEXCOORD2;

	};
	v2f vert(a2v v)
	{
	  v2f o;
	  o.pos=UnityObjectToClipPos(v.vertex);
	  o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
	  TANGENT_SPACE_ROTATION;
	  o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
	  o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
	  return o;
	
	}
	fixed4 frag(v2f i) : SV_Target
	{
	 fixed3 tangentLightDir =normalize(i.lightDir);
	 fixed3 tangentViewDir= normalize(i.viewDir);
	 fixed3 tangentNormal=UnpackNormal(tex2D(_BumpMap,i.uv));
	 tangentNormal.xy*=_BumpScale;
	 tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
	 fixed3 aldobe =tex2D(_MainTex,i.uv).rgb*_Color.rgb;
	 fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz*aldobe;
	 fixed3 diffuse=_LightColor0.rgb*aldobe*max(0,dot(tangentNormal,tangentLightDir));
	 fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
	 fixed specularMask=tex2D(_SpecularMask,i.uv).r*_SpecularScale;
	 fixed3 specular =_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss)*specularMask;
	 return fixed4(ambient+diffuse+specular,1.0);

	}

	ENDCG
  
   } 
  
  }

  FallBack"Diffuse"

}