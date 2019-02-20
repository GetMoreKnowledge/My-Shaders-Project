// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyWrite/Transparent"{

  SubShader{
     Tags{"Queue"="Transparent"}
  

     GrabPass{}
	 Pass
	 {
	   CGPROGRAM
	   #pragma vertex vert
	   #pragma fragment frag
	   #include "UnityCG.cginc"
	   sampler2D _GrabTexture;


	   struct vertInput{
	   
	   float4 vertex :POSITION;
	   };

	   struct vertOutInput{
	   
	    float4 vertex : POSITION;
		float4 uvgrab : TEXCOORD1;
	  
	   };
	   vertOutInput vert(vertInput v)
	   {
	        vertOutInput o;
			o.vertex=UnityObjectToClipPos(v.vertex);
			o.uvgrab=ComputeGrabScreenPos(o.vertex);
			return o;

	   }
	   half4 frag(vertOutInput i):COLOR
	   {
	     fixed4 col=tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.uvgrab));
		 return col+half4(0.5,0,0,0);
	   }
	 
	 
	 
	 
	 
	 
	 ENDCG
	 
	 
	 
	 
	 
	 
	 
	 }
  
  }




























}