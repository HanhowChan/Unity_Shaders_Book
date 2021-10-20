// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/MChapter8-AlphaBlend"
{
	Properties
	{
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1	//1.增加_AlphaScale用于在透明纹理的基础上控制政体的透明度
	}

	SubShader
	{
		/*将Queue标签设置为Transparent,设置渲染队列为透明度混合使用的Transparent队列;
		* 设置IgnoreProjector标签为True,使该Shader不会受到投影器(Projectors)的影响;
		* RenderType标签设置为Transparent,让Unity把这个Shader归入到提前定义的组,用来指明该Shader是一个使用了透明度混合的Shader;
		*/
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass
		{
			//设置LightMode标签为ForwardBase,让Unity能够按前向渲染路径的方式为Shader正确提供各个光照变量
			Tags{"LightMode" = "ForwardBase"}
			//关闭深度写入,让透明物体片元背后的片元也能参与颜色混合
			ZWrite Off
			//设置颜色混合模式DstColor_new = SrcColor.a * SrcColor.rgb + (1 - SrcColor.a) * DstColor_old.rgb 
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				//设置片元着色器返回值中的透明通道,必须使用Blend命令打开混合后,此处设置透明度通道才有意义,否则不会产生影响
				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}

			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}