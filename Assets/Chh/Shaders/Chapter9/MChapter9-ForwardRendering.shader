Shader "Custom/MChapter9-ForwardRendering"
{
    Properties
    {

    }

    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            // Apparently need to add this declaration
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            
            struct a2v
            {
                pos:POSITION;
                normal:NORMAL;
                uv:TEXCOORD0;
            };

            struct v2f
            {

            };

            v2f vert(a2v v)
            {
                
            }

            fixed4 frag(v2f i)
            {

                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
                // Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, worldLightDir)), _Gloss);
                // The attenuation of directional light is always 1
                fixed atten = 1.0;
                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }

        Pass
        {
            // Pass for other pixel lights
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            // Apparently need to add this declaration
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            struct a2v
            {
                
            };

            struct v2f
            {
                worldPosition
            };

            v2f vert(a2v v)
            {

            }

            fixed4 frag(v2f i) :SV_Target
            {
#ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPosition.xyz);
            }

            ENDCG
        }
    }
    Fallback ""
}
