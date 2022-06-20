// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_LightningTrail"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin]_Texture0("Texture 0", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		[HDR]_BaseColour("BaseColour", Color) = (1,0.7529564,0,0)
		_FlashingControl("FlashingControl", Vector) = (10,10,10,10)
		[ASEEnd]_PanningControl("PanningControl", Vector) = (1,1,1,1)

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

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
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
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour;
			float4 _PanningControl;
			float4 _FlashingControl;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Texture0;
			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
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
				float4 ase_color : COLOR;
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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float4 DiffuseColour13 = ( IN.ase_color * _BaseColour );
				float PanningOnX74 = _PanningControl.x;
				float mulTime42 = _TimeParameters.x * PanningOnX74;
				float2 texCoord7 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6 = ( mulTime42 * float2( 1.5,0 ) + texCoord7);
				float temp_output_4_0_g13 = 1.0;
				float temp_output_5_0_g13 = 2.0;
				float2 appendResult7_g13 = (float2(temp_output_4_0_g13 , temp_output_5_0_g13));
				float totalFrames39_g13 = ( temp_output_4_0_g13 * temp_output_5_0_g13 );
				float2 appendResult8_g13 = (float2(totalFrames39_g13 , temp_output_5_0_g13));
				float FlashingOnX34 = sin( ( _TimeParameters.x * _FlashingControl.x ) );
				float clampResult42_g13 = clamp( 0.0 , 0.0001 , ( totalFrames39_g13 - 1.0 ) );
				float temp_output_35_0_g13 = frac( ( ( FlashingOnX34 + clampResult42_g13 ) / totalFrames39_g13 ) );
				float2 appendResult29_g13 = (float2(temp_output_35_0_g13 , ( 1.0 - temp_output_35_0_g13 )));
				float2 temp_output_15_0_g13 = ( ( panner6 / appendResult7_g13 ) + ( floor( ( appendResult8_g13 * appendResult29_g13 ) ) / appendResult7_g13 ) );
				float4 LightningX82 = ( tex2D( _Texture0, temp_output_15_0_g13 ) * FlashingOnX34 );
				float PanningOnY75 = _PanningControl.y;
				float mulTime62 = _TimeParameters.x * PanningOnY75;
				float2 texCoord61 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner60 = ( mulTime62 * float2( 1.5,0 ) + texCoord61);
				float temp_output_4_0_g12 = 1.0;
				float temp_output_5_0_g12 = 2.0;
				float2 appendResult7_g12 = (float2(temp_output_4_0_g12 , temp_output_5_0_g12));
				float totalFrames39_g12 = ( temp_output_4_0_g12 * temp_output_5_0_g12 );
				float2 appendResult8_g12 = (float2(totalFrames39_g12 , temp_output_5_0_g12));
				float FlashingOnY35 = sin( ( _TimeParameters.x * _FlashingControl.y ) );
				float clampResult42_g12 = clamp( 0.0 , 0.0001 , ( totalFrames39_g12 - 1.0 ) );
				float temp_output_35_0_g12 = frac( ( ( FlashingOnY35 + clampResult42_g12 ) / totalFrames39_g12 ) );
				float2 appendResult29_g12 = (float2(temp_output_35_0_g12 , ( 1.0 - temp_output_35_0_g12 )));
				float2 temp_output_15_0_g12 = ( ( panner60 / appendResult7_g12 ) + ( floor( ( appendResult8_g12 * appendResult29_g12 ) ) / appendResult7_g12 ) );
				float4 LightningY83 = ( tex2D( _Texture1, temp_output_15_0_g12 ) * FlashingOnY35 );
				float PanningOnZ76 = _PanningControl.z;
				float mulTime67 = _TimeParameters.x * PanningOnZ76;
				float2 texCoord66 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner65 = ( mulTime67 * float2( 1.5,0 ) + texCoord66);
				float temp_output_4_0_g15 = 1.0;
				float temp_output_5_0_g15 = 2.0;
				float2 appendResult7_g15 = (float2(temp_output_4_0_g15 , temp_output_5_0_g15));
				float totalFrames39_g15 = ( temp_output_4_0_g15 * temp_output_5_0_g15 );
				float2 appendResult8_g15 = (float2(totalFrames39_g15 , temp_output_5_0_g15));
				float FlashingOnZ36 = sin( ( _TimeParameters.x * _FlashingControl.z ) );
				float clampResult42_g15 = clamp( 0.0 , 0.0001 , ( totalFrames39_g15 - 1.0 ) );
				float temp_output_35_0_g15 = frac( ( ( FlashingOnZ36 + clampResult42_g15 ) / totalFrames39_g15 ) );
				float2 appendResult29_g15 = (float2(temp_output_35_0_g15 , ( 1.0 - temp_output_35_0_g15 )));
				float2 temp_output_15_0_g15 = ( ( panner65 / appendResult7_g15 ) + ( floor( ( appendResult8_g15 * appendResult29_g15 ) ) / appendResult7_g15 ) );
				float4 LightningZ84 = ( tex2D( _Texture2, temp_output_15_0_g15 ) * FlashingOnZ36 );
				float PanningOnW77 = _PanningControl.w;
				float mulTime72 = _TimeParameters.x * PanningOnW77;
				float2 texCoord71 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner70 = ( mulTime72 * float2( 1.5,0 ) + texCoord71);
				float temp_output_4_0_g14 = 1.0;
				float temp_output_5_0_g14 = 2.0;
				float2 appendResult7_g14 = (float2(temp_output_4_0_g14 , temp_output_5_0_g14));
				float totalFrames39_g14 = ( temp_output_4_0_g14 * temp_output_5_0_g14 );
				float2 appendResult8_g14 = (float2(totalFrames39_g14 , temp_output_5_0_g14));
				float FlashingOnW37 = sin( ( _TimeParameters.x * _FlashingControl.w ) );
				float clampResult42_g14 = clamp( 0.0 , 0.0001 , ( totalFrames39_g14 - 1.0 ) );
				float temp_output_35_0_g14 = frac( ( ( FlashingOnW37 + clampResult42_g14 ) / totalFrames39_g14 ) );
				float2 appendResult29_g14 = (float2(temp_output_35_0_g14 , ( 1.0 - temp_output_35_0_g14 )));
				float2 temp_output_15_0_g14 = ( ( panner70 / appendResult7_g14 ) + ( floor( ( appendResult8_g14 * appendResult29_g14 ) ) / appendResult7_g14 ) );
				float4 LightningW85 = ( tex2D( _Texture3, temp_output_15_0_g14 ) * FlashingOnW37 );
				float4 temp_output_94_0 = ( LightningX82 + LightningY83 + LightningZ84 + LightningW85 );
				
				float VertexAlpha104 = IN.ase_color.a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( DiffuseColour13 * temp_output_94_0 ).rgb;
				float Alpha = ( temp_output_94_0 * VertexAlpha104 ).r;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
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
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour;
			float4 _PanningControl;
			float4 _FlashingControl;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Texture0;
			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
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

				o.clipPos = TransformWorldToHClip( positionWS );
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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float PanningOnX74 = _PanningControl.x;
				float mulTime42 = _TimeParameters.x * PanningOnX74;
				float2 texCoord7 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6 = ( mulTime42 * float2( 1.5,0 ) + texCoord7);
				float temp_output_4_0_g13 = 1.0;
				float temp_output_5_0_g13 = 2.0;
				float2 appendResult7_g13 = (float2(temp_output_4_0_g13 , temp_output_5_0_g13));
				float totalFrames39_g13 = ( temp_output_4_0_g13 * temp_output_5_0_g13 );
				float2 appendResult8_g13 = (float2(totalFrames39_g13 , temp_output_5_0_g13));
				float FlashingOnX34 = sin( ( _TimeParameters.x * _FlashingControl.x ) );
				float clampResult42_g13 = clamp( 0.0 , 0.0001 , ( totalFrames39_g13 - 1.0 ) );
				float temp_output_35_0_g13 = frac( ( ( FlashingOnX34 + clampResult42_g13 ) / totalFrames39_g13 ) );
				float2 appendResult29_g13 = (float2(temp_output_35_0_g13 , ( 1.0 - temp_output_35_0_g13 )));
				float2 temp_output_15_0_g13 = ( ( panner6 / appendResult7_g13 ) + ( floor( ( appendResult8_g13 * appendResult29_g13 ) ) / appendResult7_g13 ) );
				float4 LightningX82 = ( tex2D( _Texture0, temp_output_15_0_g13 ) * FlashingOnX34 );
				float PanningOnY75 = _PanningControl.y;
				float mulTime62 = _TimeParameters.x * PanningOnY75;
				float2 texCoord61 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner60 = ( mulTime62 * float2( 1.5,0 ) + texCoord61);
				float temp_output_4_0_g12 = 1.0;
				float temp_output_5_0_g12 = 2.0;
				float2 appendResult7_g12 = (float2(temp_output_4_0_g12 , temp_output_5_0_g12));
				float totalFrames39_g12 = ( temp_output_4_0_g12 * temp_output_5_0_g12 );
				float2 appendResult8_g12 = (float2(totalFrames39_g12 , temp_output_5_0_g12));
				float FlashingOnY35 = sin( ( _TimeParameters.x * _FlashingControl.y ) );
				float clampResult42_g12 = clamp( 0.0 , 0.0001 , ( totalFrames39_g12 - 1.0 ) );
				float temp_output_35_0_g12 = frac( ( ( FlashingOnY35 + clampResult42_g12 ) / totalFrames39_g12 ) );
				float2 appendResult29_g12 = (float2(temp_output_35_0_g12 , ( 1.0 - temp_output_35_0_g12 )));
				float2 temp_output_15_0_g12 = ( ( panner60 / appendResult7_g12 ) + ( floor( ( appendResult8_g12 * appendResult29_g12 ) ) / appendResult7_g12 ) );
				float4 LightningY83 = ( tex2D( _Texture1, temp_output_15_0_g12 ) * FlashingOnY35 );
				float PanningOnZ76 = _PanningControl.z;
				float mulTime67 = _TimeParameters.x * PanningOnZ76;
				float2 texCoord66 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner65 = ( mulTime67 * float2( 1.5,0 ) + texCoord66);
				float temp_output_4_0_g15 = 1.0;
				float temp_output_5_0_g15 = 2.0;
				float2 appendResult7_g15 = (float2(temp_output_4_0_g15 , temp_output_5_0_g15));
				float totalFrames39_g15 = ( temp_output_4_0_g15 * temp_output_5_0_g15 );
				float2 appendResult8_g15 = (float2(totalFrames39_g15 , temp_output_5_0_g15));
				float FlashingOnZ36 = sin( ( _TimeParameters.x * _FlashingControl.z ) );
				float clampResult42_g15 = clamp( 0.0 , 0.0001 , ( totalFrames39_g15 - 1.0 ) );
				float temp_output_35_0_g15 = frac( ( ( FlashingOnZ36 + clampResult42_g15 ) / totalFrames39_g15 ) );
				float2 appendResult29_g15 = (float2(temp_output_35_0_g15 , ( 1.0 - temp_output_35_0_g15 )));
				float2 temp_output_15_0_g15 = ( ( panner65 / appendResult7_g15 ) + ( floor( ( appendResult8_g15 * appendResult29_g15 ) ) / appendResult7_g15 ) );
				float4 LightningZ84 = ( tex2D( _Texture2, temp_output_15_0_g15 ) * FlashingOnZ36 );
				float PanningOnW77 = _PanningControl.w;
				float mulTime72 = _TimeParameters.x * PanningOnW77;
				float2 texCoord71 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner70 = ( mulTime72 * float2( 1.5,0 ) + texCoord71);
				float temp_output_4_0_g14 = 1.0;
				float temp_output_5_0_g14 = 2.0;
				float2 appendResult7_g14 = (float2(temp_output_4_0_g14 , temp_output_5_0_g14));
				float totalFrames39_g14 = ( temp_output_4_0_g14 * temp_output_5_0_g14 );
				float2 appendResult8_g14 = (float2(totalFrames39_g14 , temp_output_5_0_g14));
				float FlashingOnW37 = sin( ( _TimeParameters.x * _FlashingControl.w ) );
				float clampResult42_g14 = clamp( 0.0 , 0.0001 , ( totalFrames39_g14 - 1.0 ) );
				float temp_output_35_0_g14 = frac( ( ( FlashingOnW37 + clampResult42_g14 ) / totalFrames39_g14 ) );
				float2 appendResult29_g14 = (float2(temp_output_35_0_g14 , ( 1.0 - temp_output_35_0_g14 )));
				float2 temp_output_15_0_g14 = ( ( panner70 / appendResult7_g14 ) + ( floor( ( appendResult8_g14 * appendResult29_g14 ) ) / appendResult7_g14 ) );
				float4 LightningW85 = ( tex2D( _Texture3, temp_output_15_0_g14 ) * FlashingOnW37 );
				float4 temp_output_94_0 = ( LightningX82 + LightningY83 + LightningZ84 + LightningW85 );
				float VertexAlpha104 = IN.ase_color.a;
				
				float Alpha = ( temp_output_94_0 * VertexAlpha104 ).r;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
