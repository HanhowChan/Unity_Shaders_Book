Shader "Custom/MBumpedSpecular" //冯乐乐留的作业[doge]
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)  // 反射颜色
        _MainTex("Main Tex", 2D) = "white" {}   // 主贴图
        _BumpMap("Normal Map", 2D) = "bump" {}  // 法线贴图
        _Specular("Specular Color", Color) = (1,1,1,1)  // 高光反射颜色
        _Gloss("Gloss", Range(8.0, 256)) = 20   // 反射系数
        _AlphaScale("Alpha Scale",Range(0, 1)) = 1  //透明度
    }

    SubShader
    {
        //渲染类型
        Tags{"RenderType" = "Opaque" "Queue" = "Transparent"}   //渲染队列设置为Transparent;将在Geometry和AlphaTest队列中的物体渲染后,再按从后往前的顺序进行渲染;任何使用了透明度混合的物体都应该使用该队列
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            CGPROGRAM
            //编译命令
            #pragma multi_compile_fwdbase
            #pragma vertex vert //声明顶点着色器为vert
            #pragma fragment frag   //声明片元着色器为frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // xy分量存储缩放参数,zw分量存储偏移参数
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;    // uv的xy分量存储主贴图的坐标,zw分量存储法线贴图的坐标
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
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                // 切线空间到世界空间的矩阵
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                // 转换模型坐标到阴影贴图坐标
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // 计算世界空间法向量
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0, bump), dot(i.TtoW1, bump), dot(i.TtoW2, bump)));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // 反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                // 高光反射颜色
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
                // 阴影与光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(ambient + (diffuse + specular) * atten, texColor.a * _AlphaScale);
            }

            ENDCG
        }

        /*一个Unity Shader通常会定义一个Base Pass(Base Pass也可以定义多次,例如需要双面渲染等情况),一个Base Pass仅会执行一次(定义了多个Base Pass的情况除外)*/
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            CGPROGRAM
            //编译命令
            #pragma multi_compile_fwdbase
            #pragma vertex vert //声明顶点着色器为vert
            #pragma fragment frag   //声明片元着色器为frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
    
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // xy分量存储缩放参数,zw分量存储偏移参数
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;    // uv的xy分量存储主贴图的坐标,zw分量存储法线贴图的坐标
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
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                // 切线空间到世界空间的矩阵
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                // 转换模型坐标到阴影贴图坐标
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // 计算世界空间法向量
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0, bump), dot(i.TtoW1, bump), dot(i.TtoW2, bump)));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // 反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                // 高光反射颜色
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
                // 阴影与光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(ambient + (diffuse + specular) * atten, texColor.a * _AlphaScale);
            }

            ENDCG
        }
        /*Additional Pass会根据影响该物体的其它逐像素光源的数目被多次调用,*/
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            /*开启和设置混合模式;使该Additional Pass与上一次的光照结果在帧缓存中进行叠加,从而得到最终的有多个光照的渲染效果;如果
            没有开启和设置混合模式,那么Additional Pass的渲染结果会覆盖掉之前的渲染结果,看起来就好像该物体只受该光源的影响;通常情
            况下,选择的混合模式使Blend One One*/
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // xy分量存储缩放参数,zw分量存储偏移参数
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;    // uv的xy分量存储主贴图的坐标,zw分量存储法线贴图的坐标
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
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                // 切线空间到世界空间的矩阵
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                // 转换模型坐标到阴影贴图坐标
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // 计算世界空间法向量
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0, bump), dot(i.TtoW1, bump), dot(i.TtoW2, bump)));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // 反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                // 漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                // 高光反射颜色
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
                // 阴影与光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4((diffuse + specular) * atten, texColor.a * _AlphaScale);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
