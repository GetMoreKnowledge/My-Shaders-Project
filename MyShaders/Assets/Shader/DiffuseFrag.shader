Shader"MyWrite/DiffuseFrag"
{
    Properties
	{
	  _Color("DiffuseColor",Color)=(1,1,1,1)
	}
  SubShader
  {
    Pass
	{
	 Tags{"LightMode"="ForwardBase"}
	  CGPROGRAM
	  #pragma vertex vert
	  #pragma fragment frag
	  #include "Lighting.cginc"
	  fixed4 _Color;

	  struct a2v
	  {
	    float4 vert :POSITION;
		float3 normal :NORMAL;
	  
	  };
	  struct v2f
	  {
	    float4 pos : SV_POSITION;
	    float3 worldNormal : TEXCOORD0;
	  
	  
	  };

	  v2f vert(a2v v)
	  {
        v2f o;
		o.pos=UnityObjectToClipPos(v.vert);//UnityObjectToClipPos(v.vertex);
		o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);//unity_WorldToObject
	    return o;  
	  }

	  fixed4 frag(v2f i):SV_Target
	  {
	    fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 worldNormal=normalize(i.worldNormal);
		fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
		//fixed3 diffuse = _LightColor0.rgb*_Color.rgb*saturate(dot(worldNormal,worldLightDir));//兰伯特
		//fixed3 color =ambient+diffuse;
		fixed halfLambert =dot(worldNormal,worldLightDir)*0.5+0.5;//半兰伯特
		fixed3 diffuse =_LightColor0.rgb*_Color.rgb*halfLambert;
		fixed3 color =ambient+diffuse;
		return fixed4(color,1.0);

	  }

	
	
	
	ENDCG
	}

  }
  Fallback "Dissuse"

}