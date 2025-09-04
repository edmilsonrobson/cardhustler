Shader "UI/FoilUI_URP"
{
    Properties
    {
        _Color         ("Tint", Color) = (1,1,1,1)
        _FoilIntensity ("Foil Intensity", Range(0,2)) = 0.5
        _FoilSpeed     ("Foil Scroll Speed", Vector) = (0.12, 0.08, 0, 0)
        _FoilScale     ("Foil Scale", Float) = 1.8
        _FoilContrast  ("Foil Contrast", Range(0,4)) = 1.0
        _FoilSoftness  ("Foil Softness", Range(0,1)) = 0.35
        _Ambient       ("Ambient Boost", Range(0,1)) = 0.15
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "RenderPipeline"="UniversalPipeline"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target   3.0

            // Enable additional lights if Pipeline Asset has them on
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Sprite from UI.Image arrives as _MainTex automatically
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _Color;
            float  _FoilIntensity;
            float2 _FoilSpeed;
            float  _FoilScale;
            float  _FoilContrast;
            float  _FoilSoftness;
            float  _Ambient;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;   // enable 'Normals' in Canvas Additional Shader Channels
            };

            struct v2f
            {
                float4 pos   : SV_POSITION;
                float2 uv    : TEXCOORD0;
                float3 nWS   : TEXCOORD1;
                float3 posWS : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos   = TransformObjectToHClip(v.vertex.xyz);
                o.uv    = v.uv;
                o.nWS   = normalize(TransformObjectToWorldNormal(v.normal));
                o.posWS = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            // smooth rainbow bands
            float3 rainbow(float t)
            {
                float r = saturate(abs(t * 6 - 3) - 1);
                float g = saturate(2 - abs(t * 6 - 2));
                float b = saturate(2 - abs(t * 6 - 4));
                return float3(r, g, b);
            }

            // blue-ish value noise (smooth, low crawl)
            float2 hash2(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p) * 43758.5453);
            }

            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3 - 2 * f);
                float a = dot(hash2(i + float2(0,0)), 1.xx);
                float b = dot(hash2(i + float2(1,0)), 1.xx);
                float c = dot(hash2(i + float2(0,1)), 1.xx);
                float d = dot(hash2(i + float2(1,1)), 1.xx);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float fbm(float2 p)
            {
                float sum = 0.0;
                float amp = 0.5;
                [unroll] for (int k = 0; k < 4; ++k)
                {
                    sum += valueNoise(p) * amp;
                    p *= 2.0;
                    amp *= 0.5;
                }
                return sum;
            }

            // accumulate simple lambert lighting from URP main + additional lights
            float3 AccumulateLighting(float3 nWS, float3 posWS)
            {
                // main directional
                Light mainL = GetMainLight(); // no shadows on UI
                float3 L0 = normalize(-mainL.direction); // dir from surface to light
                float  NdotL0 = saturate(dot(nWS, L0));
                float3 lit = mainL.color * NdotL0;

                // additional lights (point/spot)
                #if defined(_ADDITIONAL_LIGHTS)
                uint count = GetAdditionalLightsCount();
                [loop] for (uint li = 0u; li < count; ++li)
                {
                    Light l = GetAdditionalLight(li, posWS);
                    float3 L = normalize(l.direction);
                    float  NdotL = saturate(dot(nWS, L));
                    lit += l.color * NdotL * l.distanceAttenuation * l.shadowAttenuation;
                }
                #endif

                return lit;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 baseCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                if (baseCol.a <= 0.001h) discard;

                // lighting
                float3 n = normalize(i.nWS);
                float3 lambert = AccumulateLighting(n, i.posWS);

                // foil layer (smooth, animated)
                float2 uv = i.uv * _FoilScale + _Time.y * _FoilSpeed;
                float band = frac(uv.x * 0.35 + uv.y * 0.35);
                float nsm  = fbm(uv * 4.0);
                float m    = pow(saturate(nsm), _FoilContrast);
                m          = smoothstep(_FoilSoftness, 1.0, m);
                float3 foilCol = rainbow(band) * m * _FoilIntensity;

                // combine
                float3 ambient = baseCol.rgb * _Ambient;
                float3 litBase = baseCol.rgb * (lambert + ambient);
                float3 outRgb  = litBase + foilCol; // add foil on top

                return half4(outRgb * _Color.rgb, baseCol.a * _Color.a);
            }
            ENDHLSL
        }
    }
}
