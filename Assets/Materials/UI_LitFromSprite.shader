Shader "UI/LitFromSprite_URP"
{
    Properties
    {
        _Color ("Tint", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.4
        _LightWrap ("Light Wrap", Range(0, 1)) = 0.5
        _MinLighting ("Min Lighting", Range(0, 1)) = 0.3
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderPipeline"="UniversalRenderPipeline"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            // URP includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Sprite texture comes from Image.sprite automatically as _MainTex
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _Color;
            float _AmbientStrength;
            float _LightWrap;
            float _MinLighting;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;   // enable Normals in Canvas Additional Shader Channels
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float3 nWS : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv  = v.uv;
                o.nWS = normalize(TransformObjectToWorldNormal(v.normal));
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                if (tex.a <= 0.001h) discard;

                // Main directional light with softer falloff
                Light mainLight = GetMainLight();
                float3 L = normalize(mainLight.direction);
                
                // Wrapped lighting for softer shadows
                float NdotL = dot(i.nWS, L);
                float wrappedNdotL = (NdotL + _LightWrap) / (1.0 + _LightWrap);
                wrappedNdotL = saturate(wrappedNdotL);
                
                // Ensure minimum lighting level
                float lightIntensity = max(wrappedNdotL, _MinLighting);

                // Add ambient lighting
                float3 ambient = _AmbientStrength * unity_AmbientSky.rgb;
                
                float3 lit = tex.rgb * _Color.rgb * (mainLight.color * lightIntensity + ambient);
                return half4(lit, tex.a * _Color.a);
            }
            ENDHLSL
        }
    }
}