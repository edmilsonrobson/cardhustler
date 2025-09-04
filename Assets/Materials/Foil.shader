Shader "Custom/FoilCard_URP"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _Color ("Base Tint", Color) = (1,1,1,1)
        
        [Header(Foil Detection)]
        [Enum(Luminance,0,Alpha,1,Red Channel,2,Green Channel,3,Blue Channel,4)] _FoilSource ("Foil Source", Float) = 0
        _FoilThreshold ("Foil Threshold", Range(0, 1)) = 0.5
        _FoilSmoothness ("Foil Edge Smoothness", Range(0, 0.5)) = 0.1
        
        [Header(Foil Effect)]
        _FoilIntensity ("Foil Intensity", Range(0, 3)) = 1.5
        _FoilScale ("Foil Scale", Range(0.1, 5)) = 1.0
        _FoilSpeed ("Foil Speed", Range(0, 5)) = 1.0
        _FoilContrast ("Foil Contrast", Range(1, 10)) = 3.0
        
        [Header(Rainbow Colors)]
        _RainbowSaturation ("Rainbow Saturation", Range(0, 2)) = 1.2
        _RainbowBrightness ("Rainbow Brightness", Range(0, 2)) = 1.5
        
        [Header(Shimmer)]
        _ShimmerSpeed ("Shimmer Speed", Range(0, 10)) = 2.0
        _ShimmerWidth ("Shimmer Width", Range(0.01, 0.5)) = 0.1
        _ShimmerIntensity ("Shimmer Intensity", Range(0, 3)) = 1.5
        
        [Header(Viewing Angle)]
        _FresnelPower ("Fresnel Power", Range(0.1, 5)) = 2.0
        _ViewAngleEffect ("View Angle Effect", Range(0, 1)) = 0.8
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalRenderPipeline"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float _FoilSource;
                float _FoilThreshold;
                float _FoilSmoothness;
                float _FoilIntensity;
                float _FoilScale;
                float _FoilSpeed;
                float _FoilContrast;
                float _RainbowSaturation;
                float _RainbowBrightness;
                float _ShimmerSpeed;
                float _ShimmerWidth;
                float _ShimmerIntensity;
                float _FresnelPower;
                float _ViewAngleEffect;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitangentWS : TEXCOORD5;
            };

            // HSV to RGB conversion
            float3 HSVtoRGB(float3 hsv)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
                return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
            }

            // Noise function for organic foil patterns
            float noise(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float smoothNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
                
                float a = noise(i);
                float b = noise(i + float2(1.0, 0.0));
                float c = noise(i + float2(0.0, 1.0));
                float d = noise(i + float2(1.0, 1.0));
                
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionHCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.normalWS = normalInput.normalWS;
                output.tangentWS = normalInput.tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Sample base texture
                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;
                
                // Determine foil mask from texture based on selected source
                float foilMask;
                if (_FoilSource == 0) // Luminance
                    foilMask = dot(baseColor.rgb, float3(0.299, 0.587, 0.114));
                else if (_FoilSource == 1) // Alpha
                    foilMask = baseColor.a;
                else if (_FoilSource == 2) // Red Channel
                    foilMask = baseColor.r;
                else if (_FoilSource == 3) // Green Channel
                    foilMask = baseColor.g;
                else // Blue Channel
                    foilMask = baseColor.b;
                
                // Apply threshold with smooth edges
                foilMask = smoothstep(_FoilThreshold - _FoilSmoothness, 
                                    _FoilThreshold + _FoilSmoothness, foilMask);
                
                // Calculate view-dependent effects
                float3 viewDir = normalize(input.viewDirWS);
                float3 normal = normalize(input.normalWS);
                float fresnel = pow(1.0 - saturate(dot(normal, viewDir)), _FresnelPower);
                
                // Create animated UV coordinates for foil pattern
                float2 foilUV = input.uv * _FoilScale;
                float time = _Time.y * _FoilSpeed;
                
                // Multi-layer noise for complex foil pattern
                float noise1 = smoothNoise(foilUV + float2(time * 0.3, time * 0.2));
                float noise2 = smoothNoise(foilUV * 2.1 + float2(-time * 0.4, time * 0.5));
                float noise3 = smoothNoise(foilUV * 4.3 + float2(time * 0.6, -time * 0.3));
                
                float combinedNoise = (noise1 + noise2 * 0.5 + noise3 * 0.25) / 1.75;
                
                // Create rainbow hue based on viewing angle and noise
                float hue = frac(combinedNoise + fresnel * _ViewAngleEffect + time * 0.1);
                
                // Enhanced contrast for more metallic look
                float foilPattern = pow(combinedNoise, _FoilContrast);
                
                // Generate rainbow colors
                float3 rainbowColor = HSVtoRGB(float3(hue, _RainbowSaturation, _RainbowBrightness));
                
                // Animated shimmer effect
                float2 shimmerUV = input.uv + float2(time * _ShimmerSpeed, 0);
                float shimmer = smoothstep(0.0, _ShimmerWidth, 
                    _ShimmerWidth - abs(frac(shimmerUV.x + shimmerUV.y) - 0.5));
                shimmer *= _ShimmerIntensity;
                
                // Combine foil effects
                float3 foilColor = rainbowColor * foilPattern + shimmer;
                foilColor *= fresnel; // More foil effect at grazing angles
                
                // Apply foil mask and intensity
                float3 finalFoil = foilColor * foilMask * _FoilIntensity;
                
                // Blend base color with foil effect (additive)
                float3 finalColor = baseColor.rgb + finalFoil;
                
                return half4(finalColor, baseColor.a);
            }
            ENDHLSL
        }
    }
}