0;0;1920;1019;1216.307;632.6894;1;True;False
Node;AmplifyShaderEditor.Vector4Node;73;-3315.745,-1152.894;Inherit;False;Property;_PanningControl;PanningControl;6;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.3,2,-5,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;19;-3331.053,-1473.101;Inherit;False;Property;_FlashingControl;FlashingControl;5;0;Create;True;0;0;0;False;0;False;10,10,10,10;20,10,15,30;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;23;-3326.974,-1564.331;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-3022.447,-1026.933;Inherit;False;PanningOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-3026.373,-1175.681;Inherit;False;PanningOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-3023.882,-953.2374;Inherit;False;PanningOnW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-3022.612,-1101.974;Inherit;False;PanningOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3119.312,-1593.912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-3108.706,-1291.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-3114.706,-1485.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-3110.706,-1390.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;22;-2991.619,-1590.715;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-4100.271,-169.5873;Inherit;False;74;PanningOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-4049.554,344.3157;Inherit;False;75;PanningOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-3948.914,765.3213;Inherit;False;76;PanningOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;29;-2981.014,-1488.188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;33;-2975.014,-1294.187;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;31;-2977.014,-1393.188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-3914.082,1178.894;Inherit;False;77;PanningOnW;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-3941.691,-289.0359;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-3890.809,229.0018;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;62;-3848.57,351.1389;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;67;-3756.269,768.3871;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;42;-3899.452,-166.8983;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-3798.508,646.2502;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;72;-3709.482,1183.483;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-2845.475,-1305.167;Inherit;False;FlashingOnW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;71;-3751.721,1061.346;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-2837.475,-1407.167;Inherit;False;FlashingOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2820.789,-1604.339;Inherit;False;FlashingOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2838.475,-1507.167;Inherit;False;FlashingOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;6;-3717.052,-287.689;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-2878.232,669.7006;Inherit;False;36;FlashingOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;60;-3666.171,230.3487;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-2872.54,248.4996;Inherit;False;35;FlashingOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;70;-3527.082,1062.693;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2886.77,-161.5635;Inherit;False;34;FlashingOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;65;-3573.87,647.5972;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-2871.117,1085.21;Inherit;False;37;FlashingOnW;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;-3315.43,469.5708;Inherit;True;Property;_Texture2;Texture 2;2;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;100;-3507.321,-231.7594;Inherit;True;Flipbook;-1;;13;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.FunctionNode;103;-3332.644,1059.787;Inherit;True;Flipbook;-1;;14;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.TexturePropertyNode;68;-3348.368,856.6018;Inherit;True;Property;_Texture3;Texture 3;3;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;101;-3398.572,192.9014;Inherit;True;Flipbook;-1;;12;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.TexturePropertyNode;8;-3466.344,-438.538;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;58;-3311.43,3.622608;Inherit;True;Property;_Texture1;Texture 1;1;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;102;-3389.456,654.0082;Inherit;True;Flipbook;-1;;15;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SamplerNode;5;-2993.662,-359.536;Inherit;True;Property;_MAT_VFX_LightningTrailSprite;MAT_VFX_LightningTrailSprite;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;69;-2969.273,856.1939;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-3000.448,473.3039;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-3000.448,57.35564;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2618.552,896.1849;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2629.823,67.31821;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-2657.535,-351.2506;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2637.264,470.4975;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2446.461,893.3379;Inherit;False;LightningW;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-2444.058,470.5509;Inherit;False;LightningZ;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;10;-3484.234,-944.7557;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2476.647,-357.0395;Inherit;False;LightningX;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-2440.848,65.74744;Inherit;False;LightningY;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-878.5009,-106.0758;Inherit;False;84;LightningZ;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-876.595,-24.1167;Inherit;False;85;LightningW;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-884.2191,-256.6517;Inherit;False;82;LightningX;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-880.4069,-182.3168;Inherit;False;83;LightningY;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-3311.249,-747.1311;Inherit;False;VertexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-527.8097,-190.5792;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-224.3073,-85.68939;Inherit;False;104;VertexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-3316.562,-665.512;Inherit;False;Property;_BaseColour;BaseColour;4;1;[HDR];Create;True;0;0;0;False;0;False;1,0.7529564,0,0;8.47419,2.040904,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;12;-509.4533,-398.782;Inherit;False;13;DiffuseColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-258.3548,-420.1605;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2936.307,-771.0378;Inherit;False;DiffuseColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-3089.454,-767.5526;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;1.692749,-194.6894;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;315.8877,-289.6062;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_LightningTrail;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;0;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637900016480046614;  Blend;0;0;Two Sided;0;637900053980865863;Cast Shadows;0;637912949157517372;  Use Shadow Threshold;0;0;Receive Shadows;0;637912949164160763;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;24.23426,-53.85387;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;76;0;73;3
WireConnection;74;0;73;1
WireConnection;77;0;73;4
WireConnection;75;0;73;2
WireConnection;24;0;23;0
WireConnection;24;1;19;1
WireConnection;32;0;23;0
WireConnection;32;1;19;4
WireConnection;28;0;23;0
WireConnection;28;1;19;2
WireConnection;30;0;23;0
WireConnection;30;1;19;3
WireConnection;22;0;24;0
WireConnection;29;0;28;0
WireConnection;33;0;32;0
WireConnection;31;0;30;0
WireConnection;62;0;91;0
WireConnection;67;0;92;0
WireConnection;42;0;90;0
WireConnection;72;0;93;0
WireConnection;37;0;33;0
WireConnection;36;0;31;0
WireConnection;34;0;22;0
WireConnection;35;0;29;0
WireConnection;6;0;7;0
WireConnection;6;1;42;0
WireConnection;60;0;61;0
WireConnection;60;1;62;0
WireConnection;70;0;71;0
WireConnection;70;1;72;0
WireConnection;65;0;66;0
WireConnection;65;1;67;0
WireConnection;100;13;6;0
WireConnection;100;2;86;0
WireConnection;103;13;70;0
WireConnection;103;2;89;0
WireConnection;101;13;60;0
WireConnection;101;2;87;0
WireConnection;102;13;65;0
WireConnection;102;2;88;0
WireConnection;5;0;8;0
WireConnection;5;1;100;0
WireConnection;69;0;68;0
WireConnection;69;1;103;0
WireConnection;64;0;63;0
WireConnection;64;1;102;0
WireConnection;59;0;58;0
WireConnection;59;1;101;0
WireConnection;81;0;69;0
WireConnection;81;1;89;0
WireConnection;79;0;59;0
WireConnection;79;1;87;0
WireConnection;78;0;5;0
WireConnection;78;1;86;0
WireConnection;80;0;64;0
WireConnection;80;1;88;0
WireConnection;85;0;81;0
WireConnection;84;0;80;0
WireConnection;82;0;78;0
WireConnection;83;0;79;0
WireConnection;104;0;10;4
WireConnection;94;0;95;0
WireConnection;94;1;96;0
WireConnection;94;2;97;0
WireConnection;94;3;98;0
WireConnection;99;0;12;0
WireConnection;99;1;94;0
WireConnection;13;0;11;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;105;0;94;0
WireConnection;105;1;106;0
WireConnection;1;2;99;0
WireConnection;1;3;105;0
ASEEND*/
//CHKSM=101DC2CCDF3328DF5CFDE21AF67F72293CAD0A52