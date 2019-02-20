Shader"MyWrite/Depth"
{
  Properties
  { 
    _MainTex("Base(RGB)",2D)="White"{}
	_DepthPower("Depth",Range(0,1))=0.5
  
  }
  SubShader
  {
    Pass
	{
	  CGPROGRAM
	  #pragma vertex vert_img
	  #pragma fragment frag
	  #pragma fragmentoption ARG_precision_hint_fastest
	  #include "UnityCG.cginc"
	  uniform sampler2D _MainTex;
	  fixed _DepthPower;
	  sampler2D _CameraDepthTexture;
    
	fixed4 frag(v2f_img i):COLOR
	{
	  float depth =UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture,i.uv.xy));
	  depth=pow(Linear01Depth(depth),_DepthPower);
	  
	  return depth;
	}
	 


	 ENDCG
	}
   
  }

FallBack off
}