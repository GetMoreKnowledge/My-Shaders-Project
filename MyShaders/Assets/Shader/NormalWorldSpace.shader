Shader"MyWrite/NormalWorldSpace"
{
  Properties
  {
    _Color("Color Tint",Color)=(1,1,1,1)
	_MainTex("MainTex",2D)="white"{}
	_BumpMap("BumpTex",2D)="bump"{}
	_BumpScale("Bump Scale",float)=1.0
	_Specular("Specular",Color)=(1,1,1,1)
	_Gloss("Gloss",Range(8.0,256))=20

  
  }

  SubShader
  {
   LOD 300
    Tags
	{
	"LightMode"="ForWardBase"
	
	}
   Pass
   {
    CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "Lighting.cginc"
	fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _BumpMap;
	float4 _BumpMap_ST;
	float _BumpScale;
	float _Gloss;
	fixed4 _Specular;
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
	  float4 uv : TEXCOORD0;
	  float4 Ttow0 : TEXCOORD1;
	  float4 Ttow1 : TEXCOORD2;
	  float4 Ttow2 : TEXCOORD3;
	
	};
	
	v2f vert (a2v v)
	{
	  v2f o;
	  o.pos= UnityObjectToClipPos(v.vertex);
	  o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
	  o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
	  float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
	  fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
	  fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
	  fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;
	  o.Ttow0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
	  o.Ttow1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
	  o.Ttow2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
	  return o;
	 
	}
	fixed4 frag(v2f i) : SV_Target
	{
	  float3 worldPos =float3(i.Ttow0.w,i.Ttow1.w,i.Ttow2.w);
	  fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
	  fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
	  fixed3 bump =UnpackNormal(tex2D(_BumpMap,i.uv.zw));
	  bump.xy*=_BumpScale;
	  bump.z=sqrt(1.0-saturate(dot(bump.xy,i.uv.zw)));
	  bump =normalize(half3(dot(i.Ttow0.xyz,bump),dot(i.Ttow1.xyz,bump),dot(i.Ttow2.xyz,bump)));
	  fixed3 tangentLightDir =normalize(lightDir);
	  fixed3 tangentViewDir =normalize(viewDir);
	  //fixed4 packedNormal =tex2D(_BumpMap,i.uv.zw);
	  //fixed3 tangentNormal;
	  //tangentNormal=UnpackNormal(packedNormal);
	  //tangentNormal.xy*=_BumpScale;
	  //tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
	  fixed3 albedo =tex2D(_MainTex,i.uv).rgb*_Color.rgb;
	  fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
	  fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(bump,tangentLightDir));
	  fixed3 halfDir =normalize(tangentLightDir+tangentViewDir);
	  fixed3 specular =_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(bump,halfDir)),_Gloss);
	  return fixed4(ambient+diffuse+specular,1.0);
	}

    ENDCG
   }
   
  }
  Fallback "Diffuse"

}