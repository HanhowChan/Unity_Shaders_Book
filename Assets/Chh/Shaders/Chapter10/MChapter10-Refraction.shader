﻿Shader "Custom/MChapter10-Refraction"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _RefractColor("Refraction Color", Color) = (1, 1, 1, 1) //折射的颜色
        _RefractAmount("Refraction Amount", Range(0, 1)) = 1    //折射程度
        _RefractRatio("Refraction Ratio", Range(0.1, 1)) = 0.5  //折射的透射比,以此来计算折射方向
        _Cubemap("Refraction Cubemap", Cube) = "_Skybox" {} //用来采样的立方体纹理
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
                float3 worldPos:TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                //计算世界空间中的折射方向,参数为归一化的入射光线方向矢量,归一化表面法线矢量,入射光线所在介质的折射率和折射光线所在介质的折射率之间的比值
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                //使用折射方向对立方体纹理进行采样
                fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
