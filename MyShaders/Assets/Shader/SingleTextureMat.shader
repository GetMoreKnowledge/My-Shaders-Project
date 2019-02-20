
Shader"MyWrite/SingleTextureMat"
{
  Properties
  {
     _MainTexture("MainTexture",2D)="white"{}
	 _Color("Color_Tint",Color)=(1,1,1,1)
	 _Specular("Specular",Color)=(1,1,1,1)
	 _Gloss("Gloss",Range(8.0,256))=20

  }
  SubShader
  {
    Pass
	{
	   Tags
	   {
	    "LightMode"="ForWardBase"
	   }
	   CGPROGRAM
	   #pragma vertex vert
	   #pragma fragment frag
	   #include "Lighting.cginc"
	   fixed4 _Color;
	   sampler2D _MainTexture;
	   float4 _MainTexture_ST;
	   fixed4 _Specular;
	   float _Gloss;

	   struct a2v
	   {
	     float4 vertex : POSITION;
		 float3 normal : NORMAL;
		 float4 texcoord : TEXCOORD0;
	   
	   };
	   struct v2f
	   {
	     float4 pos :SV_POSITION;
		 float3 worldNormal : TEXCOORD0;
		 float3 worldPos : TEXCOORD1;
		 float2 uv : TEXCOORD2;

	   };

	   v2f vert(a2v v)
	   {
	    v2f o;
		o.pos=UnityObjectToClipPos(v.vertex);
		o.worldNormal=UnityObjectToWorldNormal(v.normal);
		o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
		o.uv=v.texcoord.xy*_MainTexture_ST.xy+_MainTexture_ST.zw;//等价
		//o.uv=TRANSFORM_TEX(v.texcoord,_MainTexture);
		return o;
	   
	   }  
	   fixed4 frag(v2f i) : SV_Target
	   {
	     fixed3 worldNormal =normalize(i.worldNormal);
		 fixed3 worldLighTDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
		 fixed3 albedo =tex2D(_MainTexture,i.uv).rgb*_Color.rgb;
		 fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
		 fixed3 diffuse=_LightColor0.rgb*albedo.rgb*max(0,dot(worldNormal,worldLighTDir));
		 fixed3 viewDir= normalize(UnityWorldSpaceViewDir(i.worldPos));
		 fixed3 halfDir = normalize(worldLighTDir+viewDir);
		 fixed3 specular =_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);
		 return fixed4(ambient+diffuse+specular,1.0);
	   
	   }
	   ENDCG

	}  
  
  
  }
  FallBack  "Specular"





}