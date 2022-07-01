Shader "URPTraining/worldpos"
{ 
   Properties {   	

     _MainTex("RGB 01", 2D) = "white" {}
    _MainTex02("RGB 02", 2D) = "white" {}
    _TintColor("color",color)=(1,1,1,1)//r,g,b,a
   	 _MaskTex("Mask Texure", 2D) = "white" {}
     _Intensity("Range Sample", Range(0, 1)) = 0.5

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
	
         struct VertexInput //버텍스 버퍼서 uv정보 읽어오도록
          {
           	float4 vertex : POSITION; 
            float2 uv :TEXCOORD0;   
            float3 color: COLOR;    
          };

        struct VertexOutput
          {
            float4 vertex  	: SV_POSITION;
            float2 uv :TEXCOORD0; 
             float3 color: COLOR;    //까먹지마 보강기에 선언하는거
            //float2 uv2	: TEXCOORD1;
            //읽어오는건 동일 채널로 읽어와도//
                //분리가능 
        };

float4 _Intensity;
        float4 _TintColor;
         float4 _MainTex_ST;

   		 Texture2D _MainTex;

   		 SamplerState sampler_MainTex;
         //samplers는 하나로 두개 분리해서 사용가능.

        float4 _MainTex02_ST;
   		Texture2D _MainTex02; 	

         
         //float4 _MaskTex_;//offset, tiling 안하니까 st붙일필요없음 - 아뭐래.. 그게 아니라 - 아예필요없는거지
         Texture2D _MaskTex;
         //Shader error in 'URPTraining/URPuvouttopixel':
         // float4 object does not have methods at line 106 (on metal)깜빡했더니난 오류 이거선언 텍스쳐

    
          	//VertexOutput o;				
          //	o.vertex = TransformObjectToHClip(v.vertex.xyz);
	//o.vertex.y += v.vertex.x;
	//o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;					            
	//return o;
    VertexOutput vert(VertexInput v)
        	{
          		VertexOutput o;				
          		o.vertex = TransformObjectToHClip(v.vertex.xyz);
                //로컬 to perspective까지 이걸로 한번에 변환

		half3 positionWS = TransformObjectToWorld(v.vertex.xyz);				
		   o.vertex.y += positionWS;
            //o.vertex = positionWS + float4(sin(color +_Time.y), 1);
            //sin안에 시간 > 움직-1~1 : 0일땐 없 y값 0이잖

            o.color=TransformObjectToWorld(v.vertex.xyz);
           // o.color = pixel의 정보값에따라 > 버텍스 위치에 월드값이 rgb에 반영되어 
           //xyz니까 3채널 rgb
            
        //중요!! 
        //포지션 값 > 옵젝공간에서 월드값으로 변환한것을 컬러에 집어넣는다 
            //화면에그릴때는 픽셀 화면에 찍어서 하는데 
            //세이더에서 이 값을 계산을 위해서 쓴다면 
        //o.vertex.y += sin(v.vertex.x);

		o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
        //버텍스 쉐이더에서 월드 공간으로 변환된 버텍스를 구해준다. 
		return o;
        	}	
	


        	half4 frag(VertexOutput i) : SV_Target
        	{ 		
                //return float4(0.5,0.5,0.5,1);
                //uv의 좌표를 읽어보자 
               // float4 color=i.uv.x;
                //return float4(i.uv.x,i.uv.y,0,1);- uv좌표값으로 리턴해서 컬러
               // return color;

           //float4 color = color;//첫변선언
            //밑에 조건문 적용 전에, uv x값으로 0.5 밝기 확인 너무 밝아서 감마 코렐레이션 조건문 사용해서 밝기 조절 시킬것임
            //감마 
           // if(i.uv.y > 0.5)// 얘는 딱 절반 나눠서 적용0 / 적용x 할라공
            {
            //color = pow(i.uv.x, 2.2) ;//각 값들의 2.2를 제곱 - 감마 코렐레이션이 적용된것임 //해
            //소수점이니까 더 작아져서 > 더 어두워질것임 
            //왜 적용?? 
            }
            //else
            {
            //color = i.uv.x;//적용하지마 

        	}

             //return color;
             float2 uv = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;//scale은 곱하고 / offset은 더해준다
   		     float2 uv2 = i.uv.xy * _MainTex02_ST.xy + _MainTex02_ST.zw;

         float4 tex01 = _MainTex.Sample(sampler_MainTex, uv);
   		 float4 tex02 = _MainTex02.Sample(sampler_MainTex, uv2); 
         float4 mask = _MaskTex.Sample(sampler_MainTex, uv); 
         //float4 color = lerp(tex01, tex02, mask.r);//msk tex의 r값 가지고 섞어라
  		
   		 //float4 color = lerp(tex01, tex02, i.uv.x);
         //float4 color = lerp(tex01, tex02, 0.5);
         //return color*__TintColor;
         //만약 이거라면, 1번텍스쳐 움직이면 2번텍스쳐도 따라움직이게된다 
          //float4 tex02 = _MainTex02.Sample(sampler_MainTex, i.uv);
          //오 이거 잘덴당
          //여기서 주의!! 마스크텍스쳐는 타일링 안된당 
           half4 color = half4(0.5,0.5,0.5,1);
          //float4 color;

          //color.rgb *= _TintColor * _Intensity * i.color ;
          color.rgb+=i.color;
          return color;



            }

           
	  ENDHLSL  
    	  }
     }
}
// 겁나 중요 
//상황. uv값 두개 사용해서, 텍스쳐 두개 따로따로 설정후 합칠 수 있도록 하려고 한다. 

//보관기 그 아웃풋 구조체서 선언한 uv. 

//1:계산을 버텍스 쉐이더에서 수행한다면?? or 2:계산을 픽셀쉐이더에서 곧바로 적용하고 리턴한다면?
// 1:일땐, 버텍스쉐이더 > 보관기가 배라고 함 버텍스값 보내주는 > 픽셀 쉐이더
//그러니까, 1일경우, 보관기에서  그 아웃풋 구조체서 선언한 uv.  필요 그니까 두개 uv
// float2 uv :TEXCOORD0; 
//float2 uv2 : TEXCOORD1;
//2일땐, 픽셀에서 두개를 나눠서 유비이 두개만들어서 계산해버리면, 두개 보관기 선언해서 보낼필요가 없게됨.> 주석처리 하나.

