Shader "Custom/MChapter10-Refraction"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _RefractColor("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractAmount("Refraction Amount", Range(0, 1)) = 1
        _RefractRatio("Refraction Ratio", Range(0.1, 1)) = 0.5
        _Cubemap("Refraction Cubemap", Cube) = "_Skybox" {}
    }
        SubShader
    {
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
            float4 pos:SV_POSITION;
                float3 worldNormal:
            };
            ENDCG
        }
    }
    FallBack "Diffuse"
}
