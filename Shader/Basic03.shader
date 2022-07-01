 // Shader 시작. 셰이더의 폴더와 이름을 여기서 결정합니다.
Shader "URPTraining/URPBasic03" //메터리얼서 쉐이더 선택시,폴더:ㅣ>shader파일이름> 쉐이더 옵션서 설렉 가능
{
	//코드에서 바꿀때마다 메터리얼 쉐이더 선택창에 이름 바로 반영됨
   Properties
   {
	_TintColor("Color",color)=(1,1,1,1)//r,g,b,a
	_Intensity("Range Sample", Range(0, 1)) = 0.5
	_MainTex("Main Texture", 2D) = "white" {}
    _MainTex02("Main Texture02", 2D) = "white" {} //<<변화1>>
	
	//"": 인스펙터 창에 노출되는 정보 얘가. + , : 변수타입 + =(): 기본값
	// 변수명 :  _TintColor유의: 숫자시,예약어,대소구분
	//언더바 안붙여도 ㅇㅋ 근데 프로퍼티 구분위해 
   }             
// Properties Block : 셰이더에서 사용할 변수를 선언하고 이를 material inspector에 노출시킵니다       	  
	SubShader
	{  
	Tags
            {
//Render type과 Render Queue를 여기서 결정합니다.
	   "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"          
                "Queue"="Geometry"
				//더있음 나중에
            }
    	Pass
    	{  		
     	 Name "Universal Forward"
              Tags { "LightMode" = "UniversalForward" }



       	HLSLPROGRAM
        	#pragma prefer_hlslcc gles
        	#pragma exclude_renderers d3d11_9x
        	#pragma vertex vert
        	#pragma fragment frag
	//float4 rgba에 대한 hlsl유형 - 실제론 4개 요소 벡터에 불가 (즉, 색상에 국한은X)

//cg shader는 .cginc를 hlsl shader는 .hlsl을 include하게 됩니다.
       	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"  
		 	
  
//vertex buffer에서 읽어올 정보를 선언합니다. 	
         	struct VertexInput
         	{
            	float4 vertex : POSITION;
				//float _Intensity; -아니 왜 얠 여기다. 외부에서 불러오는게 아니러ㅏ 여기서 프로퍼티로 선언해서 쓰는거잖아
				float2 uv1 : TEXCOORD0; //texture매핑위함임
                float2 uv2 : TEXCOORD1;
          	};
//보간기를 통해 버텍스 셰이더에서 픽셀 셰이더로 전달할 정보를 선언합니다.
        	struct VertexOutput
          	{
           	float4 vertex  	: SV_POSITION;
			float2 uv1 : TEXCOORD0; //texture매핑위함임
            float2 uv2 : TEXCOORD1;
			//float positionWS : COLOR;//오류남 position이니까 xyz float3여야!!실수 주의
			//float _Intensity; //앤 버텍스 아웃풋에 불러와서 픽셀 셰이더가 받아서 사용할 수 있게끔 하기만 하면 된당 
			// 에 근데 픽셀로 변환할게 없잖아.. 얘도 걍 인풋일때 안집어넣는거랑 마찬가지 밖에다가 선언해
			//구조체 두개 내부 똑같은듯 
			//float3 positionWS:COLOR;//SEMANTIC설정도 빼먹지말길,,, 아니면 오류남
      	};


		float _Intensity; // 이렇게 이용할 것들인데, 픽셀 변환 필요없는것들은 여기다가 선언하면 됨 
		half4 _TintColor; 

		sampler2D _MainTex;
        float4 _MainTex01_ST;

        sampler2D _MainTex02;
		float4 _MainTex02_ST;
//버텍스 셰이더
      	VertexOutput vert(VertexInput v)
        	{
          	VertexOutput o;      
          	o.vertex = TransformObjectToHClip(v.vertex.xyz);
			//o.positionWS=TransformObjectToWorld(v.vertex.xyz);			
			//o.uv = v.uv.xy;//버텍스 버퍼에서 받아온거 v
            //o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw; xy 음
            o.uv1 = v.uv1;
            o.uv2 = v.uv2;

         	return o;
        	}
//픽셀 셰이더
        	half4 frag(VertexOutput i) : SV_Target
        	{                	
          	//return half4(_TintColor);

			//return half4(1,1,1, 1)*_Intensity; //이것만 하면, 색깔 고정 밝기 설정가능
			//return half4(_TintColor)*_Intensity; // 밝기, 색 다 리턴 고정값 아니고 사용자지정 가능하게 
			//return half4(i.vertex);
			///*_Intensity;
			float2 uv1 = i.uv1.xy * _MainTex01_ST.xy + _MainTex01_ST.zw;//여기여기 
            float2 uv2 = i.uv2.xy * _MainTex02_ST.xy + _MainTex02_ST.zw;//여기여기 

			half4 col01 = tex2D(_MainTex, uv1); 
            half4 col02 = tex2D(_MainTex02, uv2);     
			//float4 color = tex2D(_MainTex, uv):앞에서 선언한 텍스쳐변수명, uv값 입력  
			//* _TintColor * _Intensity;  //3개 속성 다 적용됨 wow tiling-스케일 관련 / offset-texture 이동 
			//만약, float2 uv = i.uv.xy 요것만 하면, 옵셋, 타일링 변화 없을 것임 바꿔도- 일단 프로퍼티 정의로 인해 노출은 될텐데 
// half4 col01=_MainTex.Sample(sampler_MainTex,i.uv);
            //float 

            half4 color=col01*col02;

			//WORLD pos
			//float4 color = tex2D(_MainTex, i.positionWS.xz*0.5) * _TintColor * _Intensity;  //월드공간포지션으로 고정 >tile변경 불가.
			return color;   	
        	}
        	ENDHLSL  
    	}
     }
}
