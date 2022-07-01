Shader "URPTraining/ref"
{

   Properties {
   
   	 _TintColor("Test Color", color) = (1, 1, 1, 1)
	 _Intensity("Range Sample", Range(0, 1)) = 0.5
	 _MainTex("Main Texture", 2D) = "white" {}

	 _Alpha("AlphaCut", Range(0,1)) = 0.5
     //변화3 0미만 없으면 안날리게 되니까
      	
       	}  

	SubShader
	{  	
	Tags
            {//변화11 태그 바꿔라 
	"RenderPipeline"="UniversalPipeline"
           "RenderType"="TransparentCutout" //opaque불투명에서 이걸로 바꿔야         
           "Queue"="Alphatest" //
		}
    	Pass
    	{  		
     	 Name "Universal Forward"
            Tags {"LightMode" = "UniversalForward"}

       	HLSLPROGRAM
        	#pragma prefer_hlslcc gles
        	#pragma exclude_renderers d3d11_9x

        	#pragma vertex vert
        	#pragma fragment frag
       	       	

       	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		       	
	half4 _TintColor;
	float _Intensity;
	float _Alpha;//변화3 0미만 없으면 안날리게 되니까

	float4 _MainTex_ST;
	Texture2D _MainTex;
	SamplerState sampler_MainTex;	
         	
         	struct VertexInput
         	  {
            	float4 vertex : POSITION;
            	float2 uv       : TEXCOORD0;
          	  };

        	struct VertexOutput
          	  {
           	           float4 vertex  	: SV_POSITION;
                       float2 uv      	: TEXCOORD0;           	
      	  };

      	VertexOutput vert(VertexInput v)
        	  {
          	VertexOutput o;
      
          	o.vertex = TransformObjectToHClip(v.vertex.xyz);                 	
          	o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;		

         	return o;
        	  }

        	half4 frag(VertexOutput i) : SV_Target
        	{                  	            
	float4 color = _MainTex.Sample(sampler_MainTex, i.uv);
    //변화2 -pixel shader내의 변화!! -  태그 바꿔라 
	color.rgb *= _TintColor * _Intensity;
			
	clip(color.a - _Alpha);//변화3 0미만 없으면 안날리게 되니까

          	return color;
        	  }
	ENDHLSL  
    	  }
     }

}

