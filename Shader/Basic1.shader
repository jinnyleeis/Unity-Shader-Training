 // Shader 시작. 셰이더의 폴더와 이름을 여기서 결정합니다.
Shader "URPTraining/URPBasic1" //메터리얼서 쉐이더 선택시,폴더:ㅣ>shader파일이름> 쉐이더 옵션서 설렉 가능
{
	//코드에서 바꿀때마다 메터리얼 쉐이더 선택창에 이름 바로 반영됨
   Properties
   {
	_TintColor("Color",color)=(1,1,1,1)//r,g,b,a
	_Intensity("Range Sample", Range(0, 1)) = 0.5
    _MainTex ("Albedo(RGB)", 2D ) = "white" {}
	//"": 인스펙터 창에 노출되는 정보 얘가. + , : 변수타입 + =(): 기본값
	// 변수명 :  _TintColor유의: 숫자시,예약어,대소구분
	//언더바 안붙여도 ㅇㅋ 근데 프로퍼티 구분위해 
   }             
// Properties Block : 셰이더에서 사용할 변수를 선언하고 이를 material inspector에 노출시킵니다       	  
	SubShader
	{  
                 // 태그 부분 //

	Tags {//Render type과 Render Queue를 여기서 결정합니다.
	   "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"          
               "Queue"="Geometry" 
              }

             
 //hlsl 부분 //
       	HLSLINCLUDE
        

//cg shader는 .cginc를 hlsl shader는 .hlsl을 include하게 됩니다.
       	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"        	
  CBUFFER_START(unityPerMaterial)
  float4 __TintColor;
  CBUFFER_END

TEXTURE2D(_MainTex);//호춟1
SAMPLER(sampler_MainTex);//호출2
//텍스처를 샘플링하는데 사용하는 텍스쳐, 샘플러 정의: 호출2개

//쉐이더 2가지 구분 vertext(정점)& fragment
//쉐이더는 유니티에서 데이터를 수신하는 것으로 시작한다 
//속성은 인스펙터 창에서 본것같이 당연하고 
//정점 위치, UV좌표 같이 셰이더 그래프가 보이지 않게 처리해야하는 추가항목

//정점 : 셰이더가 연결된 옵젝 메쉬의 모든 정점에서 작동 
//- 정점을 화면의 올바른 위치에 배치 
//정점 쉐이더에 대한 <입력>으로 전달된 데이터 포함하는 구조체 
struct VertexInput
{

    float4 position : POSITION;//꼭짓점 위치
    float2 uv : TEXCOORD0;//uv 좌표
//hlsl의 특징 - 셰이더 컴파일러가 각 변수의 용도를 알 수 있도록 하기 위해 
//변수에 semantic 추가 POSITION semantic/ TEXCOORD0:텍스쳐좌표의 약자임

};
//출력 구조체
struct VertexOutput
    {
      // float4 vertex : SV_POSITION;//sv?픽셀 위치를 의미

    float4 position : SV_POSITION;//꼭짓점 위치
    float2 uv : TEXCOORD0;//uv 좌표
    };
    //주의 구조체 블럭 끝에 무조건 ; 찍어야!
//float4 __TintColor;

//vertex buffer에서 읽어올 정보를 선언합니다. 	
         
//보간기를 통해 버텍스 셰이더에서 픽셀 셰이더로 전달할 정보를 선언합니다.
        
//버텍스 셰이더
      
//픽셀 셰이더
        
        	ENDHLSL 


        Pass //구조체에 속성 말고 세부 버텍스 내용 작성은 여기서 
    	{  		
     	 //Name "Universal Forward"
              //Tags { "LightMode" = "UniversalForward" }


        HLSLPROGRAM
        //#pragma prefer_hlslcc gles
        //#pragma exclude_renderers d3d11_9x
        #pragma vertex vert // 유니티에 이러한 기능이 정점 밑 조각쉐이더임을알리는부분>드롭다운메뉴서할당가능하게
        #pragma fragment frag
//c와 같은 함수
//float4 __TintColor;
//VertexOutput<반환유형>vert<함수명>(VertexInput v<매개변수>입력에 대해v란버텍스인풋지정)
        VertexOutput vert(VertexInput v)
        	{
          	VertexOutput o; //출력에 대해 o란 VertexOutput 지정
            //이제 각각의 멤버 채우면 된당    
            //각각 정점이 모델 자체 중심점을 기준으로 배치되는 객체 공간에서 
            //각 정점이  2d화면 좌표를 기준으로 배치되는 클립공간을 정점변환해야
            //유니티가 이거 위한 urp에 할당된 함수인듯
            //여기에서 정점입력위치를 전달해서 > 정점 출력 위치에 할당
            //implicit truncation editor warning 제거 위해 xyz붙임.어??-?
          	o.position = TransformObjectToHClip(v.position.xyz);
            o.uv=v.uv;//uv좌표는 그런 변환 필요없음 그래서 걍 바로 변수할당하면ㅇㅋ

         	return o;
        	}
            //float4 __TintColor;

            //왜 fragment쉐이더가 픽셀쉐이더임: 이미지 조작은 1픽셀이니까 보통
            //// float4 vertex : SV_POSITION;//sv?픽셀 위치를 의미
            //위에꺼 까먹지마! 버텍스 출력구조체 안에서 꼭짓점의 의미체계임
            //이걸로 함수 자체에도 의미체계 제공
            //vs 버텍스 쉐이더는 전혀 필요없다 이게 
            //이함수가 해당 픽셀의 최종색상인 float4색상을 반환하고 
            //VertexOutput을 유일한 매개변수로 사용.

            float4 frag(VertexOutput v) : SV_Target
        	{       

            float4 baseTex=SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,v.uv);  
            //올바른 uv좌표서 기본 텍스쳐 샘플링 가능하게 uv좌표 전달
            //이미 Pos는 다 전달 ㅇㅇ       	
            //float4 baseTex*__TintColor;
            //각 요소 hlsl이 하나씩 곱하고 새 float4 반환 // 얘 중간작업 일케 안하고 한번에 리턴값으로 줘도 됨
          	//return baseTex*__TintColor;
            //return half4(_TintColor);왜 내가 보낸 틴트컬러놈이 변환이없냥 ㅠㅠ 머가 고정됨??>...
            return float4(__TintColor); 
			//half4(0.5 , 0.5, 0.5, 1);       	
        	}






        ENDHLSL 


        }
    	}
     }

