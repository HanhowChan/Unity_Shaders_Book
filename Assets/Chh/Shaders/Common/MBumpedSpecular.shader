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

    
            ENDCG
        }
    }
    FallBack "Specular"
}
