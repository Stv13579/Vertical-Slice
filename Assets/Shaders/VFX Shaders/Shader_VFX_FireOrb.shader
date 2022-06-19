// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_FireOrb"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Noise_1_Scale("Noise_1_Scale", Float) = 3.38
		_MAT_VFX_FlameOrbSprite_Base_1("MAT_VFX_FlameOrbSprite_Base_1", 2D) = "white" {}
		_Voronoi_Speed("Voronoi_Speed", Float) = 5
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Cinders_2_Panning("Cinders_2_Panning", Vector) = (-0.1,-1,0,0)
		_BaseFire_2_Panning("BaseFire_2_Panning", Vector) = (-1,0,0,0)
		_BaseFire_1_Panning("BaseFire_1_Panning", Vector) = (1,0,0,0)
		_Cidners_1_Panning("Cidners_1_Panning", Vector) = (0.1,-2,0,0)
		_Voronoi_Scale("Voronoi_Scale", Float) = 5
		_Smoothstep_Fade("Smoothstep_Fade", Range( 0 , 100)) = 2
		_SmoothStep_Fill("SmoothStep_Fill", Range( -2 , 2)) = -2
		_RemapNews("Remap News", Vector) = (-3.14,1.95,0,0)
		_Flame2Remap("Flame 2 Remap", Vector) = (0,1,0,10)
		_Fres_Scale_MinNew("Fres_Scale_MinNew", Float) = 1
		_Fres_Power_MaxNew("Fres_Power_MaxNew", Float) = 5
		_Fres_Scale_MaxNew("Fres_Scale_MaxNew", Float) = 5
		_Fres_Power_MinNew("Fres_Power_MinNew", Float) = 1
		_Fres_ScaleX_PowerY_Speeds("Fres_Scale(X)_Power(Y)_Speeds", Vector) = (1,1,0,0)
		[HDR]_BaseColour("BaseColour", Color) = (1,1,1,0)
		_CutSmoothStep("CutSmoothStep", Range( 0 , 100)) = 0
		_FadeAwaySmoothstep("FadeAwaySmoothstep", Range( -2 , 2)) = -2
		_MAT_VFX_FlameOrbSprite_Embers_2("MAT_VFX_FlameOrbSprite_Embers_2", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_CindersBlinkSpeed("CindersBlinkSpeed", Float) = 1
		[ASEEnd]_Offset("Offset", Float) = 0

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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


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
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour;
			float4 _Flame2Remap;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float2 _BaseFire_1_Panning;
			float2 _Cinders_2_Panning;
			float2 _Cidners_1_Panning;
			float2 _BaseFire_2_Panning;
			float _FadeAwaySmoothstep;
			float _CindersBlinkSpeed;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Voronoi_Scale;
			float _Fres_Scale_MinNew;
			float _CutSmoothStep;
			float _Smoothstep_Fade;
			float _SmoothStep_Fill;
			float _Offset;
			float _Voronoi_Speed;
			float _Fres_Scale_MaxNew;
			float _Noise_1_Scale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MAT_VFX_FlameOrbSprite_Base_1;
			sampler2D _TextureSample0;
			sampler2D _TextureSample2;
			sampler2D _MAT_VFX_FlameOrbSprite_Embers_2;


					float2 voronoihash35( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi35( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash35( n + g );
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
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time35 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId35 = 0;
				float2 texCoord32 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords35 = texCoord32 * _Voronoi_Scale;
				float2 id35 = 0;
				float2 uv35 = 0;
				float fade35 = 0.5;
				float voroi35 = 0;
				float rest35 = 0;
				for( int it35 = 0; it35 <8; it35++ ){
				voroi35 += fade35 * voronoi35( coords35, time35, id35, uv35, 0,voronoiSmoothId35 );
				rest35 += fade35;
				coords35 *= 2;
				fade35 *= 0.5;
				}//Voronoi35
				voroi35 /= rest35;
				float Voronoi38 = (_RemapNews.x + (voroi35 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 temp_cast_0 = (( Voronoi38 * _Offset )).xxx;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_cast_0;
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
				float4 Colour77 = ( IN.ase_color * _BaseColour );
				float2 texCoord8 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner9 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord8);
				float time35 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId35 = 0;
				float2 texCoord32 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords35 = texCoord32 * _Voronoi_Scale;
				float2 id35 = 0;
				float2 uv35 = 0;
				float fade35 = 0.5;
				float voroi35 = 0;
				float rest35 = 0;
				for( int it35 = 0; it35 <8; it35++ ){
				voroi35 += fade35 * voronoi35( coords35, time35, id35, uv35, 0,voronoiSmoothId35 );
				rest35 += fade35;
				coords35 *= 2;
				fade35 *= 0.5;
				}//Voronoi35
				voroi35 /= rest35;
				float Voronoi38 = (_RemapNews.x + (voroi35 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 worldToObj19 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult25 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Voronoi38 + ( 1.0 - (0.0 + (worldToObj19.y - -1.0) * (2.6 - 0.0) / (1.0 - -1.0)) ) ));
				float Smoothstep43 = smoothstepResult25;
				float4 _Flame1Remap = float4(0,1,0,10);
				float4 temp_cast_0 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_1 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_2 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_3 = (_Flame1Remap.w).xxxx;
				float2 panner16 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord8);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV70 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode70 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV70, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float VoronoiOriginal82 = voroi35;
				float Fresnel_Pulse72 = ( fresnelNode70 * VoronoiOriginal82 );
				float2 texCoord128 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner131 = ( 1.0 * _Time.y * _Cidners_1_Panning + texCoord128);
				float2 panner130 = ( 1.0 * _Time.y * _Cinders_2_Panning + texCoord128);
				float4 Cinders140 = ( ( tex2D( _TextureSample2, panner131 ) + tex2D( _MAT_VFX_FlameOrbSprite_Embers_2, panner130 ) ) * abs( sin( ( _TimeParameters.x * _CindersBlinkSpeed ) ) ) );
				float4 temp_output_54_0 = ( (temp_cast_2 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner9 ) * Smoothstep43 ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner16 ).r * Smoothstep43 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) + Fresnel_Pulse72 + Cinders140 );
				
				float4 temp_cast_5 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_6 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_7 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_8 = (_Flame1Remap.w).xxxx;
				float3 worldToObj97 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner100 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj97.xy);
				float simplePerlin3D102 = snoise( float3( panner100 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D102 = simplePerlin3D102*0.5 + 0.5;
				float Noise_1103 = simplePerlin3D102;
				float3 worldToObj85 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult94 = smoothstep( _FadeAwaySmoothstep , ( _FadeAwaySmoothstep + _CutSmoothStep ) , ( Noise_1103 + ( 1.0 - (0.0 + (worldToObj85.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha95 = smoothstepResult94;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Colour77 * temp_output_54_0 ).rgb;
				float Alpha = ( temp_output_54_0 * DisolveAlpha95 ).r;
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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour;
			float4 _Flame2Remap;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float2 _BaseFire_1_Panning;
			float2 _Cinders_2_Panning;
			float2 _Cidners_1_Panning;
			float2 _BaseFire_2_Panning;
			float _FadeAwaySmoothstep;
			float _CindersBlinkSpeed;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Voronoi_Scale;
			float _Fres_Scale_MinNew;
			float _CutSmoothStep;
			float _Smoothstep_Fade;
			float _SmoothStep_Fill;
			float _Offset;
			float _Voronoi_Speed;
			float _Fres_Scale_MaxNew;
			float _Noise_1_Scale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MAT_VFX_FlameOrbSprite_Base_1;
			sampler2D _TextureSample0;
			sampler2D _TextureSample2;
			sampler2D _MAT_VFX_FlameOrbSprite_Embers_2;


					float2 voronoihash35( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi35( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash35( n + g );
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
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time35 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId35 = 0;
				float2 texCoord32 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords35 = texCoord32 * _Voronoi_Scale;
				float2 id35 = 0;
				float2 uv35 = 0;
				float fade35 = 0.5;
				float voroi35 = 0;
				float rest35 = 0;
				for( int it35 = 0; it35 <8; it35++ ){
				voroi35 += fade35 * voronoi35( coords35, time35, id35, uv35, 0,voronoiSmoothId35 );
				rest35 += fade35;
				coords35 *= 2;
				fade35 *= 0.5;
				}//Voronoi35
				voroi35 /= rest35;
				float Voronoi38 = (_RemapNews.x + (voroi35 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 temp_cast_0 = (( Voronoi38 * _Offset )).xxx;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_cast_0;
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

				float2 texCoord8 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner9 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord8);
				float time35 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId35 = 0;
				float2 texCoord32 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords35 = texCoord32 * _Voronoi_Scale;
				float2 id35 = 0;
				float2 uv35 = 0;
				float fade35 = 0.5;
				float voroi35 = 0;
				float rest35 = 0;
				for( int it35 = 0; it35 <8; it35++ ){
				voroi35 += fade35 * voronoi35( coords35, time35, id35, uv35, 0,voronoiSmoothId35 );
				rest35 += fade35;
				coords35 *= 2;
				fade35 *= 0.5;
				}//Voronoi35
				voroi35 /= rest35;
				float Voronoi38 = (_RemapNews.x + (voroi35 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 worldToObj19 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult25 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Voronoi38 + ( 1.0 - (0.0 + (worldToObj19.y - -1.0) * (2.6 - 0.0) / (1.0 - -1.0)) ) ));
				float Smoothstep43 = smoothstepResult25;
				float4 _Flame1Remap = float4(0,1,0,10);
				float4 temp_cast_0 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_1 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_2 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_3 = (_Flame1Remap.w).xxxx;
				float2 panner16 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord8);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV70 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode70 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV70, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float VoronoiOriginal82 = voroi35;
				float Fresnel_Pulse72 = ( fresnelNode70 * VoronoiOriginal82 );
				float2 texCoord128 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner131 = ( 1.0 * _Time.y * _Cidners_1_Panning + texCoord128);
				float2 panner130 = ( 1.0 * _Time.y * _Cinders_2_Panning + texCoord128);
				float4 Cinders140 = ( ( tex2D( _TextureSample2, panner131 ) + tex2D( _MAT_VFX_FlameOrbSprite_Embers_2, panner130 ) ) * abs( sin( ( _TimeParameters.x * _CindersBlinkSpeed ) ) ) );
				float4 temp_output_54_0 = ( (temp_cast_2 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner9 ) * Smoothstep43 ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner16 ).r * Smoothstep43 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) + Fresnel_Pulse72 + Cinders140 );
				float3 worldToObj97 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner100 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj97.xy);
				float simplePerlin3D102 = snoise( float3( panner100 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D102 = simplePerlin3D102*0.5 + 0.5;
				float Noise_1103 = simplePerlin3D102;
				float3 worldToObj85 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult94 = smoothstep( _FadeAwaySmoothstep , ( _FadeAwaySmoothstep + _CutSmoothStep ) , ( Noise_1103 + ( 1.0 - (0.0 + (worldToObj85.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha95 = smoothstepResult94;
				
				float Alpha = ( temp_output_54_0 * DisolveAlpha95 ).r;
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
92;203;1920;970;-13.16797;456.6982;1;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;30;-1058.964,1426.913;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1056.841,1507.611;Inherit;False;Property;_Voronoi_Speed;Voronoi_Speed;2;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-858.5065,1527.7;Inherit;False;Property;_Voronoi_Scale;Voronoi_Scale;8;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-836.5345,1430.549;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-918.1747,1308.128;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;26;-1439.108,894.7792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;56;-1329.977,1941.477;Inherit;False;Property;_Fres_ScaleX_PowerY_Speeds;Fres_Scale(X)_Power(Y)_Speeds;17;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;57;-1206.671,1874.914;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;19;-1247.78,905.531;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VoronoiNode;35;-647.3815,1400.093;Inherit;True;0;0;1;3;8;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.Vector2Node;36;-651.3947,1664.121;Inherit;False;Property;_RemapNews;Remap News;11;0;Create;True;0;0;0;False;0;False;-3.14,1.95;0,1.85;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-1036.319,918.0328;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1008.184,2046.791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-444.2006,1431.926;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1005.009,1812.333;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;96;-1553.337,2788.4;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;97;-1388.636,2785.307;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;98;-1351.92,3069.144;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;99;-1358.866,2946.803;Inherit;False;Constant;_Noise_1_Speed;Noise_1_Speed;2;0;Create;True;0;0;0;False;0;False;-0.4,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;60;-870.3156,1817.53;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;84;-1652.625,2426.138;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;61;-873.4906,2051.988;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;-823.0355,938.3843;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;2.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-159.4621,1416.175;Inherit;True;Voronoi;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;129;-2655.797,32.70087;Inherit;False;Property;_Cinders_2_Panning;Cinders_2_Panning;4;0;Create;True;0;0;0;False;0;False;-0.1,-1;-0.1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;23;-639.1735,1027.611;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;100;-1139.843,2904.894;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-642.7145,941.1348;Inherit;False;38;Voronoi;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;85;-1476.788,2418.198;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;101;-1140.006,3024.211;Inherit;False;Property;_Noise_1_Scale;Noise_1_Scale;0;0;Create;True;0;0;0;False;0;False;3.38;3.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;128;-2658.65,-210.7017;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;127;-2658.14,-89.18122;Inherit;False;Property;_Cidners_1_Panning;Cidners_1_Panning;7;0;Create;True;0;0;0;False;0;False;0.1,-2;0.1,-2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;146;-2427.298,273.2727;Inherit;False;Property;_CindersBlinkSpeed;CindersBlinkSpeed;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;145;-2406.378,152.9836;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-946.6447,1135.866;Inherit;False;Property;_SmoothStep_Fill;SmoothStep_Fill;10;0;Create;True;0;0;0;False;0;False;-2;-0.538033;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;64;-755.8417,2056.717;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-880.1547,2202.935;Inherit;False;Property;_Fres_Power_MaxNew;Fres_Power_MaxNew;14;0;Create;True;0;0;0;False;0;False;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-944.6447,1214.864;Inherit;False;Property;_Smoothstep_Fade;Smoothstep_Fade;9;0;Create;True;0;0;0;False;0;False;2;2.409762;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-876.9786,1895.477;Inherit;False;Property;_Fres_Scale_MinNew;Fres_Scale_MinNew;13;0;Create;True;0;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-880.1547,2129.935;Inherit;False;Property;_Fres_Power_MinNew;Fres_Power_MinNew;16;0;Create;True;0;0;0;False;0;False;1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;63;-752.6647,1822.259;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-877.9786,1968.477;Inherit;False;Property;_Fres_Scale_MaxNew;Fres_Scale_MaxNew;15;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;86;-1265.327,2427.521;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PannerNode;131;-2307.146,-140.2987;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-425.4106,1323.976;Inherit;False;VoronoiOriginal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-416.6945,972.8508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2189.858,209.4671;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;130;-2299.526,10.43398;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-452.1525,1156.258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;68;-624.8417,2058.717;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;69;-637.6647,1827.26;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;102;-959.9241,2957.213;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-769.8654,2962.807;Inherit;False;Noise_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;15;-1586.821,-373.9455;Inherit;False;Property;_BaseFire_1_Panning;BaseFire_1_Panning;6;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;126;-2065.27,-209.0154;Inherit;True;Property;_TextureSample2;Texture Sample 2;22;0;Create;True;0;0;0;False;0;False;-1;fb1989d88b7781643a7a881847abc030;f64f6159c74584f4eb4572ef56188c22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;87;-1052.043,2447.872;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1587.331,-495.466;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;148;-2037.144,210.5132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-365.1486,2087.762;Inherit;False;82;VoronoiOriginal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;17;-1584.478,-252.0634;Inherit;False;Property;_BaseFire_2_Panning;BaseFire_2_Panning;5;0;Create;True;0;0;0;False;0;False;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;25;-239.8498,990.5527;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1.63;False;2;FLOAT;1.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;70;-437.1056,1873.833;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;144;-2086.901,7.622363;Inherit;True;Property;_MAT_VFX_FlameOrbSprite_Embers_2;MAT_VFX_FlameOrbSprite_Embers_2;21;0;Create;True;0;0;0;False;0;False;-1;f64f6159c74584f4eb4572ef56188c22;fb1989d88b7781643a7a881847abc030;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;-1179.982,2645.354;Inherit;False;Property;_FadeAwaySmoothstep;FadeAwaySmoothstep;20;0;Create;True;0;0;0;False;0;False;-2;-2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-93.17368,1875.179;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-1713.285,-79.42743;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1173.652,2725.354;Inherit;False;Property;_CutSmoothStep;CutSmoothStep;19;0;Create;True;0;0;0;False;0;False;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-4.889102,974.441;Inherit;False;Smoothstep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;16;-1228.207,-274.3303;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;88;-868.1798,2537.1;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;149;-1914.763,214.6971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-867.952,2461.754;Inherit;False;103;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;9;-1235.827,-425.063;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-684.6991,2495.739;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-874.5679,-536.1261;Inherit;False;43;Smoothstep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-913.3743,-7.64888;Inherit;False;43;Smoothstep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-953.4634,-434.0188;Inherit;True;Property;_MAT_VFX_FlameOrbSprite_Base_1;MAT_VFX_FlameOrbSprite_Base_1;1;0;Create;True;0;0;0;False;0;False;-1;de68d8344b3bf444c88752a1e7691c07;de68d8344b3bf444c88752a1e7691c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-1490.091,-26.92687;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-679.4818,2661.934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-948.7759,-231.4425;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;88fe50336f30e04478eb04534ac134a4;88fe50336f30e04478eb04534ac134a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;71;133.4667,1878.786;Inherit;True;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;94;-494.4301,2500.441;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1.63;False;2;FLOAT;1.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-575.3721,-219.039;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-1252.516,3.743851;Inherit;False;Cinders;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;52;-558.0068,-393.3242;Inherit;False;Constant;_Flame1Remap;Flame 1 Remap;6;0;Create;True;0;0;0;False;0;False;0,1,0,10;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-589.8074,-618.9565;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;49;-546.7863,11.5929;Inherit;False;Property;_Flame2Remap;Flame 2 Remap;12;0;Create;True;0;0;0;False;0;False;0,1,0,10;0,1,0,10;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;372.2188,1881.806;Inherit;False;Fresnel_Pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;48;-219.076,-207.3753;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;51;-214.8316,-431.4842;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-155.277,16.15678;Inherit;False;72;Fresnel_Pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-124.1346,100.1317;Inherit;False;140;Cinders;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-238.987,2506.849;Inherit;False;DisolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;743.168,-129.6982;Inherit;True;38;Voronoi;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;788.168,78.30182;Inherit;False;Property;_Offset;Offset;24;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;574.1094,-230.5703;Inherit;False;95;DisolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;128.3194,-354.4412;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-100.6411,-1023.582;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;789.4801,-351.3452;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;380.8818,-536.1365;Inherit;False;77;Colour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;612.8818,-494.1365;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;75;-387.5312,-967.487;Inherit;False;Property;_BaseColour;BaseColour;18;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.9883373,0.1759344,0.06209449,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;74;-385.7297,-1159.61;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;982.168,-60.69818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;57.35889,-1011.582;Inherit;False;Colour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1218.349,-368.2207;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_FireOrb;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637911451554347671;  Blend;0;637911465458744339;Two Sided;1;637911461748083334;Cast Shadows;0;637911451656369085;  Use Shadow Threshold;0;0;Receive Shadows;0;637911451650319829;GPU Instancing;1;0;LOD CrossFade;0;637911451592529888;Built-in Fog;0;637911451598817122;DOTS Instancing;0;637911451606738440;Meta Pass;0;637911451621082308;Extra Pre Pass;0;637911451631180775;Tessellation;0;637911451641059433;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
WireConnection;34;0;30;0
WireConnection;34;1;31;0
WireConnection;19;0;26;0
WireConnection;35;0;32;0
WireConnection;35;1;34;0
WireConnection;35;2;33;0
WireConnection;20;0;19;0
WireConnection;58;0;57;0
WireConnection;58;1;56;2
WireConnection;37;0;35;0
WireConnection;37;3;36;1
WireConnection;37;4;36;2
WireConnection;59;0;57;0
WireConnection;59;1;56;1
WireConnection;97;0;96;0
WireConnection;60;0;59;0
WireConnection;61;0;58;0
WireConnection;21;0;20;1
WireConnection;38;0;37;0
WireConnection;23;0;21;0
WireConnection;100;0;97;0
WireConnection;100;2;99;0
WireConnection;100;1;98;0
WireConnection;85;0;84;0
WireConnection;64;0;61;0
WireConnection;63;0;60;0
WireConnection;86;0;85;0
WireConnection;131;0;128;0
WireConnection;131;2;127;0
WireConnection;82;0;35;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;130;0;128;0
WireConnection;130;2;129;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;68;0;64;0
WireConnection;68;3;67;0
WireConnection;68;4;65;0
WireConnection;69;0;63;0
WireConnection;69;3;62;0
WireConnection;69;4;66;0
WireConnection;102;0;100;0
WireConnection;102;1;101;0
WireConnection;103;0;102;0
WireConnection;126;1;131;0
WireConnection;87;0;86;1
WireConnection;148;0;147;0
WireConnection;25;0;24;0
WireConnection;25;1;27;0
WireConnection;25;2;29;0
WireConnection;70;2;69;0
WireConnection;70;3;68;0
WireConnection;144;1;130;0
WireConnection;81;0;70;0
WireConnection;81;1;83;0
WireConnection;143;0;126;0
WireConnection;143;1;144;0
WireConnection;43;0;25;0
WireConnection;16;0;8;0
WireConnection;16;2;17;0
WireConnection;88;0;87;0
WireConnection;149;0;148;0
WireConnection;9;0;8;0
WireConnection;9;2;15;0
WireConnection;92;0;90;0
WireConnection;92;1;88;0
WireConnection;5;1;9;0
WireConnection;151;0;143;0
WireConnection;151;1;149;0
WireConnection;93;0;91;0
WireConnection;93;1;89;0
WireConnection;13;1;16;0
WireConnection;71;0;81;0
WireConnection;94;0;92;0
WireConnection;94;1;91;0
WireConnection;94;2;93;0
WireConnection;47;0;13;1
WireConnection;47;1;44;0
WireConnection;140;0;151;0
WireConnection;50;0;5;0
WireConnection;50;1;53;0
WireConnection;72;0;71;0
WireConnection;48;0;47;0
WireConnection;48;1;49;1
WireConnection;48;2;49;2
WireConnection;48;3;49;3
WireConnection;48;4;49;4
WireConnection;51;0;50;0
WireConnection;51;1;52;1
WireConnection;51;2;52;2
WireConnection;51;3;52;3
WireConnection;51;4;52;4
WireConnection;95;0;94;0
WireConnection;54;0;51;0
WireConnection;54;1;48;0
WireConnection;54;2;73;0
WireConnection;54;3;133;0
WireConnection;76;0;74;0
WireConnection;76;1;75;0
WireConnection;104;0;54;0
WireConnection;104;1;105;0
WireConnection;78;0;79;0
WireConnection;78;1;54;0
WireConnection;154;0;152;0
WireConnection;154;1;153;0
WireConnection;77;0;76;0
WireConnection;1;2;78;0
WireConnection;1;3;104;0
WireConnection;1;5;154;0
ASEEND*/
//CHKSM=2ADCF71978978EE9FB1D969670AB3FD49EEA13EF