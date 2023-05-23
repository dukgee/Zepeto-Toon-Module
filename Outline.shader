Shader "Deferred/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        // LOD 100
        Cull Off ZWrite Off// ZTest Always
        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 scrpos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.scrpos = ComputeScreenPos(o.vertex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
             
            float _Thickness;
            float _TransitionSmoothness;
            float _Edge;
            float4 _Color;
            sampler2D _CameraDepthTexture;
            sampler2D sampler_CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                _Thickness = 2;
                _TransitionSmoothness = 2.5;
                _Edge =1;
                float2 offset = _Thickness / _ScreenParams;
                _Color = float4(0,0,0,1);


                float2 coord = UNITY_PROJ_COORD(i.scrpos);
          
                float left = LinearEyeDepth( tex2Dproj(_CameraDepthTexture,     float4(coord.x-offset.x,coord.y,1,1) )  .x);
                float right = LinearEyeDepth(  tex2Dproj(_CameraDepthTexture,   float4(coord.x+offset.x,coord.y,1,1))  .x );
                float up = LinearEyeDepth(  tex2Dproj(_CameraDepthTexture,      float4(coord.x,coord.y+offset.y,1,1))  .x );
                float down = LinearEyeDepth(  tex2Dproj(_CameraDepthTexture,    float4(coord.x,coord.y-offset.y,1,1))  .x );

                float delta = sqrt( pow(right - left, 2) + pow(up - down, 2) );

                float t = smoothstep(_Edge, _Edge + _TransitionSmoothness, delta);

                float4 mainTex = tex2D(_MainTex, i.uv);

                float4 color = lerp(mainTex, _Color, _Color.a);

                float4 output = lerp(mainTex, color, t);
  
                return output;
            }
            ENDCG
        }
    }
}