Shader "URP/FoilProcedural"
{
    Properties
    {
        _Intensity     ("Intensity", Range(0, 5)) = 1
        _Speed         ("Speed", Range(0, 10)) = 1.5
        _Scale         ("Pattern Scale", Range(0.1, 20)) = 4
        _FresnelPower  ("Fresnel Power", Range(0.1, 8)) = 2.5
        _FresnelBoost  ("Fresnel Boost", Range(0, 3)) = 0.5
        _Tint          ("Overall Tint", Color) = (1,1,1,1)
        _Alpha         ("Alpha", Range(0,1)) = 1
        _SilverMode    ("Silver Only 0..1", Range(0,1)) = 0 // 0 rainbow, 1 silver
        _Cull          ("Cull 0:Off 1:Front 2:Back", Float) = 2
    }

    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        LOD 100

        Pass
        {
            Name "FoilProcedural"
            Tags{ "LightMode"="UniversalForward" }

            Blend One One
            ZWrite Off
            Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            // URP includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            // Properties
            CBUFFER_START(UnityPerMaterial)
                float _Intensity;
                float _Speed;
                float _Scale;
                float _FresnelPower;
                float _FresnelBoost;
                float4 _Tint;
                float _Alpha;
                float _SilverMode;
                float _Cull;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                float4 color      : COLOR;   // A used as mask if wanted
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float4 color       : COLOR;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS    = NormalizeNormalPerVertex(TransformObjectToWorldNormal(IN.normalOS));
                OUT.color       = IN.color;
                return OUT;
            }

            // Cheap rainbow from a single phase x using shifted sines
            float3 Rainbow(float x)
            {
                // 2*pi/3 phase shifts
                const float s = 2.09439510239;
                float r = 0.5 + 0.5 * sin(x);
                float g = 0.5 + 0.5 * sin(x + s);
                float b = 0.5 + 0.5 * sin(x + 2.0*s);
                return float3(r, g, b);
            }

            float3 Desaturate(float3 c, float amount)
            {
                float g = dot(c, float3(0.299, 0.587, 0.114));
                return lerp(c, float3(g, g, g), saturate(amount));
            }

            float3 RotateVector(float3 v, float angle)
            {
                // Rotate around Y to make bands slide sideways
                float s = sin(angle), c = cos(angle);
                float3x3 R = float3x3(
                    c, 0, -s,
                    0, 1,  0,
                    s, 0,  c
                );
                return mul(R, v);
            }

            float4 frag (Varyings IN) : SV_Target
            {
                // View dir
                float3 V = normalize(GetWorldSpaceViewDir(IN.positionWS));
                float3 N = normalize(IN.normalWS);

                // Fresnel
                float fres = pow(saturate(1.0 - dot(N, V)), _FresnelPower);
                fres = saturate(fres * (1.0 + _FresnelBoost));

                // Animated directional projection to make bands move
                float t = _Time.y * _Speed;
                float3 dir = RotateVector(float3(0.7, 0.3, 0.6), t * 0.75);
                float phase = dot(IN.positionWS, dir) * _Scale + t * 2.0;

                // Rainbow bands
                float3 rgb = Rainbow(phase);

                // Optional silver mode
                rgb = Desaturate(rgb, _SilverMode);

                // Extra sparkle by modulating with a high frequency ripple
                float ripple = 0.5 + 0.5 * sin(phase * 3.1);
                rgb *= lerp(0.7, 1.3, ripple);

                // Mix with Fresnel and tint
                float3 color = rgb * fres * _Intensity * _Tint.rgb;

                // Vertex color alpha can mask the foil if you paint it. If not, it will be 1.
                float maskA = IN.color.a;

                return float4(color, _Alpha * maskA);
            }
            ENDHLSL
        }
    }

    FallBack Off
}
