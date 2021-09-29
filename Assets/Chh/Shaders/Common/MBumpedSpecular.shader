Shader "Custom/MBumpedSpecular"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)  // 反射颜色
        _MainTex("Main Tex", 2D) = "white" {}   // 主贴图
        _BumpMap("Normal Map", 2D) = "bump" {}  // 法线贴图
        _Specular("Specular Color", Color) = (1,1,1,1)  // 高光反色颜色
        _Gloss("Gloss", Range(8.0, 256)) = 20   // 反射系数
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGGPOGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
    
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 TtoW0:TEXCOORD1;
                float4 TtoW1:TEXCOORD2;
                float4 TtoW2:TEXCOORD3;
                SHADOW_COORDS(4);
            };
            ENDCG
        }
    }
    FallBack "Specular"
}
