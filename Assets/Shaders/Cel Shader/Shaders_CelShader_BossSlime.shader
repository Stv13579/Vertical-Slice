// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shaders_CelShader_BossSlime"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Diffuse_Colour("Diffuse_Colour", Color) = (1,1,1,0)
		_Spec_Smoothness("Spec_Smoothness", Range( 0 , 1)) = 0.954
		_FireVoronoiSpeed("Fire Voronoi Speed", Float) = 5
		[HDR]_Spec_Colour("Spec_Colour", Color) = (1,1,1,0)
		_FresnelScale("FresnelScale", Float) = 0.65
		_Highlight_Strenght("Highlight_Strenght", Float) = 1
		_Rim_Strenght("Rim_Strenght", Float) = 1
		_SubSurface_Stenght("SubSurface_Stenght", Range( 0 , 10)) = 10
		_SSS_Fres_Scale("SSS_Fres_Scale", Float) = 11
		_SSS_Fres_Power("SSS_Fres_Power", Float) = 3
		_FireVoronoiScale("Fire Voronoi Scale", Float) = 5
		_CrystalTextureLerpFade("Crystal Texture Lerp Fade", Range( 0 , 10)) = 2
		_FireTextureLerpFade("Fire Texture Lerp Fade", Range( 0 , 10)) = 2
		_FireRemapNews("Fire Remap News", Vector) = (-3.14,1.95,0,0)
		_Rim_Alpha("Rim_Alpha", Range( 0 , 1)) = 1
		_SubSurf_Alpha("SubSurf_Alpha", Range( 0 , 1)) = 1
		_Specular_Alpha("Specular_Alpha", Range( 0 , 1)) = 1
		_Outline_Colour("Outline_Colour", Color) = (0,0,0,0)
		_Outline_Width("Outline_Width", Range( 0 , 0.1)) = 0.01
		_Outline_Distance("Outline_Distance", Float) = 15
		_Outline_Alpha("Outline_Alpha", Range( 0 , 1)) = 1
		_Overall_Smoothness("Overall_Smoothness", Range( 0 , 1)) = 0
		_DefaultEmmisive("Default Emmisive", 2D) = "white" {}
		_DefaultSubsurfaceMulti("Default SubsurfaceMulti", 2D) = "white" {}
		_DefaultTexture("Default Texture", 2D) = "white" {}
		_CrystalEmmisive("Crystal Emmisive", 2D) = "white" {}
		_CrystalTexture("Crystal Texture", 2D) = "white" {}
		_CrystalSubsurfaceMulti("Crystal SubsurfaceMulti", 2D) = "white" {}
		_FireTexture("Fire Texture", 2D) = "white" {}
		_FireEmmisive("Fire Emmisive", 2D) = "white" {}
		_FireSubsurfaceMulti("Fire SubsurfaceMulti", 2D) = "white" {}
		_CrystalTextureLerp("Crystal Texture Lerp", Range( -1 , 1)) = 1
		_FireTextureLerp("Fire Texture Lerp", Range( -1 , 1)) = 1
		_CrystalVoronoiScale("Crystal Voronoi Scale", Float) = 0
		[ASEEnd]_CrystalVoronoiSpeed("Crystal Voronoi Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 


		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			Name "ExtraPrePass"
			
			
			Blend One Zero
			Cull Front
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_EXTRA_PREPASS

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DefaultTexture;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_DefaultTexture = v.ase_texcoord.xy * _DefaultTexture_ST.xy + _DefaultTexture_ST.zw;
				float4 tex2DNode124 = tex2Dlod( _DefaultTexture, float4( uv_DefaultTexture, 0, 0.0) );
				float Texture_Alpha101 = tex2DNode124.a;
				float4 unityObjectToClipPos104 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 Outline96 = ( v.ase_normal * _Outline_Width * Texture_Alpha101 * max( unityObjectToClipPos104.w , _Outline_Distance ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( Outline96 * _Outline_Alpha );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				
				float3 Color = _Outline_Colour.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DefaultTexture;
			sampler2D _CrystalTexture;
			sampler2D _FireTexture;
			sampler2D _DefaultSubsurfaceMulti;
			sampler2D _CrystalSubsurfaceMulti;
			sampler2D _FireSubsurfaceMulti;
			sampler2D _DefaultEmmisive;
			sampler2D _CrystalEmmisive;
			sampler2D _FireEmmisive;


			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
					float2 voronoihash183( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi183( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash183( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F2 - F1;
					}
			
					float2 voronoihash223( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi223( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash223( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float dotResult4 = dot( WorldNormal , _MainLightPosition.xyz );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_7_0 = min( saturate( dotResult4 ) , ase_lightAtten );
				float temp_output_3_0_g9 = ( temp_output_7_0 - 0.1 );
				float temp_output_9_0 = saturate( ( temp_output_3_0_g9 / fwidth( temp_output_3_0_g9 ) ) );
				float3 bakedGI13 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, WorldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, WorldNormal, bakedGI13, half4(0,0,0,0));
				float2 uv_DefaultTexture = IN.ase_texcoord7.xy * _DefaultTexture_ST.xy + _DefaultTexture_ST.zw;
				float4 tex2DNode124 = tex2D( _DefaultTexture, uv_DefaultTexture );
				float2 uv_CrystalTexture = IN.ase_texcoord7.xy * _CrystalTexture_ST.xy + _CrystalTexture_ST.zw;
				float time183 = ( _TimeParameters.x * _CrystalVoronoiSpeed );
				float2 voronoiSmoothId183 = 0;
				float2 texCoord188 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords183 = texCoord188 * _CrystalVoronoiScale;
				float2 id183 = 0;
				float2 uv183 = 0;
				float voroi183 = voronoi183( coords183, time183, id183, uv183, 0, voronoiSmoothId183 );
				float clampResult217 = clamp( voroi183 , 0.0 , 1.0 );
				float smoothstepResult192 = smoothstep( _CrystalTextureLerp , ( _CrystalTextureLerp + _CrystalTextureLerpFade ) , clampResult217);
				float LerpIntoCrystal165 = smoothstepResult192;
				float4 lerpResult127 = lerp( tex2DNode124 , tex2D( _CrystalTexture, uv_CrystalTexture ) , LerpIntoCrystal165);
				float2 uv_FireTexture = IN.ase_texcoord7.xy * _FireTexture_ST.xy + _FireTexture_ST.zw;
				float time223 = ( _TimeParameters.x * _FireVoronoiSpeed );
				float2 voronoiSmoothId223 = 0;
				float2 texCoord222 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords223 = texCoord222 * _FireVoronoiScale;
				float2 id223 = 0;
				float2 uv223 = 0;
				float fade223 = 0.5;
				float voroi223 = 0;
				float rest223 = 0;
				for( int it223 = 0; it223 <8; it223++ ){
				voroi223 += fade223 * voronoi223( coords223, time223, id223, uv223, 0,voronoiSmoothId223 );
				rest223 += fade223;
				coords223 *= 2;
				fade223 *= 0.5;
				}//Voronoi223
				voroi223 /= rest223;
				float clampResult227 = clamp( (_FireRemapNews.x + (voroi223 - 0.0) * (_FireRemapNews.y - _FireRemapNews.x) / (1.0 - 0.0)) , 0.0 , 1.0 );
				float smoothstepResult215 = smoothstep( _FireTextureLerp , ( _FireTextureLerp + _FireTextureLerpFade ) , clampResult227);
				float LerpIntoFire166 = ( smoothstepResult215 + ( 0.1 * step( smoothstepResult215 , 0.1 ) ) );
				float4 lerpResult129 = lerp( lerpResult127 , tex2D( _FireTexture, uv_FireTexture ) , LerpIntoFire166);
				float4 BossSlimesTexture133 = lerpResult129;
				float4 Diffuse19 = ( float4( ( temp_output_9_0 + ( ( 1.0 - temp_output_9_0 ) * bakedGI13 ) ) , 0.0 ) * ( BossSlimesTexture133 * _Diffuse_Colour ) );
				float NormalDotLight64 = temp_output_7_0;
				float NormalDotLightStep39 = temp_output_9_0;
				float lerpResult71 = lerp( NormalDotLight64 , pow( ( 1.0 - NormalDotLight64 ) , _SubSurface_Stenght ) , NormalDotLightStep39);
				float2 uv_DefaultSubsurfaceMulti = IN.ase_texcoord7.xy * _DefaultSubsurfaceMulti_ST.xy + _DefaultSubsurfaceMulti_ST.zw;
				float2 uv_CrystalSubsurfaceMulti = IN.ase_texcoord7.xy * _CrystalSubsurfaceMulti_ST.xy + _CrystalSubsurfaceMulti_ST.zw;
				float4 lerpResult173 = lerp( tex2D( _DefaultSubsurfaceMulti, uv_DefaultSubsurfaceMulti ) , tex2D( _CrystalSubsurfaceMulti, uv_CrystalSubsurfaceMulti ) , LerpIntoCrystal165);
				float2 uv_FireSubsurfaceMulti = IN.ase_texcoord7.xy * _FireSubsurfaceMulti_ST.xy + _FireSubsurfaceMulti_ST.zw;
				float4 lerpResult174 = lerp( lerpResult173 , tex2D( _FireSubsurfaceMulti, uv_FireSubsurfaceMulti ) , LerpIntoFire166);
				float4 SubsurfaceMultiTextures180 = lerpResult174;
				float fresnelNdotV83 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode83 = ( 0.0 + _SSS_Fres_Scale * pow( 1.0 - fresnelNdotV83, _SSS_Fres_Power ) );
				float4 SubsurfaceScattering80 = ( ( lerpResult71 * SubsurfaceMultiTextures180 ) + ( fresnelNode83 * SubsurfaceMultiTextures180 ) );
				float fresnelNdotV42 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode42 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV42, 5.0 ) );
				float temp_output_3_0_g10 = ( fresnelNode42 - 0.1 );
				float temp_output_43_0 = saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) );
				float3 bakedGI51 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, WorldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, WorldNormal, bakedGI51, half4(0,0,0,0));
				float4 Highlight53 = ( ( NormalDotLightStep39 * temp_output_43_0 * _MainLightColor * _Highlight_Strenght ) + float4( ( ( 1.0 - NormalDotLightStep39 ) * temp_output_43_0 * bakedGI51 * _Rim_Strenght ) , 0.0 ) );
				
				float2 uv_DefaultEmmisive = IN.ase_texcoord7.xy * _DefaultEmmisive_ST.xy + _DefaultEmmisive_ST.zw;
				float2 uv_CrystalEmmisive = IN.ase_texcoord7.xy * _CrystalEmmisive_ST.xy + _CrystalEmmisive_ST.zw;
				float4 lerpResult163 = lerp( tex2D( _DefaultEmmisive, uv_DefaultEmmisive ) , tex2D( _CrystalEmmisive, uv_CrystalEmmisive ) , LerpIntoCrystal165);
				float2 uv_FireEmmisive = IN.ase_texcoord7.xy * _FireEmmisive_ST.xy + _FireEmmisive_ST.zw;
				float4 lerpResult164 = lerp( lerpResult163 , tex2D( _FireEmmisive, uv_FireEmmisive ) , LerpIntoFire166);
				float4 BossSlimeEmissiveTextures171 = lerpResult164;
				
				float3 normalizeResult23 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float dotResult24 = dot( normalizeResult23 , WorldNormal );
				float temp_output_3_0_g11 = ( pow( dotResult24 , exp2( ( ( _Spec_Smoothness * 10.0 ) + 1.0 ) ) ) - 0.1 );
				float4 Specular35 = ( saturate( ( temp_output_3_0_g11 / fwidth( temp_output_3_0_g11 ) ) ) * _Spec_Colour * _Spec_Smoothness );
				
				float3 Albedo = ( Diffuse19 + ( SubsurfaceScattering80 * _SubSurf_Alpha ) + ( Highlight53 * _Rim_Alpha ) ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = BossSlimeEmissiveTextures171.rgb;
				float3 Specular = ( Specular35 * _Specular_Alpha ).rgb;
				float Metallic = 0;
				float Smoothness = _Overall_Smoothness;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal, 0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES1
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DefaultTexture;
			sampler2D _CrystalTexture;
			sampler2D _FireTexture;
			sampler2D _DefaultSubsurfaceMulti;
			sampler2D _CrystalSubsurfaceMulti;
			sampler2D _FireSubsurfaceMulti;
			sampler2D _DefaultEmmisive;
			sampler2D _CrystalEmmisive;
			sampler2D _FireEmmisive;


			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
					float2 voronoihash183( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi183( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash183( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F2 - F1;
					}
			
					float2 voronoihash223( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi223( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash223( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord4.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float dotResult4 = dot( ase_worldNormal , _MainLightPosition.xyz );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_7_0 = min( saturate( dotResult4 ) , ase_lightAtten );
				float temp_output_3_0_g9 = ( temp_output_7_0 - 0.1 );
				float temp_output_9_0 = saturate( ( temp_output_3_0_g9 / fwidth( temp_output_3_0_g9 ) ) );
				float3 bakedGI13 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI13, half4(0,0,0,0));
				float2 uv_DefaultTexture = IN.ase_texcoord4.xy * _DefaultTexture_ST.xy + _DefaultTexture_ST.zw;
				float4 tex2DNode124 = tex2D( _DefaultTexture, uv_DefaultTexture );
				float2 uv_CrystalTexture = IN.ase_texcoord4.xy * _CrystalTexture_ST.xy + _CrystalTexture_ST.zw;
				float time183 = ( _TimeParameters.x * _CrystalVoronoiSpeed );
				float2 voronoiSmoothId183 = 0;
				float2 texCoord188 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords183 = texCoord188 * _CrystalVoronoiScale;
				float2 id183 = 0;
				float2 uv183 = 0;
				float voroi183 = voronoi183( coords183, time183, id183, uv183, 0, voronoiSmoothId183 );
				float clampResult217 = clamp( voroi183 , 0.0 , 1.0 );
				float smoothstepResult192 = smoothstep( _CrystalTextureLerp , ( _CrystalTextureLerp + _CrystalTextureLerpFade ) , clampResult217);
				float LerpIntoCrystal165 = smoothstepResult192;
				float4 lerpResult127 = lerp( tex2DNode124 , tex2D( _CrystalTexture, uv_CrystalTexture ) , LerpIntoCrystal165);
				float2 uv_FireTexture = IN.ase_texcoord4.xy * _FireTexture_ST.xy + _FireTexture_ST.zw;
				float time223 = ( _TimeParameters.x * _FireVoronoiSpeed );
				float2 voronoiSmoothId223 = 0;
				float2 texCoord222 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords223 = texCoord222 * _FireVoronoiScale;
				float2 id223 = 0;
				float2 uv223 = 0;
				float fade223 = 0.5;
				float voroi223 = 0;
				float rest223 = 0;
				for( int it223 = 0; it223 <8; it223++ ){
				voroi223 += fade223 * voronoi223( coords223, time223, id223, uv223, 0,voronoiSmoothId223 );
				rest223 += fade223;
				coords223 *= 2;
				fade223 *= 0.5;
				}//Voronoi223
				voroi223 /= rest223;
				float clampResult227 = clamp( (_FireRemapNews.x + (voroi223 - 0.0) * (_FireRemapNews.y - _FireRemapNews.x) / (1.0 - 0.0)) , 0.0 , 1.0 );
				float smoothstepResult215 = smoothstep( _FireTextureLerp , ( _FireTextureLerp + _FireTextureLerpFade ) , clampResult227);
				float LerpIntoFire166 = ( smoothstepResult215 + ( 0.1 * step( smoothstepResult215 , 0.1 ) ) );
				float4 lerpResult129 = lerp( lerpResult127 , tex2D( _FireTexture, uv_FireTexture ) , LerpIntoFire166);
				float4 BossSlimesTexture133 = lerpResult129;
				float4 Diffuse19 = ( float4( ( temp_output_9_0 + ( ( 1.0 - temp_output_9_0 ) * bakedGI13 ) ) , 0.0 ) * ( BossSlimesTexture133 * _Diffuse_Colour ) );
				float NormalDotLight64 = temp_output_7_0;
				float NormalDotLightStep39 = temp_output_9_0;
				float lerpResult71 = lerp( NormalDotLight64 , pow( ( 1.0 - NormalDotLight64 ) , _SubSurface_Stenght ) , NormalDotLightStep39);
				float2 uv_DefaultSubsurfaceMulti = IN.ase_texcoord4.xy * _DefaultSubsurfaceMulti_ST.xy + _DefaultSubsurfaceMulti_ST.zw;
				float2 uv_CrystalSubsurfaceMulti = IN.ase_texcoord4.xy * _CrystalSubsurfaceMulti_ST.xy + _CrystalSubsurfaceMulti_ST.zw;
				float4 lerpResult173 = lerp( tex2D( _DefaultSubsurfaceMulti, uv_DefaultSubsurfaceMulti ) , tex2D( _CrystalSubsurfaceMulti, uv_CrystalSubsurfaceMulti ) , LerpIntoCrystal165);
				float2 uv_FireSubsurfaceMulti = IN.ase_texcoord4.xy * _FireSubsurfaceMulti_ST.xy + _FireSubsurfaceMulti_ST.zw;
				float4 lerpResult174 = lerp( lerpResult173 , tex2D( _FireSubsurfaceMulti, uv_FireSubsurfaceMulti ) , LerpIntoFire166);
				float4 SubsurfaceMultiTextures180 = lerpResult174;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV83 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode83 = ( 0.0 + _SSS_Fres_Scale * pow( 1.0 - fresnelNdotV83, _SSS_Fres_Power ) );
				float4 SubsurfaceScattering80 = ( ( lerpResult71 * SubsurfaceMultiTextures180 ) + ( fresnelNode83 * SubsurfaceMultiTextures180 ) );
				float fresnelNdotV42 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode42 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV42, 5.0 ) );
				float temp_output_3_0_g10 = ( fresnelNode42 - 0.1 );
				float temp_output_43_0 = saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) );
				float3 bakedGI51 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI51, half4(0,0,0,0));
				float4 Highlight53 = ( ( NormalDotLightStep39 * temp_output_43_0 * _MainLightColor * _Highlight_Strenght ) + float4( ( ( 1.0 - NormalDotLightStep39 ) * temp_output_43_0 * bakedGI51 * _Rim_Strenght ) , 0.0 ) );
				
				float2 uv_DefaultEmmisive = IN.ase_texcoord4.xy * _DefaultEmmisive_ST.xy + _DefaultEmmisive_ST.zw;
				float2 uv_CrystalEmmisive = IN.ase_texcoord4.xy * _CrystalEmmisive_ST.xy + _CrystalEmmisive_ST.zw;
				float4 lerpResult163 = lerp( tex2D( _DefaultEmmisive, uv_DefaultEmmisive ) , tex2D( _CrystalEmmisive, uv_CrystalEmmisive ) , LerpIntoCrystal165);
				float2 uv_FireEmmisive = IN.ase_texcoord4.xy * _FireEmmisive_ST.xy + _FireEmmisive_ST.zw;
				float4 lerpResult164 = lerp( lerpResult163 , tex2D( _FireEmmisive, uv_FireEmmisive ) , LerpIntoFire166);
				float4 BossSlimeEmissiveTextures171 = lerpResult164;
				
				
				float3 Albedo = ( Diffuse19 + ( SubsurfaceScattering80 * _SubSurf_Alpha ) + ( Highlight53 * _Rim_Alpha ) ).rgb;
				float3 Emission = BossSlimeEmissiveTextures171.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FireTexture_ST;
			float4 _DefaultSubsurfaceMulti_ST;
			float4 _Diffuse_Colour;
			float4 _CrystalSubsurfaceMulti_ST;
			float4 _DefaultEmmisive_ST;
			float4 _CrystalEmmisive_ST;
			float4 _FireSubsurfaceMulti_ST;
			float4 _CrystalTexture_ST;
			float4 _Outline_Colour;
			float4 _Spec_Colour;
			float4 _DefaultTexture_ST;
			float4 _FireEmmisive_ST;
			float2 _FireRemapNews;
			float _Rim_Alpha;
			float _Spec_Smoothness;
			float _Rim_Strenght;
			float _Highlight_Strenght;
			float _FresnelScale;
			float _SubSurf_Alpha;
			float _SSS_Fres_Power;
			float _Outline_Width;
			float _SubSurface_Stenght;
			float _Specular_Alpha;
			float _FireVoronoiSpeed;
			float _FireVoronoiScale;
			float _FireTextureLerpFade;
			float _FireTextureLerp;
			float _CrystalVoronoiSpeed;
			float _CrystalVoronoiScale;
			float _CrystalTextureLerpFade;
			float _CrystalTextureLerp;
			float _Outline_Alpha;
			float _Outline_Distance;
			float _SSS_Fres_Scale;
			float _Overall_Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DefaultTexture;
			sampler2D _CrystalTexture;
			sampler2D _FireTexture;
			sampler2D _DefaultSubsurfaceMulti;
			sampler2D _CrystalSubsurfaceMulti;
			sampler2D _FireSubsurfaceMulti;


			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
					float2 voronoihash183( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi183( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash183( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F2 - F1;
					}
			
					float2 voronoihash223( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi223( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash223( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord4.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float dotResult4 = dot( ase_worldNormal , _MainLightPosition.xyz );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_7_0 = min( saturate( dotResult4 ) , ase_lightAtten );
				float temp_output_3_0_g9 = ( temp_output_7_0 - 0.1 );
				float temp_output_9_0 = saturate( ( temp_output_3_0_g9 / fwidth( temp_output_3_0_g9 ) ) );
				float3 bakedGI13 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI13, half4(0,0,0,0));
				float2 uv_DefaultTexture = IN.ase_texcoord4.xy * _DefaultTexture_ST.xy + _DefaultTexture_ST.zw;
				float4 tex2DNode124 = tex2D( _DefaultTexture, uv_DefaultTexture );
				float2 uv_CrystalTexture = IN.ase_texcoord4.xy * _CrystalTexture_ST.xy + _CrystalTexture_ST.zw;
				float time183 = ( _TimeParameters.x * _CrystalVoronoiSpeed );
				float2 voronoiSmoothId183 = 0;
				float2 texCoord188 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords183 = texCoord188 * _CrystalVoronoiScale;
				float2 id183 = 0;
				float2 uv183 = 0;
				float voroi183 = voronoi183( coords183, time183, id183, uv183, 0, voronoiSmoothId183 );
				float clampResult217 = clamp( voroi183 , 0.0 , 1.0 );
				float smoothstepResult192 = smoothstep( _CrystalTextureLerp , ( _CrystalTextureLerp + _CrystalTextureLerpFade ) , clampResult217);
				float LerpIntoCrystal165 = smoothstepResult192;
				float4 lerpResult127 = lerp( tex2DNode124 , tex2D( _CrystalTexture, uv_CrystalTexture ) , LerpIntoCrystal165);
				float2 uv_FireTexture = IN.ase_texcoord4.xy * _FireTexture_ST.xy + _FireTexture_ST.zw;
				float time223 = ( _TimeParameters.x * _FireVoronoiSpeed );
				float2 voronoiSmoothId223 = 0;
				float2 texCoord222 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords223 = texCoord222 * _FireVoronoiScale;
				float2 id223 = 0;
				float2 uv223 = 0;
				float fade223 = 0.5;
				float voroi223 = 0;
				float rest223 = 0;
				for( int it223 = 0; it223 <8; it223++ ){
				voroi223 += fade223 * voronoi223( coords223, time223, id223, uv223, 0,voronoiSmoothId223 );
				rest223 += fade223;
				coords223 *= 2;
				fade223 *= 0.5;
				}//Voronoi223
				voroi223 /= rest223;
				float clampResult227 = clamp( (_FireRemapNews.x + (voroi223 - 0.0) * (_FireRemapNews.y - _FireRemapNews.x) / (1.0 - 0.0)) , 0.0 , 1.0 );
				float smoothstepResult215 = smoothstep( _FireTextureLerp , ( _FireTextureLerp + _FireTextureLerpFade ) , clampResult227);
				float LerpIntoFire166 = ( smoothstepResult215 + ( 0.1 * step( smoothstepResult215 , 0.1 ) ) );
				float4 lerpResult129 = lerp( lerpResult127 , tex2D( _FireTexture, uv_FireTexture ) , LerpIntoFire166);
				float4 BossSlimesTexture133 = lerpResult129;
				float4 Diffuse19 = ( float4( ( temp_output_9_0 + ( ( 1.0 - temp_output_9_0 ) * bakedGI13 ) ) , 0.0 ) * ( BossSlimesTexture133 * _Diffuse_Colour ) );
				float NormalDotLight64 = temp_output_7_0;
				float NormalDotLightStep39 = temp_output_9_0;
				float lerpResult71 = lerp( NormalDotLight64 , pow( ( 1.0 - NormalDotLight64 ) , _SubSurface_Stenght ) , NormalDotLightStep39);
				float2 uv_DefaultSubsurfaceMulti = IN.ase_texcoord4.xy * _DefaultSubsurfaceMulti_ST.xy + _DefaultSubsurfaceMulti_ST.zw;
				float2 uv_CrystalSubsurfaceMulti = IN.ase_texcoord4.xy * _CrystalSubsurfaceMulti_ST.xy + _CrystalSubsurfaceMulti_ST.zw;
				float4 lerpResult173 = lerp( tex2D( _DefaultSubsurfaceMulti, uv_DefaultSubsurfaceMulti ) , tex2D( _CrystalSubsurfaceMulti, uv_CrystalSubsurfaceMulti ) , LerpIntoCrystal165);
				float2 uv_FireSubsurfaceMulti = IN.ase_texcoord4.xy * _FireSubsurfaceMulti_ST.xy + _FireSubsurfaceMulti_ST.zw;
				float4 lerpResult174 = lerp( lerpResult173 , tex2D( _FireSubsurfaceMulti, uv_FireSubsurfaceMulti ) , LerpIntoFire166);
				float4 SubsurfaceMultiTextures180 = lerpResult174;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV83 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode83 = ( 0.0 + _SSS_Fres_Scale * pow( 1.0 - fresnelNdotV83, _SSS_Fres_Power ) );
				float4 SubsurfaceScattering80 = ( ( lerpResult71 * SubsurfaceMultiTextures180 ) + ( fresnelNode83 * SubsurfaceMultiTextures180 ) );
				float fresnelNdotV42 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode42 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV42, 5.0 ) );
				float temp_output_3_0_g10 = ( fresnelNode42 - 0.1 );
				float temp_output_43_0 = saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) );
				float3 bakedGI51 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI51, half4(0,0,0,0));
				float4 Highlight53 = ( ( NormalDotLightStep39 * temp_output_43_0 * _MainLightColor * _Highlight_Strenght ) + float4( ( ( 1.0 - NormalDotLightStep39 ) * temp_output_43_0 * bakedGI51 * _Rim_Strenght ) , 0.0 ) );
				
				
				float3 Albedo = ( Diffuse19 + ( SubsurfaceScattering80 * _SubSurf_Alpha ) + ( Highlight53 * _Rim_Alpha ) ).rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
126;181;1460;605;5492.866;868.6887;6.360644;True;False
Node;AmplifyShaderEditor.CommentaryNode;267;-2726.805,1299.336;Inherit;False;2237.914;961.9309;LerpEffects;29;219;218;221;222;220;224;223;159;225;213;185;186;214;227;187;184;188;215;239;183;128;194;217;193;192;165;262;232;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;218;-2676.805,1814.649;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-2674.682,1895.347;Inherit;False;Property;_FireVoronoiSpeed;Fire Voronoi Speed;2;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-2454.375,1818.285;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;222;-2536.016,1695.864;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;220;-2467.247,1934.936;Inherit;False;Property;_FireVoronoiScale;Fire Voronoi Scale;10;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;224;-2274.664,2067.468;Inherit;False;Property;_FireRemapNews;Fire Remap News;13;0;Create;True;0;0;0;False;0;False;-3.14,1.95;0,1.85;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VoronoiNode;223;-2265.222,1787.829;Inherit;True;0;0;1;3;8;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TFHCRemapNode;225;-2062.042,1819.662;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;185;-2435,1455.578;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2068.098,2133.311;Inherit;False;Property;_FireTextureLerpFade;Fire Texture Lerp Fade;12;0;Create;True;0;0;0;False;0;False;2;0.6744601;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-2065.6,2053.35;Inherit;False;Property;_FireTextureLerp;Fire Texture Lerp;32;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-2473.072,1553.336;Inherit;False;Property;_CrystalVoronoiSpeed;Crystal Voronoi Speed;34;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;188;-2237.072,1349.336;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;227;-1717.334,1872.01;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-2207.072,1488.336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-2212.341,1591.497;Inherit;False;Property;_CrystalVoronoiScale;Crystal Voronoi Scale;33;0;Create;True;0;0;0;False;0;False;0;6.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;61;-1124.051,-219.8217;Inherit;False;2300.392;951.9884;Diffuse;18;5;18;16;11;14;19;12;2;4;8;6;7;9;39;10;13;64;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-1638.747,2029.858;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;183;-1901.182,1398.728;Inherit;True;0;0;1;2;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;128;-1978.897,1668.58;Inherit;False;Property;_CrystalTextureLerp;Crystal Texture Lerp;31;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-1978.625,1745.135;Inherit;False;Property;_CrystalTextureLerpFade;Crystal Texture Lerp Fade;11;0;Create;True;0;0;0;False;0;False;2;0.8235295;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-1104.051,-169.8217;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;215;-1488.904,1879.808;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;5;-1101.051,0.727196;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-1659.223,1700.046;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;217;-1726.949,1425.412;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;4;-879.8677,-112.0473;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;239;-1245.067,2007.267;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;6;-657.123,-91.53743;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;8;-672.5497,129.6805;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-1036.959,1941.861;Inherit;False;2;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;192;-1541.275,1427.224;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;7;-464.8889,-27.71422;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-1317.435,1425.235;Inherit;False;LerpIntoCrystal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;182;-2726.401,-594.2277;Inherit;False;1561.684;1876.903;Lerping System;25;167;125;124;127;126;168;129;133;163;164;161;160;162;169;171;101;170;176;178;175;173;179;177;174;180;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;232;-912.3782,1881.139;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-212.2124,-123.1253;Inherit;False;NormalDotLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;175;-2605.734,664.312;Inherit;True;Property;_DefaultSubsurfaceMulti;Default SubsurfaceMulti;23;0;Create;True;0;0;0;False;0;False;-1;50041941d1e8d18448c3dab07e5150e8;50041941d1e8d18448c3dab07e5150e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;82;-2739.526,-1320.744;Inherit;False;1583.045;703.9894;Subsurface Scattering;15;67;73;63;75;71;78;72;77;83;84;85;87;86;80;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-712.8909,1876.749;Inherit;False;LerpIntoFire;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-2249.405,857.425;Inherit;False;165;LerpIntoCrystal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;176;-2648.401,859.676;Inherit;True;Property;_CrystalSubsurfaceMulti;Crystal SubsurfaceMulti;27;0;Create;True;0;0;0;False;0;False;-1;40cfa72d7a927ff4f9d9c4ee1c57bc18;40cfa72d7a927ff4f9d9c4ee1c57bc18;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;9;-231.9439,-27.46984;Inherit;True;Step Antialiasing;-1;;9;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-2733.426,-1278.744;Inherit;True;64;NormalDotLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-2676.401,1052.676;Inherit;True;Property;_FireSubsurfaceMulti;Fire SubsurfaceMulti;30;0;Create;True;0;0;0;False;0;False;-1;fe24b13ab18ef6a48937ff321f94110f;fe24b13ab18ef6a48937ff321f94110f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;125;-2614.567,-344.8633;Inherit;True;Property;_CrystalTexture;Crystal Texture;26;0;Create;True;0;0;0;False;0;False;-1;40cfa72d7a927ff4f9d9c4ee1c57bc18;40cfa72d7a927ff4f9d9c4ee1c57bc18;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;124;-2613.899,-544.2275;Inherit;True;Property;_DefaultTexture;Default Texture;24;0;Create;True;0;0;0;False;0;False;-1;50041941d1e8d18448c3dab07e5150e8;50041941d1e8d18448c3dab07e5150e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;60;-1124.003,-1115.409;Inherit;False;2373.498;866.2963;RimLight;14;49;52;51;50;41;47;53;46;40;43;44;42;48;88;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-2269.437,-350.0411;Inherit;False;165;LerpIntoCrystal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;69.8935,-148.9549;Inherit;False;NormalDotLightStep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-2237.377,941.6191;Inherit;False;166;LerpIntoFire;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;173;-1926.437,727.5552;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2708.057,-1017.16;Inherit;False;Property;_SubSurface_Stenght;SubSurface_Stenght;7;0;Create;True;0;0;0;False;0;False;10;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2723.986,-915.6536;Inherit;True;39;NormalDotLightStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;-2613.567,-144.8633;Inherit;True;Property;_FireTexture;Fire Texture;28;0;Create;True;0;0;0;False;0;False;-1;fe24b13ab18ef6a48937ff321f94110f;fe24b13ab18ef6a48937ff321f94110f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;127;-1988.603,-470.9846;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;72;-2534.138,-1245.123;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1074.003,-778.2938;Inherit;False;Property;_FresnelScale;FresnelScale;4;0;Create;True;0;0;0;False;0;False;0.65;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-2274.637,-261.6411;Inherit;False;166;LerpIntoFire;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;174;-1713.675,788.9492;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;-1444.717,788.689;Inherit;False;SubsurfaceMultiTextures;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;129;-1775.84,-409.5905;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;42;-840.702,-846.4988;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2253.402,-759.3262;Inherit;False;Property;_SSS_Fres_Power;SSS_Fres_Power;9;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;239.9768,-708.1265;Inherit;False;39;NormalDotLightStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;77;-2303.362,-1216.559;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2252.202,-840.9263;Inherit;False;Property;_SSS_Fres_Scale;SSS_Fres_Scale;8;0;Create;True;0;0;0;False;0;False;11;11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;75;-2487.799,-917.1616;Inherit;True;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-1495.873,-421.6499;Inherit;False;BossSlimesTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;13;-32.23515,89.01387;Inherit;True;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;10;112.8599,16.32068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;131.2214,-1065.409;Inherit;False;39;NormalDotLightStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;83;-2023.719,-837.3531;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;43;-556.8851,-842.6078;Inherit;True;Step Antialiasing;-1;;10;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;371.1898,-365.1126;Inherit;False;Property;_Rim_Strenght;Rim_Strenght;6;0;Create;True;0;0;0;False;0;False;1;2.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;51;345.5215,-440.9233;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;88;26.64403,-860.5748;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;49;458.9368,-698.9484;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-2054.176,-1014.616;Inherit;False;180;SubsurfaceMultiTextures;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;71;-2066.805,-1284.433;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;12.11992,-739.3398;Inherit;False;Property;_Highlight_Strenght;Highlight_Strenght;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1574.126,-988.7805;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;282.7659,46.99821;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;587.4279,-524.5681;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;18;201.8704,242.7831;Inherit;False;Property;_Diffuse_Colour;Diffuse_Colour;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1652.575,-1246.637;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;195.4687,154.0607;Inherit;False;133;BossSlimesTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;379.2762,-990.0381;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;786.0803,-804.0235;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;522.8466,104.7056;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-1363.312,-1088.946;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;448.3843,-84.96317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-1371.443,-1281.792;Inherit;False;SubsurfaceScattering;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;1025.495,-739.4885;Inherit;False;Highlight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;732.0095,40.81031;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;1539.743,352.5099;Inherit;False;53;Highlight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;952.3403,53.97856;Inherit;False;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;90;1488.286,432.7668;Inherit;False;Property;_Rim_Alpha;Rim_Alpha;14;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;1480.302,237.0498;Inherit;False;Property;_SubSurf_Alpha;SubSurf_Alpha;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;1506.839,159.9613;Inherit;False;80;SubsurfaceScattering;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;1815.005,33.16698;Inherit;False;19;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;1807.103,333.5249;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;120;-437.9135,1314.107;Inherit;False;1102.771;677.2579;Outline;9;105;98;100;102;103;99;96;104;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;1808.216,116.059;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1123.999,751.0065;Inherit;False;2119.078;531.3668;Specular;15;32;33;31;35;27;21;20;28;22;25;23;24;30;26;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;160;-2612.71,262.3359;Inherit;True;Property;_CrystalEmmisive;Crystal Emmisive;25;0;Create;True;0;0;0;False;0;False;-1;40cfa72d7a927ff4f9d9c4ee1c57bc18;9cd6ee011ea58e3468429ff119beb61c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-158.0653,1106.19;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;2133.016,109.9608;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;23;-620.3117,897.3231;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-1505.025,200.6994;Inherit;False;BossSlimeEmissiveTextures;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2315.672,-439.3674;Inherit;False;Texture_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-777.8182,875.0667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;2145.836,-71.97765;Inherit;False;96;Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;823.1292,1031.453;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;105;103.9595,1730.376;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-171.5463,1524.511;Inherit;False;Property;_Outline_Width;Outline_Width;18;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;337.5237,1078.529;Inherit;False;Property;_Spec_Colour;Spec_Colour;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1.498039,1.498039,1.498039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;25;-658.5859,1018.876;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;107;2133.387,-267.2668;Inherit;False;Property;_Outline_Colour;Outline_Colour;17;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;103;-387.9135,1718.401;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;163;-1986.746,136.2149;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;94;1987.053,716.3666;Inherit;False;Property;_Specular_Alpha;Specular_Alpha;16;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;164;-1773.984,197.6089;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-26.2392,1109.615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;2327.972,576.6765;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;21;-1073.999,955.5313;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;169;-2309.713,266.0851;Inherit;False;165;LerpIntoCrystal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;33;429.8592,954.9973;Inherit;False;Step Antialiasing;-1;;11;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-142.8883,1875.365;Inherit;False;Property;_Outline_Distance;Outline_Distance;19;0;Create;True;0;0;0;False;0;False;15;400;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;104;-154.9113,1704.095;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;20;-1053.765,801.0065;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;627.0363,998.091;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;2038.636,624.3289;Inherit;False;35;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;115;2093.729,14.2052;Inherit;False;Property;_Outline_Alpha;Outline_Alpha;20;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;2407.729,-24.7948;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;2117.591,342.1179;Inherit;False;171;BossSlimeEmissiveTextures;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;242.2396,1484.107;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Exp2OpNode;30;122.7069,1109.615;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-149.0983,1625.922;Inherit;False;101;Texture_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-433.7013,1097.63;Inherit;False;Property;_Spec_Smoothness;Spec_Smoothness;1;0;Create;True;0;0;0;False;0;False;0.954;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;2579.658,657.7766;Inherit;False;Property;_Overall_Smoothness;Overall_Smoothness;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;440.8589,1474.301;Inherit;False;Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;161;-2612.043,62.97221;Inherit;True;Property;_DefaultEmmisive;Default Emmisive;22;0;Create;True;0;0;0;False;0;False;-1;50041941d1e8d18448c3dab07e5150e8;a1f54dfa529ce0f41a2f81e1380cfd02;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2297.686,350.2783;Inherit;False;166;LerpIntoFire;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;24;-431.9891,967.5163;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;162;-2611.71,462.3359;Inherit;True;Property;_FireEmmisive;Fire Emmisive;29;0;Create;True;0;0;0;False;0;False;-1;fe24b13ab18ef6a48937ff321f94110f;380019da6d0638a41bbfd40980af87e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;98;-108.7604,1364.107;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;26;275.0777,974.3643;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;114;2655.199,105.8385;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;112;2655.199,105.8385;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;110;3013.865,100.7217;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;Shaders_CelShader_BossSlime;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;0;637888563752726232;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,-1;0;Translucency;0;0;  Translucency Strength;1,False,-1;0;  Normal Distortion;0.5,False,-1;0;  Scattering;2,False,-1;0;  Direct;0.9,False,-1;0;  Ambient;0.1,False,-1;0;  Shadow;0.5,False,-1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;1;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;6;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;111;2655.199,105.8385;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;113;2655.199,105.8385;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;109;2646.527,-203.5897;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;221;0;218;0
WireConnection;221;1;219;0
WireConnection;223;0;222;0
WireConnection;223;1;221;0
WireConnection;223;2;220;0
WireConnection;225;0;223;0
WireConnection;225;3;224;1
WireConnection;225;4;224;2
WireConnection;227;0;225;0
WireConnection;187;0;185;0
WireConnection;187;1;186;0
WireConnection;214;0;159;0
WireConnection;214;1;213;0
WireConnection;183;0;188;0
WireConnection;183;1;187;0
WireConnection;183;2;184;0
WireConnection;215;0;227;0
WireConnection;215;1;159;0
WireConnection;215;2;214;0
WireConnection;193;0;128;0
WireConnection;193;1;194;0
WireConnection;217;0;183;0
WireConnection;4;0;2;0
WireConnection;4;1;5;0
WireConnection;239;0;215;0
WireConnection;6;0;4;0
WireConnection;262;1;239;0
WireConnection;192;0;217;0
WireConnection;192;1;128;0
WireConnection;192;2;193;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;165;0;192;0
WireConnection;232;0;215;0
WireConnection;232;1;262;0
WireConnection;64;0;7;0
WireConnection;166;0;232;0
WireConnection;9;2;7;0
WireConnection;39;0;9;0
WireConnection;173;0;175;0
WireConnection;173;1;176;0
WireConnection;173;2;178;0
WireConnection;127;0;124;0
WireConnection;127;1;125;0
WireConnection;127;2;167;0
WireConnection;72;0;67;0
WireConnection;174;0;173;0
WireConnection;174;1;177;0
WireConnection;174;2;179;0
WireConnection;180;0;174;0
WireConnection;129;0;127;0
WireConnection;129;1;126;0
WireConnection;129;2;168;0
WireConnection;42;2;44;0
WireConnection;77;0;72;0
WireConnection;77;1;78;0
WireConnection;75;0;63;0
WireConnection;133;0;129;0
WireConnection;10;0;9;0
WireConnection;83;2;86;0
WireConnection;83;3;87;0
WireConnection;43;2;42;0
WireConnection;49;0;48;0
WireConnection;71;0;67;0
WireConnection;71;1;77;0
WireConnection;71;2;75;0
WireConnection;85;0;83;0
WireConnection;85;1;181;0
WireConnection;11;0;10;0
WireConnection;11;1;13;0
WireConnection;50;0;49;0
WireConnection;50;1;43;0
WireConnection;50;2;51;0
WireConnection;50;3;52;0
WireConnection;73;0;71;0
WireConnection;73;1;181;0
WireConnection;41;0;40;0
WireConnection;41;1;43;0
WireConnection;41;2;88;0
WireConnection;41;3;46;0
WireConnection;47;0;41;0
WireConnection;47;1;50;0
WireConnection;16;0;134;0
WireConnection;16;1;18;0
WireConnection;84;0;73;0
WireConnection;84;1;85;0
WireConnection;12;0;9;0
WireConnection;12;1;11;0
WireConnection;80;0;84;0
WireConnection;53;0;47;0
WireConnection;14;0;12;0
WireConnection;14;1;16;0
WireConnection;19;0;14;0
WireConnection;89;0;54;0
WireConnection;89;1;90;0
WireConnection;91;0;81;0
WireConnection;91;1;92;0
WireConnection;28;0;27;0
WireConnection;38;0;37;0
WireConnection;38;1;91;0
WireConnection;38;2;89;0
WireConnection;23;0;22;0
WireConnection;171;0;164;0
WireConnection;101;0;124;4
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;35;0;31;0
WireConnection;105;0;104;4
WireConnection;105;1;106;0
WireConnection;163;0;161;0
WireConnection;163;1;160;0
WireConnection;163;2;169;0
WireConnection;164;0;163;0
WireConnection;164;1;162;0
WireConnection;164;2;170;0
WireConnection;29;0;28;0
WireConnection;93;0;36;0
WireConnection;93;1;94;0
WireConnection;33;2;26;0
WireConnection;104;0;103;0
WireConnection;31;0;33;0
WireConnection;31;1;32;0
WireConnection;31;2;27;0
WireConnection;116;0;97;0
WireConnection;116;1;115;0
WireConnection;99;0;98;0
WireConnection;99;1;100;0
WireConnection;99;2;102;0
WireConnection;99;3;105;0
WireConnection;30;0;29;0
WireConnection;96;0;99;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
WireConnection;26;1;30;0
WireConnection;110;0;38;0
WireConnection;110;2;172;0
WireConnection;110;9;93;0
WireConnection;110;4;119;0
WireConnection;109;0;107;0
WireConnection;109;3;116;0
ASEEND*/
//CHKSM=F009D504F9D62E90146088B836AB1BC18DEE00FE