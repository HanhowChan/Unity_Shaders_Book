Shader "Custom/MBumpedDiffuse"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
        _BumpTex("Bump Tex", 2D) = "bump" {}
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION; //裁剪空间坐标
                float4 uv:TEXCOORD0;
                float4 TtoW0:TEXCOORD1;
                float4 TtoW1:TEXCOORD2;
                float4 TtoW2:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;  //副切线

                //切线空间到世界空间的矩阵
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // 根据法线纹理获取法向量 
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));    //法线纹理一般存储的是切线空间的法向量
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));    //计算世界空间中的法向量(将法向量从切线空间转换到世界空间)
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(ambient + diffuse * atten, 1.0);
            }
            ENDCG
        }
    }
        Fallback "Diffuse"
}
