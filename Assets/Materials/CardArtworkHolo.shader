Shader "Shader Graphs/CardArtworkHolo"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0
        [NoScaleOffset]_Heightmap("Heightmap", 2D) = "black" {}
        _Heightmap_Strength("Heightmap Strength", Range(0, 1)) = 0.5
        [HDR]_Holo_Color("Holo Color", Color) = (1, 1, 1, 0)
        [Toggle(_USE_COLOR_RAMP)]_USE_COLOR_RAMP("Use Color Ramp", Float) = 0
        [NoScaleOffset]_Holo_Color_Ramp("Holo Color Ramp", 2D) = "white" {}
        _Holo_Noise_Scale("Holo Noise Scale", Range(0, 250)) = 10
        _Holo_Anim_Speed("Holo Anim Speed", Range(0, 1)) = 0
        _Holo_Mask("Holo Mask", 2D) = "white" {}
        _Holo_Direction("Holo Direction", Vector, 2) = (1, 0, 0, 0)
        _Holo_Density("Holo Density", Range(0.1, 15)) = 5
        _Holo_Rotation_Scroll_Speed("Holo Rotation Scroll Speed", Range(0, 30)) = 10
        _Holo_Offset("Holo Offset", Range(0, 1)) = 0
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 0
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_ViewVectorTangent_float(out float3 Out, float3 WorldSpacePosition, float3 WorldSpaceTangent, float3 WorldSpaceBitangent, float3 WorldSpaceNormal)
        {
            float3x3 basisTransform = float3x3(WorldSpaceTangent, WorldSpaceBitangent, WorldSpaceNormal);
            Out = _WorldSpaceCameraPos.xyz - GetAbsolutePositionWS(WorldSpacePosition);
            if(!IsPerspectiveProjection())
            {
                Out = GetViewForwardDir() * dot(Out, GetViewForwardDir());
            }
            Out = length(Out) * TransformWorldToTangent(Out, basisTransform);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
        {
            // RGB to HSV
            float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
            float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
            float D = Q.x - min(Q.w, Q.y);
            float E = 1e-10;
            float V = (D == 0) ? Q.x : (Q.x + E);
            float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
        
            float hue = hsv.x + Offset;
            hsv.x = (hue < 0)
                    ? hue + 1
                    : (hue > 1)
                        ? hue - 1
                        : hue;
        
            // HSV to RGB
            float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float4 _Property_29908339723e461897ebbb94895295e5_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Holo_Color) : _Holo_Color;
            UnityTexture2D _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Holo_Color_Ramp);
            float _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float = _Holo_Noise_Scale;
            float _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float((IN.ObjectSpacePosition.xy), _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float, _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float);
            float _Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float = _Holo_Anim_Speed;
            float _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float;
            Unity_Multiply_float_float(_Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float, IN.TimeParameters.x, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float);
            float _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float;
            Unity_Add_float(_SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float, _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float);
            float3 _ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3;
            Unity_ViewVectorTangent_float(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, IN.WorldSpacePosition, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float2 _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2 = _Holo_Direction;
            float _Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[0];
            float _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[1];
            float _Split_039ca2ad21bf440eb392307c2d70144a_B_3_Float = 0;
            float _Split_039ca2ad21bf440eb392307c2d70144a_A_4_Float = 0;
            float3 _Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3 = float3(_Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float, _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float, float(0));
            float3 _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3;
            Unity_Normalize_float3(_Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3);
            float _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float;
            Unity_DotProduct_float3(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float);
            float _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float = _Holo_Offset;
            float _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float;
            Unity_Add_float(_DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float, _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float, _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float);
            float _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float = _Holo_Density;
            float _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float;
            Unity_Multiply_float_float(_Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float, _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float, _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float);
            float _Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float = _Holo_Rotation_Scroll_Speed;
            float3 _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3;
            Unity_Subtract_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3);
            float3 _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3;
            Unity_Normalize_float3(_Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3, _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3);
            float3 _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3 = TransformWorldToTangentDir(_Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3.xyz, tangentTransform, true);
            }
            float _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float);
            float _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float;
            Unity_Multiply_float_float(_Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float);
            float _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float;
            Unity_Add_float(_Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float, _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float);
            float _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float;
            Unity_Sine_float(_Add_010574f5fffc470aa32d759419b9c967_Out_2_Float, _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float);
            float _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float;
            Unity_Saturate_float(_Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float);
            float _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float;
            Unity_Add_float(_Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float);
            float2 _Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2 = float2(_Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, float(0.5));
            float4 _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.tex, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.samplerstate, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.GetTransformedUV(_Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2) );
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_R_4_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.r;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_G_5_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.g;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_B_6_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.b;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_A_7_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.a;
            float4 Color_6f6abf83027a45238478e6fdd76f6c5e = IsGammaSpace() ? float4(1, 0, 0, 1) : float4(SRGBToLinear(float3(1, 0, 0)), 1);
            float3 _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            Unity_Hue_Normalized_float((Color_6f6abf83027a45238478e6fdd76f6c5e.xyz), _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3);
            #if defined(_USE_COLOR_RAMP)
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = (_SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.xyz);
            #else
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            #endif
            float3 _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_29908339723e461897ebbb94895295e5_Out_0_Vector4.xyz), _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3, _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3);
            UnityTexture2D _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D = UnityBuildTexture2DStruct(_Holo_Mask);
            float4 _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.tex, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.samplerstate, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.r;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_G_5_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.g;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_B_6_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.b;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_A_7_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.a;
            float _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float;
            Unity_Multiply_float_float(_Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float, _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float);
            float3 _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            Unity_Lerp_float3((_Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4.xyz), _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3, (_Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float.xxx), _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3);
            UnityTexture2D _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Heightmap);
            float4 _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.tex, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.samplerstate, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.r;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_G_5_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.g;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_B_6_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.b;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_A_7_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.a;
            float _Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float = _Heightmap_Strength;
            float _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float;
            Unity_Multiply_float_float(_Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float, 0.002, _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            float3x3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float,_Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix, _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3);
            float _Property_d5a09642715d4123bfdebcaed03b0bc6_Out_0_Float = _Smoothness;
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.BaseColor = _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            surface.NormalTS = _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = _Property_d5a09642715d4123bfdebcaed03b0bc6_Out_0_Float;
            surface.Occlusion = float(1);
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_ViewVectorTangent_float(out float3 Out, float3 WorldSpacePosition, float3 WorldSpaceTangent, float3 WorldSpaceBitangent, float3 WorldSpaceNormal)
        {
            float3x3 basisTransform = float3x3(WorldSpaceTangent, WorldSpaceBitangent, WorldSpaceNormal);
            Out = _WorldSpaceCameraPos.xyz - GetAbsolutePositionWS(WorldSpacePosition);
            if(!IsPerspectiveProjection())
            {
                Out = GetViewForwardDir() * dot(Out, GetViewForwardDir());
            }
            Out = length(Out) * TransformWorldToTangent(Out, basisTransform);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
        {
            // RGB to HSV
            float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
            float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
            float D = Q.x - min(Q.w, Q.y);
            float E = 1e-10;
            float V = (D == 0) ? Q.x : (Q.x + E);
            float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
        
            float hue = hsv.x + Offset;
            hsv.x = (hue < 0)
                    ? hue + 1
                    : (hue > 1)
                        ? hue - 1
                        : hue;
        
            // HSV to RGB
            float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float4 _Property_29908339723e461897ebbb94895295e5_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Holo_Color) : _Holo_Color;
            UnityTexture2D _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Holo_Color_Ramp);
            float _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float = _Holo_Noise_Scale;
            float _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float((IN.ObjectSpacePosition.xy), _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float, _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float);
            float _Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float = _Holo_Anim_Speed;
            float _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float;
            Unity_Multiply_float_float(_Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float, IN.TimeParameters.x, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float);
            float _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float;
            Unity_Add_float(_SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float, _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float);
            float3 _ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3;
            Unity_ViewVectorTangent_float(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, IN.WorldSpacePosition, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float2 _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2 = _Holo_Direction;
            float _Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[0];
            float _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[1];
            float _Split_039ca2ad21bf440eb392307c2d70144a_B_3_Float = 0;
            float _Split_039ca2ad21bf440eb392307c2d70144a_A_4_Float = 0;
            float3 _Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3 = float3(_Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float, _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float, float(0));
            float3 _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3;
            Unity_Normalize_float3(_Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3);
            float _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float;
            Unity_DotProduct_float3(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float);
            float _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float = _Holo_Offset;
            float _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float;
            Unity_Add_float(_DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float, _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float, _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float);
            float _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float = _Holo_Density;
            float _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float;
            Unity_Multiply_float_float(_Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float, _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float, _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float);
            float _Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float = _Holo_Rotation_Scroll_Speed;
            float3 _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3;
            Unity_Subtract_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3);
            float3 _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3;
            Unity_Normalize_float3(_Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3, _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3);
            float3 _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3 = TransformWorldToTangentDir(_Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3.xyz, tangentTransform, true);
            }
            float _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float);
            float _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float;
            Unity_Multiply_float_float(_Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float);
            float _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float;
            Unity_Add_float(_Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float, _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float);
            float _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float;
            Unity_Sine_float(_Add_010574f5fffc470aa32d759419b9c967_Out_2_Float, _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float);
            float _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float;
            Unity_Saturate_float(_Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float);
            float _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float;
            Unity_Add_float(_Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float);
            float2 _Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2 = float2(_Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, float(0.5));
            float4 _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.tex, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.samplerstate, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.GetTransformedUV(_Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2) );
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_R_4_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.r;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_G_5_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.g;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_B_6_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.b;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_A_7_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.a;
            float4 Color_6f6abf83027a45238478e6fdd76f6c5e = IsGammaSpace() ? float4(1, 0, 0, 1) : float4(SRGBToLinear(float3(1, 0, 0)), 1);
            float3 _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            Unity_Hue_Normalized_float((Color_6f6abf83027a45238478e6fdd76f6c5e.xyz), _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3);
            #if defined(_USE_COLOR_RAMP)
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = (_SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.xyz);
            #else
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            #endif
            float3 _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_29908339723e461897ebbb94895295e5_Out_0_Vector4.xyz), _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3, _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3);
            UnityTexture2D _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D = UnityBuildTexture2DStruct(_Holo_Mask);
            float4 _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.tex, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.samplerstate, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.r;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_G_5_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.g;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_B_6_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.b;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_A_7_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.a;
            float _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float;
            Unity_Multiply_float_float(_Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float, _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float);
            float3 _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            Unity_Lerp_float3((_Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4.xyz), _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3, (_Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float.xxx), _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3);
            UnityTexture2D _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Heightmap);
            float4 _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.tex, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.samplerstate, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.r;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_G_5_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.g;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_B_6_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.b;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_A_7_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.a;
            float _Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float = _Heightmap_Strength;
            float _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float;
            Unity_Multiply_float_float(_Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float, 0.002, _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            float3x3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float,_Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix, _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3);
            float _Property_d5a09642715d4123bfdebcaed03b0bc6_Out_0_Float = _Smoothness;
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.BaseColor = _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            surface.NormalTS = _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = _Property_d5a09642715d4123bfdebcaed03b0bc6_Out_0_Float;
            surface.Occlusion = float(1);
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Heightmap);
            float4 _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.tex, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.samplerstate, _Property_dc9b460d009a4890934c1e3bb1e15faa_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.r;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_G_5_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.g;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_B_6_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.b;
            float _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_A_7_Float = _SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_RGBA_0_Vector4.a;
            float _Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float = _Heightmap_Strength;
            float _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float;
            Unity_Multiply_float_float(_Property_9a8e65c7f8e14816b12a7c52affdbe2f_Out_0_Float, 0.002, _Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            float3x3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_SampleTexture2D_36b9526f927b43ce8fcd5adb7be3a5bb_R_4_Float,_Multiply_13b8949c25b940629252cc1d2ed07922_Out_2_Float,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Position,_NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_TangentMatrix, _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3);
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.NormalTS = _NormalFromHeight_fdd0e59bf88c4ced915a3514c473d58a_Out_1_Vector3;
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float4 texCoord1 : INTERP2;
             float4 texCoord2 : INTERP3;
             float3 positionWS : INTERP4;
             float3 normalWS : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_ViewVectorTangent_float(out float3 Out, float3 WorldSpacePosition, float3 WorldSpaceTangent, float3 WorldSpaceBitangent, float3 WorldSpaceNormal)
        {
            float3x3 basisTransform = float3x3(WorldSpaceTangent, WorldSpaceBitangent, WorldSpaceNormal);
            Out = _WorldSpaceCameraPos.xyz - GetAbsolutePositionWS(WorldSpacePosition);
            if(!IsPerspectiveProjection())
            {
                Out = GetViewForwardDir() * dot(Out, GetViewForwardDir());
            }
            Out = length(Out) * TransformWorldToTangent(Out, basisTransform);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
        {
            // RGB to HSV
            float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
            float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
            float D = Q.x - min(Q.w, Q.y);
            float E = 1e-10;
            float V = (D == 0) ? Q.x : (Q.x + E);
            float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
        
            float hue = hsv.x + Offset;
            hsv.x = (hue < 0)
                    ? hue + 1
                    : (hue > 1)
                        ? hue - 1
                        : hue;
        
            // HSV to RGB
            float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float4 _Property_29908339723e461897ebbb94895295e5_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Holo_Color) : _Holo_Color;
            UnityTexture2D _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Holo_Color_Ramp);
            float _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float = _Holo_Noise_Scale;
            float _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float((IN.ObjectSpacePosition.xy), _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float, _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float);
            float _Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float = _Holo_Anim_Speed;
            float _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float;
            Unity_Multiply_float_float(_Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float, IN.TimeParameters.x, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float);
            float _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float;
            Unity_Add_float(_SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float, _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float);
            float3 _ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3;
            Unity_ViewVectorTangent_float(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, IN.WorldSpacePosition, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float2 _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2 = _Holo_Direction;
            float _Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[0];
            float _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[1];
            float _Split_039ca2ad21bf440eb392307c2d70144a_B_3_Float = 0;
            float _Split_039ca2ad21bf440eb392307c2d70144a_A_4_Float = 0;
            float3 _Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3 = float3(_Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float, _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float, float(0));
            float3 _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3;
            Unity_Normalize_float3(_Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3);
            float _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float;
            Unity_DotProduct_float3(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float);
            float _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float = _Holo_Offset;
            float _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float;
            Unity_Add_float(_DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float, _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float, _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float);
            float _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float = _Holo_Density;
            float _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float;
            Unity_Multiply_float_float(_Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float, _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float, _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float);
            float _Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float = _Holo_Rotation_Scroll_Speed;
            float3 _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3;
            Unity_Subtract_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3);
            float3 _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3;
            Unity_Normalize_float3(_Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3, _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3);
            float3 _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3 = TransformWorldToTangentDir(_Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3.xyz, tangentTransform, true);
            }
            float _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float);
            float _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float;
            Unity_Multiply_float_float(_Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float);
            float _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float;
            Unity_Add_float(_Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float, _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float);
            float _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float;
            Unity_Sine_float(_Add_010574f5fffc470aa32d759419b9c967_Out_2_Float, _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float);
            float _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float;
            Unity_Saturate_float(_Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float);
            float _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float;
            Unity_Add_float(_Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float);
            float2 _Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2 = float2(_Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, float(0.5));
            float4 _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.tex, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.samplerstate, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.GetTransformedUV(_Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2) );
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_R_4_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.r;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_G_5_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.g;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_B_6_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.b;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_A_7_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.a;
            float4 Color_6f6abf83027a45238478e6fdd76f6c5e = IsGammaSpace() ? float4(1, 0, 0, 1) : float4(SRGBToLinear(float3(1, 0, 0)), 1);
            float3 _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            Unity_Hue_Normalized_float((Color_6f6abf83027a45238478e6fdd76f6c5e.xyz), _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3);
            #if defined(_USE_COLOR_RAMP)
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = (_SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.xyz);
            #else
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            #endif
            float3 _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_29908339723e461897ebbb94895295e5_Out_0_Vector4.xyz), _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3, _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3);
            UnityTexture2D _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D = UnityBuildTexture2DStruct(_Holo_Mask);
            float4 _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.tex, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.samplerstate, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.r;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_G_5_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.g;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_B_6_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.b;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_A_7_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.a;
            float _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float;
            Unity_Multiply_float_float(_Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float, _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float);
            float3 _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            Unity_Lerp_float3((_Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4.xyz), _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3, (_Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float.xxx), _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.BaseColor = _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_ViewVectorTangent_float(out float3 Out, float3 WorldSpacePosition, float3 WorldSpaceTangent, float3 WorldSpaceBitangent, float3 WorldSpaceNormal)
        {
            float3x3 basisTransform = float3x3(WorldSpaceTangent, WorldSpaceBitangent, WorldSpaceNormal);
            Out = _WorldSpaceCameraPos.xyz - GetAbsolutePositionWS(WorldSpacePosition);
            if(!IsPerspectiveProjection())
            {
                Out = GetViewForwardDir() * dot(Out, GetViewForwardDir());
            }
            Out = length(Out) * TransformWorldToTangent(Out, basisTransform);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
        {
            // RGB to HSV
            float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
            float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
            float D = Q.x - min(Q.w, Q.y);
            float E = 1e-10;
            float V = (D == 0) ? Q.x : (Q.x + E);
            float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
        
            float hue = hsv.x + Offset;
            hsv.x = (hue < 0)
                    ? hue + 1
                    : (hue > 1)
                        ? hue - 1
                        : hue;
        
            // HSV to RGB
            float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float4 _Property_29908339723e461897ebbb94895295e5_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Holo_Color) : _Holo_Color;
            UnityTexture2D _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Holo_Color_Ramp);
            float _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float = _Holo_Noise_Scale;
            float _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float((IN.ObjectSpacePosition.xy), _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float, _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float);
            float _Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float = _Holo_Anim_Speed;
            float _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float;
            Unity_Multiply_float_float(_Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float, IN.TimeParameters.x, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float);
            float _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float;
            Unity_Add_float(_SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float, _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float);
            float3 _ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3;
            Unity_ViewVectorTangent_float(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, IN.WorldSpacePosition, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float2 _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2 = _Holo_Direction;
            float _Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[0];
            float _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[1];
            float _Split_039ca2ad21bf440eb392307c2d70144a_B_3_Float = 0;
            float _Split_039ca2ad21bf440eb392307c2d70144a_A_4_Float = 0;
            float3 _Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3 = float3(_Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float, _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float, float(0));
            float3 _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3;
            Unity_Normalize_float3(_Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3);
            float _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float;
            Unity_DotProduct_float3(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float);
            float _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float = _Holo_Offset;
            float _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float;
            Unity_Add_float(_DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float, _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float, _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float);
            float _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float = _Holo_Density;
            float _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float;
            Unity_Multiply_float_float(_Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float, _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float, _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float);
            float _Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float = _Holo_Rotation_Scroll_Speed;
            float3 _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3;
            Unity_Subtract_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3);
            float3 _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3;
            Unity_Normalize_float3(_Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3, _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3);
            float3 _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3 = TransformWorldToTangentDir(_Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3.xyz, tangentTransform, true);
            }
            float _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float);
            float _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float;
            Unity_Multiply_float_float(_Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float);
            float _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float;
            Unity_Add_float(_Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float, _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float);
            float _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float;
            Unity_Sine_float(_Add_010574f5fffc470aa32d759419b9c967_Out_2_Float, _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float);
            float _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float;
            Unity_Saturate_float(_Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float);
            float _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float;
            Unity_Add_float(_Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float);
            float2 _Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2 = float2(_Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, float(0.5));
            float4 _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.tex, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.samplerstate, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.GetTransformedUV(_Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2) );
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_R_4_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.r;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_G_5_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.g;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_B_6_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.b;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_A_7_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.a;
            float4 Color_6f6abf83027a45238478e6fdd76f6c5e = IsGammaSpace() ? float4(1, 0, 0, 1) : float4(SRGBToLinear(float3(1, 0, 0)), 1);
            float3 _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            Unity_Hue_Normalized_float((Color_6f6abf83027a45238478e6fdd76f6c5e.xyz), _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3);
            #if defined(_USE_COLOR_RAMP)
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = (_SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.xyz);
            #else
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            #endif
            float3 _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_29908339723e461897ebbb94895295e5_Out_0_Vector4.xyz), _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3, _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3);
            UnityTexture2D _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D = UnityBuildTexture2DStruct(_Holo_Mask);
            float4 _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.tex, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.samplerstate, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.r;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_G_5_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.g;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_B_6_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.b;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_A_7_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.a;
            float _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float;
            Unity_Multiply_float_float(_Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float, _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float);
            float3 _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            Unity_Lerp_float3((_Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4.xyz), _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3, (_Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float.xxx), _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.BaseColor = _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ _USE_COLOR_RAMP
        
        #if defined(_USE_COLOR_RAMP)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float _Smoothness;
        float4 _Holo_Mask_TexelSize;
        float4 _Holo_Mask_ST;
        float _Holo_Anim_Speed;
        float _Holo_Density;
        float4 _Holo_Color;
        float4 _Holo_Color_Ramp_TexelSize;
        float4 _Heightmap_TexelSize;
        float _Heightmap_Strength;
        float _Holo_Rotation_Scroll_Speed;
        float _Holo_Noise_Scale;
        float _Holo_Offset;
        float2 _Holo_Direction;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Holo_Mask);
        SAMPLER(sampler_Holo_Mask);
        TEXTURE2D(_Holo_Color_Ramp);
        SAMPLER(sampler_Holo_Color_Ramp);
        TEXTURE2D(_Heightmap);
        SAMPLER(sampler_Heightmap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_ViewVectorTangent_float(out float3 Out, float3 WorldSpacePosition, float3 WorldSpaceTangent, float3 WorldSpaceBitangent, float3 WorldSpaceNormal)
        {
            float3x3 basisTransform = float3x3(WorldSpaceTangent, WorldSpaceBitangent, WorldSpaceNormal);
            Out = _WorldSpaceCameraPos.xyz - GetAbsolutePositionWS(WorldSpacePosition);
            if(!IsPerspectiveProjection())
            {
                Out = GetViewForwardDir() * dot(Out, GetViewForwardDir());
            }
            Out = length(Out) * TransformWorldToTangent(Out, basisTransform);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
        {
            // RGB to HSV
            float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
            float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
            float D = Q.x - min(Q.w, Q.y);
            float E = 1e-10;
            float V = (D == 0) ? Q.x : (Q.x + E);
            float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
        
            float hue = hsv.x + Offset;
            hsv.x = (hue < 0)
                    ? hue + 1
                    : (hue > 1)
                        ? hue - 1
                        : hue;
        
            // HSV to RGB
            float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.tex, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.samplerstate, _Property_2074fa72a40d4a73865dc75e043bb2c3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_R_4_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.r;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_G_5_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.g;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_B_6_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.b;
            float _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_A_7_Float = _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4.a;
            float4 _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3c01db2f122f46a8b6dd8ebde45c8e25_Out_0_Vector4, _SampleTexture2D_2252654c48cd4c89b2ff3e859a44acf7_RGBA_0_Vector4, _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4);
            float4 _Property_29908339723e461897ebbb94895295e5_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Holo_Color) : _Holo_Color;
            UnityTexture2D _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Holo_Color_Ramp);
            float _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float = _Holo_Noise_Scale;
            float _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float((IN.ObjectSpacePosition.xy), _Property_f38d30f9b36040059ebeff27887527ba_Out_0_Float, _SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float);
            float _Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float = _Holo_Anim_Speed;
            float _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float;
            Unity_Multiply_float_float(_Property_cc2445f7cc3d414eb33032fe15b46e97_Out_0_Float, IN.TimeParameters.x, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float);
            float _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float;
            Unity_Add_float(_SimpleNoise_f5cb03e85d964465857535953eceeb2b_Out_2_Float, _Multiply_d96818c9bf49403da07030bb17467b8d_Out_2_Float, _Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float);
            float3 _ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3;
            Unity_ViewVectorTangent_float(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, IN.WorldSpacePosition, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float2 _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2 = _Holo_Direction;
            float _Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[0];
            float _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float = _Property_c49f73f85e274e10aede07602e36b461_Out_0_Vector2[1];
            float _Split_039ca2ad21bf440eb392307c2d70144a_B_3_Float = 0;
            float _Split_039ca2ad21bf440eb392307c2d70144a_A_4_Float = 0;
            float3 _Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3 = float3(_Split_039ca2ad21bf440eb392307c2d70144a_R_1_Float, _Split_039ca2ad21bf440eb392307c2d70144a_G_2_Float, float(0));
            float3 _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3;
            Unity_Normalize_float3(_Vector3_3b85848b9dba4054b6b5e34614d880cf_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3);
            float _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float;
            Unity_DotProduct_float3(_ViewVector_9aacb8e07e5747158757dca1cf8b792c_Out_0_Vector3, _Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float);
            float _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float = _Holo_Offset;
            float _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float;
            Unity_Add_float(_DotProduct_4a88d066ea9543d28f4b0c814201233a_Out_2_Float, _Property_33a0485e634146e686204ec638d2ad36_Out_0_Float, _Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float);
            float _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float = _Holo_Density;
            float _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float;
            Unity_Multiply_float_float(_Add_49a9fdcd4b6e4cadba6e1867b7140e53_Out_2_Float, _Property_5d5c472f1ad84640b19769b46260446b_Out_0_Float, _Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float);
            float _Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float = _Holo_Rotation_Scroll_Speed;
            float3 _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3;
            Unity_Subtract_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3);
            float3 _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3;
            Unity_Normalize_float3(_Subtract_6361d093372f476fa50d798a1dbe295c_Out_2_Vector3, _Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3);
            float3 _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3 = TransformWorldToTangentDir(_Normalize_0f3ed533ba49476c88301cf4b3afb047_Out_1_Vector3.xyz, tangentTransform, true);
            }
            float _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_4b01960172dc46e0b344d5a7df5f1d62_Out_1_Vector3, _Transform_85446a1f096a4940a668be4e4e5c6f66_Out_1_Vector3, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float);
            float _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float;
            Unity_Multiply_float_float(_Property_9d507f3eb04d450e8e0a22d00e3df94a_Out_0_Float, _DotProduct_ea7cc0f34d9e488f8face943d48167a3_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float);
            float _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float;
            Unity_Add_float(_Multiply_0215a8e040964589a9f541ab3a185605_Out_2_Float, _Multiply_99fa5d7e2b0b463f95f7313575b3022d_Out_2_Float, _Add_010574f5fffc470aa32d759419b9c967_Out_2_Float);
            float _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float;
            Unity_Sine_float(_Add_010574f5fffc470aa32d759419b9c967_Out_2_Float, _Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float);
            float _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float;
            Unity_Saturate_float(_Sine_4b4afe60cb2a481c9d60c7a9e5e3f801_Out_1_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float);
            float _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float;
            Unity_Add_float(_Add_dda6390d6a574030ae8554abe51c17e9_Out_2_Float, _Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float);
            float2 _Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2 = float2(_Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, float(0.5));
            float4 _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.tex, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.samplerstate, _Property_e4de1fd27c854f6fa5888e0a0ed61d91_Out_0_Texture2D.GetTransformedUV(_Vector2_228666f8029e42cb80476e18605ccb28_Out_0_Vector2) );
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_R_4_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.r;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_G_5_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.g;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_B_6_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.b;
            float _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_A_7_Float = _SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.a;
            float4 Color_6f6abf83027a45238478e6fdd76f6c5e = IsGammaSpace() ? float4(1, 0, 0, 1) : float4(SRGBToLinear(float3(1, 0, 0)), 1);
            float3 _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            Unity_Hue_Normalized_float((Color_6f6abf83027a45238478e6fdd76f6c5e.xyz), _Add_b48fde99011c461f89e72f8623a0db9b_Out_2_Float, _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3);
            #if defined(_USE_COLOR_RAMP)
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = (_SampleTexture2D_e953d49ab6f344adaac9bda2835c0cbf_RGBA_0_Vector4.xyz);
            #else
            float3 _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3 = _Hue_64860b285d2c4aca8e0a09ea90ab7c99_Out_2_Vector3;
            #endif
            float3 _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_29908339723e461897ebbb94895295e5_Out_0_Vector4.xyz), _UseColorRamp_7e5315ff106d4ab7abd10fec4275de94_Out_0_Vector3, _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3);
            UnityTexture2D _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D = UnityBuildTexture2DStruct(_Holo_Mask);
            float4 _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.tex, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.samplerstate, _Property_6720ccc5ca5c47af8eaea431937f515b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.r;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_G_5_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.g;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_B_6_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.b;
            float _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_A_7_Float = _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_RGBA_0_Vector4.a;
            float _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float;
            Unity_Multiply_float_float(_Saturate_56b33f3a498d41a28a84221f7508ab83_Out_1_Float, _SampleTexture2D_6bef16632254408b995ebfb580d3bde7_R_4_Float, _Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float);
            float3 _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            Unity_Lerp_float3((_Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4.xyz), _Multiply_6939e6fd2198448e856320d191c13517_Out_2_Vector3, (_Multiply_115e1dba5baf46e38bfb202a3cbbcaf8_Out_2_Float.xxx), _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3);
            float _Split_f577539ea5374fa28c60130ee84b516b_R_1_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[0];
            float _Split_f577539ea5374fa28c60130ee84b516b_G_2_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[1];
            float _Split_f577539ea5374fa28c60130ee84b516b_B_3_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[2];
            float _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float = _Multiply_437591cfbda5465fbe87bbe35f62b9e1_Out_2_Vector4[3];
            surface.BaseColor = _Lerp_92b6245816e84f5693787944e2f783d7_Out_3_Vector3;
            surface.Alpha = _Split_f577539ea5374fa28c60130ee84b516b_A_4_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}