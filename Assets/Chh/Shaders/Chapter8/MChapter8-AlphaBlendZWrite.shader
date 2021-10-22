// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/MChapter8-AlphaBlend"
{
	Properties
	{
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1	//_AlphaScale用于在透明纹理的基础上控制政体的透明度
	}

	SubShader
	{
		/*将Queue标签设置为Transparent,设置渲染队列为透明度混合使用的Transparent队列;
		* 设置IgnoreProjector标签为True,使该Shader不会受到投影器(Projectors)的影响;
		* RenderType标签设置为Transparent,让Unity把这个Shader归入到提前定义的组,用来指明该Shader是一个使用了透明度混合的Shader;
		*/
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		/*
		增加一个Pass将模型的深度信息写入深度缓冲中
		*/
		Pass
		{
			ZWrite On		//开启深度写入
			ColorMask 0	//设置颜色通道的写掩码,ColorMask RGB | A | 0 | Combination of {R G B A};ColorMask为0时,意味着该Pass不写入任何颜色通道,不会输出任何颜色
		}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}	//设置LightMode标签为ForwardBase让Unity能够按前向渲染路径的方式为我们正确提供各个光照变量
			ZWrite Off	//关闭深度写入
			BlendOp Add	//设置混合操作,默认的混合操作就是Add,此时可省略
			/*Add: 混合后源颜色加上混合后目标颜色相加
			* Sub: 混合后源颜色减去混合后的目标颜色
			* RevSub: 混合后目标颜色减去混合后源颜色
			* Min: 使用源颜色和目标颜色中较小的值,逐分量比较(此时混合因子不生效,因为仅使用原始的源颜色和目标颜色之间的比较结果)
			* Max: 使用源颜色和目标颜色中较大的值,逐分量比较(此时混合因子不生效,因为仅使用原始的源颜色和目标颜色之间的比较结果)
			*/
			Blend SrcAlpha OneMinusSrcAlpha	//设置混合模式(同时打开了颜色混合)
			/*混合计算公式:
			* O_rgb= SrcFactor * S_rgb + DstFactor * D_rgb
			* O_a = SrcFactorA * S_a + DstFactorA * D_a
			*混合命令:
			* 1. Blend SrcFactor DstFactor(此时SrcFactorA = SrcFactor, DstFactorA = DstFactor)
			* 2. Blend SrcFactor DstFactor, SrcFactorA DstFactorA
			*/

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