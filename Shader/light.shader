Shader "Custom/light"
{
Properties 
  {

  }  

  SubShader
        {  	
       Tags
        {
        "RenderPipeline"="UniversalPipeline"
        "RenderType"="Opaque"          
        "Queue"="Geometry"		
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
	
      struct VertexInput
          {
           	float4 vertex : POSITION;
	float3 normal : NORMAL;//면에 수직이다 법선 pmesh서 노멀정보 읽어와 -노멀도 월드공간으로 변환해야!!!!
    //노멀, 포지션 둘다. 
          };

     struct VertexOutput
          {
            float4 vertex  	: SV_POSITION;
	float3 normal      : NORMAL;
      	  };

   VertexOutput vert(VertexInput v)
        	{
          	VertexOutput o;      
          	o.vertex = TransformObjectToHClip(v.vertex.xyz); 				         	
	o.normal = TransformObjectToWorldNormal(v.normal);
    //면에 수직이다 법선 pmesh서 노멀정보 읽어와 -노멀도 월드공간으로 변환해야!!!!
    //월드로 안바꿔주고 옵젝상태로 놔두면, 그림자를 따라간다 
    //포지션 변환과 다르게 노말ㅇ 노말x 된걸로 심화적으로 조건 나눠야 
    //노멀, 포지션 둘다. 
			
         	return o;
        	}					

    half4 frag(VertexOutput i) : SV_Target
        	{	  	
            float3 LightColor = _MainLightColor.rgb;
           //float3 Light = _MainLightPosition.xyz;


			 
	//float NdotL = saturate(dot(Light, i.normal));
          //	float4 color = float4(1,1,1,1);			

	float3 light = _MainLightPosition.xyz;
          	float4 color = float4(1,0,0,1);
            //saturate함수 : 두 벡터 내적 > 얼마나 비슷 
            //코세타값 0 : 같방 즉, 1 > 밝
            //두 벡터 직각 : 코세타값 0  > 어둡 . 모서리
           // float3 toonlight = ceil((NdotL) * _lightwidth) / _lightStep * LightColor;
	//float3 ambient = NdotL > 0 ? 0 : _Ambientcolor.rgb;

	//color.rgb *= toonlight + ambient ;

	color.rgb *= saturate(dot(i.normal, light)) * _MainLightColor.rgb;	
    //0-1사이로 
	//return color;
    //	float3 LightColor = _MainLightColor.rgb;
	//float3 Light = _MainLightPosition.xyz;
			 
	//float3 NdotL = saturate(dot(Light, i.normal));
         // 	float4 color = float4(1,1,1,1);			
	//float3 toonlight = _MainLightColor.rgb ;		
	//color.rgb *= toonlight + ambient;
	return color;

        	}
 ENDHLSL  
  	}
     
}
}

