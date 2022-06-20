// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_LaserbeamOrb"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Noise_1_Scale("Noise_1_Scale", Float) = 3.38
		_Float0("Float 0", Float) = 1
		_MAT_VFX_FlameOrbSprite_Base_1("MAT_VFX_FlameOrbSprite_Base_1", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		_Voronoi_Speed("Voronoi_Speed", Float) = 5
		_Texture2("Texture 2", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_BaseFire_2_Panning("BaseFire_2_Panning", Vector) = (-1,0,0,0)
		_BaseFire_1_Panning("BaseFire_1_Panning", Vector) = (1,0,0,0)
		_Voronoi_Scale("Voronoi_Scale", Float) = 5
		_Flashing_MainXYZ("Flashing_Main (XYZ)", Vector) = (1,1,1,0)
		_Fres_2_Scale_MinNew("Fres_2_Scale_MinNew", Float) = 1
		_TopFade("TopFade", Range( -100 , 100)) = 0
		_Fres_2_Power_MaxNew("Fres_2_Power_MaxNew", Float) = 5
		_Panning_MainXYZ("Panning_Main (XYZ)", Vector) = (1,1,1,0)
		_Flame2Remap("Flame 2 Remap", Vector) = (0,1,0,1.5)
		_Fres_Scale_MaxNew1("Fres_Scale_MaxNew", Float) = 5
		_Fres_2_Power_MinNew("Fres_2_Power_MinNew", Float) = 1
		[HDR]_LightningColour_1("LightningColour_1", Color) = (1,1,1,0)
		_Fres_2_ScaleX_PowerY_Speeds("Fres_2_Scale(X)_Power(Y)_Speeds", Vector) = (1,1,0,0)
		_TopCull("TopCull", Range( 0 , 1)) = 1
		_RemapNews("Remap News", Vector) = (0,0,0,0)
		[HDR]_LightningColour_2("LightningColour_2", Color) = (1,1,1,0)
		_BottomCull("BottomCull", Range( 0 , 1)) = 0.1294118
		_Fres_Scale_MinNew("Fres_Scale_MinNew", Float) = 1
		_BottomFade("BottomFade", Range( -100 , 100)) = -0.5
		_Fres_Power_MaxNew("Fres_Power_MaxNew", Float) = 5
		_Fres_Scale_MaxNew("Fres_Scale_MaxNew", Float) = 5
		_Fres_Power_MinNew("Fres_Power_MinNew", Float) = 1
		_Fres_ScaleX_PowerY_Speeds("Fres_Scale(X)_Power(Y)_Speeds", Vector) = (1,1,0,0)
		[ASEEnd][HDR]_FireColour("FireColour", Color) = (0.990566,0.2478243,0,0)

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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


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
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _LightningColour_1;
			float4 _FireColour;
			float4 _LightningColour_2;
			float4 _Flame2Remap;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float2 _Fres_2_ScaleX_PowerY_Speeds;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float2 _BaseFire_1_Panning;
			float2 _BaseFire_2_Panning;
			float _Fres_Scale_MaxNew1;
			float _Fres_2_Power_MaxNew;
			float _Fres_2_Scale_MinNew;
			float _BottomFade;
			float _BottomCull;
			float _Fres_2_Power_MinNew;
			float _Fres_Power_MinNew;
			float _Fres_Power_MaxNew;
			float _Voronoi_Scale;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _TopFade;
			float _TopCull;
			float _Noise_1_Scale;
			float _Float0;
			float _Voronoi_Speed;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Texture1;
			sampler2D _Texture3;
			sampler2D _Texture2;
			sampler2D _MAT_VFX_FlameOrbSprite_Base_1;
			sampler2D _TextureSample0;


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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			
					float2 voronoihash10( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi10( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash10( n + g );
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
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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
				float4 LightingColour1153 = ( IN.ase_color * _LightningColour_1 );
				float PanningOnX112 = _Panning_MainXYZ.x;
				float mulTime118 = _TimeParameters.x * PanningOnX112;
				float2 texCoord121 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner123 = ( mulTime118 * float2( 1.5,0.3 ) + texCoord121);
				float FlashingOnX107 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X138 = ( tex2D( _Texture1, panner123 ) * FlashingOnX107 );
				float PanningOnY111 = _Panning_MainXYZ.y;
				float mulTime120 = _TimeParameters.x * PanningOnY111;
				float2 texCoord122 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner128 = ( mulTime120 * float2( 0,1.5 ) + texCoord122);
				float FlashingOnY108 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y140 = ( tex2D( _Texture3, panner128 ) * FlashingOnY108 );
				float PanningOnZ110 = _Panning_MainXYZ.z;
				float mulTime114 = _TimeParameters.x * PanningOnZ110;
				float2 texCoord116 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner119 = ( mulTime114 * float2( 1.5,0 ) + texCoord116);
				float temp_output_4_0_g9 = 1.0;
				float temp_output_5_0_g9 = 2.0;
				float2 appendResult7_g9 = (float2(temp_output_4_0_g9 , temp_output_5_0_g9));
				float totalFrames39_g9 = ( temp_output_4_0_g9 * temp_output_5_0_g9 );
				float2 appendResult8_g9 = (float2(totalFrames39_g9 , temp_output_5_0_g9));
				float clampResult42_g9 = clamp( 0.0 , 0.0001 , ( totalFrames39_g9 - 1.0 ) );
				float temp_output_35_0_g9 = frac( ( ( _TimeParameters.x + clampResult42_g9 ) / totalFrames39_g9 ) );
				float2 appendResult29_g9 = (float2(temp_output_35_0_g9 , ( 1.0 - temp_output_35_0_g9 )));
				float2 temp_output_15_0_g9 = ( ( panner119 / appendResult7_g9 ) + ( floor( ( appendResult8_g9 * appendResult29_g9 ) ) / appendResult7_g9 ) );
				float FlashingOnZ95 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z139 = ( tex2D( _Texture2, temp_output_15_0_g9 ) * FlashingOnZ95 );
				float4 temp_output_162_0 = ( LightningMain_X138 + LightningMain_Y140 + LightningMain_Z139 );
				float4 FireColour34 = ( IN.ase_color * _FireColour );
				float2 texCoord16 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner18 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord16);
				float3 worldToObj142 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner145 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj142.xy);
				float simplePerlin3D147 = snoise( float3( panner145 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D147 = simplePerlin3D147*0.5 + 0.5;
				float Noise_1148 = simplePerlin3D147;
				float4 _Flame1Remap = float4(0,1,0,1.5);
				float4 temp_cast_2 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_3 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_4 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_5 = (_Flame1Remap.w).xxxx;
				float2 panner17 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord16);
				float4 Fire31 = ( (temp_cast_4 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner18 ) * Noise_1148 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner17 ).r * Noise_1148 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) );
				float3 worldToObj38 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float temp_output_50_0 = ( worldToObj38.y * 0.88 );
				float smoothstepResult56 = smoothstep( _TopCull , _TopFade , ( 1.0 - temp_output_50_0 ));
				float TopCull51 = smoothstepResult56;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV82 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode82 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV82, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float2 texCoord175 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv178 = 0;
				float3 unityVoronoy178 = UnityVoronoi(texCoord175,( _TimeParameters.x * _Float0 ),10.0,uv178);
				float Voronoi_2183 = (_RemapNews.x + (unityVoronoy178.x - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float Fresnel_Pulse88 = ( fresnelNode82 * Voronoi_2183 );
				float temp_output_53_0 = ( TopCull51 * Fresnel_Pulse88 );
				float4 LightningColour2154 = ( IN.ase_color * _LightningColour_2 );
				float smoothstepResult41 = smoothstep( _BottomCull , _BottomFade , temp_output_50_0);
				float BottomCull45 = smoothstepResult41;
				float temp_output_54_0 = ( BottomCull45 * Fresnel_Pulse88 );
				float4 Fresnel48 = ( ( temp_output_53_0 * LightningColour2154 ) + ( temp_output_54_0 * FireColour34 ) );
				float fresnelNdotV199 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode199 = ( 0.0 + (_Fres_2_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_2_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew1 - _Fres_2_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV199, (_Fres_2_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_2_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_2_Power_MaxNew - _Fres_2_Power_MinNew) / (1.0 - 0.0)) ) );
				float time10 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId10 = 0;
				float2 texCoord7 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords10 = texCoord7 * _Voronoi_Scale;
				float2 id10 = 0;
				float2 uv10 = 0;
				float fade10 = 0.5;
				float voroi10 = 0;
				float rest10 = 0;
				for( int it10 = 0; it10 <8; it10++ ){
				voroi10 += fade10 * voronoi10( coords10, time10, id10, uv10, 0,voronoiSmoothId10 );
				rest10 += fade10;
				coords10 *= 2;
				fade10 *= 0.5;
				}//Voronoi10
				voroi10 /= rest10;
				float VoronoiOriginal29 = voroi10;
				float Fresnel_PulseFire202 = ( fresnelNode199 * VoronoiOriginal29 );
				
				float FresnelNoColour206 = ( temp_output_53_0 + temp_output_54_0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( LightingColour1153 * temp_output_162_0 ) + ( FireColour34 * Fire31 ) + Fresnel48 + ( Fresnel_PulseFire202 * FireColour34 ) ).rgb;
				float Alpha = ( temp_output_162_0 + Fire31 + Fresnel_PulseFire202 + FresnelNoColour206 ).r;
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
			float4 _LightningColour_1;
			float4 _FireColour;
			float4 _LightningColour_2;
			float4 _Flame2Remap;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float2 _Fres_2_ScaleX_PowerY_Speeds;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float2 _BaseFire_1_Panning;
			float2 _BaseFire_2_Panning;
			float _Fres_Scale_MaxNew1;
			float _Fres_2_Power_MaxNew;
			float _Fres_2_Scale_MinNew;
			float _BottomFade;
			float _BottomCull;
			float _Fres_2_Power_MinNew;
			float _Fres_Power_MinNew;
			float _Fres_Power_MaxNew;
			float _Voronoi_Scale;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _TopFade;
			float _TopCull;
			float _Noise_1_Scale;
			float _Float0;
			float _Voronoi_Speed;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Texture1;
			sampler2D _Texture3;
			sampler2D _Texture2;
			sampler2D _MAT_VFX_FlameOrbSprite_Base_1;
			sampler2D _TextureSample0;


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
			
					float2 voronoihash10( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi10( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash10( n + g );
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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float PanningOnX112 = _Panning_MainXYZ.x;
				float mulTime118 = _TimeParameters.x * PanningOnX112;
				float2 texCoord121 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner123 = ( mulTime118 * float2( 1.5,0.3 ) + texCoord121);
				float FlashingOnX107 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X138 = ( tex2D( _Texture1, panner123 ) * FlashingOnX107 );
				float PanningOnY111 = _Panning_MainXYZ.y;
				float mulTime120 = _TimeParameters.x * PanningOnY111;
				float2 texCoord122 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner128 = ( mulTime120 * float2( 0,1.5 ) + texCoord122);
				float FlashingOnY108 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y140 = ( tex2D( _Texture3, panner128 ) * FlashingOnY108 );
				float PanningOnZ110 = _Panning_MainXYZ.z;
				float mulTime114 = _TimeParameters.x * PanningOnZ110;
				float2 texCoord116 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner119 = ( mulTime114 * float2( 1.5,0 ) + texCoord116);
				float temp_output_4_0_g9 = 1.0;
				float temp_output_5_0_g9 = 2.0;
				float2 appendResult7_g9 = (float2(temp_output_4_0_g9 , temp_output_5_0_g9));
				float totalFrames39_g9 = ( temp_output_4_0_g9 * temp_output_5_0_g9 );
				float2 appendResult8_g9 = (float2(totalFrames39_g9 , temp_output_5_0_g9));
				float clampResult42_g9 = clamp( 0.0 , 0.0001 , ( totalFrames39_g9 - 1.0 ) );
				float temp_output_35_0_g9 = frac( ( ( _TimeParameters.x + clampResult42_g9 ) / totalFrames39_g9 ) );
				float2 appendResult29_g9 = (float2(temp_output_35_0_g9 , ( 1.0 - temp_output_35_0_g9 )));
				float2 temp_output_15_0_g9 = ( ( panner119 / appendResult7_g9 ) + ( floor( ( appendResult8_g9 * appendResult29_g9 ) ) / appendResult7_g9 ) );
				float FlashingOnZ95 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z139 = ( tex2D( _Texture2, temp_output_15_0_g9 ) * FlashingOnZ95 );
				float4 temp_output_162_0 = ( LightningMain_X138 + LightningMain_Y140 + LightningMain_Z139 );
				float2 texCoord16 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner18 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord16);
				float3 worldToObj142 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner145 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj142.xy);
				float simplePerlin3D147 = snoise( float3( panner145 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D147 = simplePerlin3D147*0.5 + 0.5;
				float Noise_1148 = simplePerlin3D147;
				float4 _Flame1Remap = float4(0,1,0,1.5);
				float4 temp_cast_2 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_3 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_4 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_5 = (_Flame1Remap.w).xxxx;
				float2 panner17 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord16);
				float4 Fire31 = ( (temp_cast_4 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner18 ) * Noise_1148 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner17 ).r * Noise_1148 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV199 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode199 = ( 0.0 + (_Fres_2_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_2_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew1 - _Fres_2_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV199, (_Fres_2_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_2_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_2_Power_MaxNew - _Fres_2_Power_MinNew) / (1.0 - 0.0)) ) );
				float time10 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId10 = 0;
				float2 texCoord7 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords10 = texCoord7 * _Voronoi_Scale;
				float2 id10 = 0;
				float2 uv10 = 0;
				float fade10 = 0.5;
				float voroi10 = 0;
				float rest10 = 0;
				for( int it10 = 0; it10 <8; it10++ ){
				voroi10 += fade10 * voronoi10( coords10, time10, id10, uv10, 0,voronoiSmoothId10 );
				rest10 += fade10;
				coords10 *= 2;
				fade10 *= 0.5;
				}//Voronoi10
				voroi10 /= rest10;
				float VoronoiOriginal29 = voroi10;
				float Fresnel_PulseFire202 = ( fresnelNode199 * VoronoiOriginal29 );
				float3 worldToObj38 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float temp_output_50_0 = ( worldToObj38.y * 0.88 );
				float smoothstepResult56 = smoothstep( _TopCull , _TopFade , ( 1.0 - temp_output_50_0 ));
				float TopCull51 = smoothstepResult56;
				float fresnelNdotV82 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode82 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV82, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float2 texCoord175 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv178 = 0;
				float3 unityVoronoy178 = UnityVoronoi(texCoord175,( _TimeParameters.x * _Float0 ),10.0,uv178);
				float Voronoi_2183 = (_RemapNews.x + (unityVoronoy178.x - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float Fresnel_Pulse88 = ( fresnelNode82 * Voronoi_2183 );
				float temp_output_53_0 = ( TopCull51 * Fresnel_Pulse88 );
				float smoothstepResult41 = smoothstep( _BottomCull , _BottomFade , temp_output_50_0);
				float BottomCull45 = smoothstepResult41;
				float temp_output_54_0 = ( BottomCull45 * Fresnel_Pulse88 );
				float FresnelNoColour206 = ( temp_output_53_0 + temp_output_54_0 );
				
				float Alpha = ( temp_output_162_0 + Fire31 + Fresnel_PulseFire202 + FresnelNoColour206 ).r;
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
0;0;1920;1019;-55.98701;2062.68;1.690906;True;False
Node;AmplifyShaderEditor.CommentaryNode;157;1669.027,-3171.993;Inherit;False;3557.792;1493.187;Combine;67;0;2;3;4;36;37;38;39;40;41;42;43;45;47;48;49;50;51;52;53;54;56;57;60;63;66;68;69;71;72;73;77;83;55;46;44;58;62;65;70;78;82;84;86;88;59;61;64;67;74;75;76;79;80;81;85;87;141;142;143;144;145;146;147;148;204;206;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;156;-610.7191,-3192.29;Inherit;False;2236.429;1311.073;FireSection;35;14;15;16;17;18;20;21;23;24;25;27;28;30;31;19;22;26;5;6;7;8;9;10;29;173;174;175;176;177;178;179;180;181;182;183;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;58;1842.333,-3059.412;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;60;1719.027,-2992.849;Inherit;False;Property;_Fres_ScaleX_PowerY_Speeds;Fres_Scale(X)_Power(Y)_Speeds;34;0;Create;True;0;0;0;False;0;False;1,1;10,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;174;535.3541,-2145.337;Inherit;False;Property;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;173;545.3541,-2216.337;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;639.2291,-2347.729;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;2043.994,-3121.993;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;720.3531,-2114.337;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;2040.819,-2887.535;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;725.3531,-2216.337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;178;914.5062,-2246.794;Inherit;True;0;0;1;3;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SinOpNode;66;2175.513,-2882.338;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;65;2178.687,-3116.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;179;1194.389,-2022.132;Inherit;False;Property;_RemapNews;Remap News;24;0;Create;True;0;0;0;False;0;False;0,0;0,1.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;155;-3484.479,-3202.703;Inherit;False;2819.501;1377.382;LightningSection;52;113;114;115;116;119;120;122;124;125;127;128;129;130;132;133;135;137;139;140;117;118;121;123;126;131;134;136;138;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;106;107;108;109;110;111;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;3986.317,-2153.055;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;70;2296.338,-3112.067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;2168.849,-2731.391;Inherit;False;Property;_Fres_Power_MaxNew;Fres_Power_MaxNew;29;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;37;2184.862,-2494.834;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;109;-2649.866,-2698.514;Inherit;False;Property;_Panning_MainXYZ;Panning_Main (XYZ);16;0;Create;True;0;0;0;False;0;False;1,1,1;-2,1,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;71;2168.849,-2804.391;Inherit;False;Property;_Fres_Power_MinNew;Fres_Power_MinNew;32;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;2171.024,-2965.85;Inherit;False;Property;_Fres_Scale_MaxNew;Fres_Scale_MaxNew;30;0;Create;True;0;0;0;False;0;False;5;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;2172.024,-3038.849;Inherit;False;Property;_Fres_Scale_MinNew;Fres_Scale_MinNew;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;180;1450.389,-2236.133;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;72;2293.161,-2877.609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;142;4151.017,-2156.148;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2345.224,-2627.157;Inherit;False;PanningOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;99;-3008.504,-2401.324;Inherit;False;Property;_Flashing_MainXYZ;Flashing_Main (XYZ);12;0;Create;True;0;0;0;False;0;False;1,1,1;1,5,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;143;4187.732,-1872.31;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;102;-2993.894,-2514.216;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;144;4180.787,-1994.65;Inherit;False;Constant;_Noise_1_Speed;Noise_1_Speed;2;0;Create;True;0;0;0;False;0;False;-0.4,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;1426.839,-2420.271;Inherit;False;Voronoi_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;38;2368.867,-2476.455;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;77;2424.161,-2875.609;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;78;2411.338,-3107.066;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;184;3370.031,-3653.093;Inherit;False;Property;_Fres_2_ScaleX_PowerY_Speeds;Fres_2_Scale(X)_Power(Y)_Speeds;22;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;185;3493.337,-3719.656;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-2781.626,-2435.27;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;145;4399.81,-2036.559;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-2786.232,-2543.797;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2777.626,-2340.27;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2488.734,-1941.32;Inherit;False;110;PanningOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-2345.389,-2702.198;Inherit;False;PanningOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;82;2611.898,-3060.493;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-383.0702,-2282.424;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;3691.824,-3547.779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;4399.646,-1917.242;Inherit;False;Property;_Noise_1_Scale;Noise_1_Scale;0;0;Create;True;0;0;0;False;0;False;3.38;3.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-380.9471,-2201.727;Inherit;False;Property;_Voronoi_Speed;Voronoi_Speed;5;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;40;2596.118,-2485.99;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;83;2683.855,-2846.564;Inherit;False;183;Voronoi_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-2349.15,-2775.906;Inherit;False;PanningOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;3694.999,-3782.237;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2025.067,-2837.409;Inherit;False;112;PanningOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;2955.832,-3059.147;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-160.6406,-2278.788;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;15;-560.209,-2897.279;Inherit;False;Property;_BaseFire_1_Panning;BaseFire_1_Panning;10;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;97;-2643.934,-2343.073;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;14;-557.866,-2775.397;Inherit;False;Property;_BaseFire_2_Panning;BaseFire_2_Panning;8;0;Create;True;0;0;0;False;0;False;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;2802.901,-2540.407;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.88;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-560.7191,-3018.8;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;104;-2647.934,-2438.073;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;114;-2301.913,-1939.631;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;189;3826.518,-3542.582;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-2051.169,-2411.878;Inherit;False;111;PanningOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-242.2808,-2401.209;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-182.6126,-2181.638;Inherit;False;Property;_Voronoi_Scale;Voronoi_Scale;11;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;103;-2658.539,-2540.6;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;147;4579.728,-1984.24;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;-2344.153,-2061.77;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;188;3829.693,-3777.04;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;86;3182.472,-3055.54;Inherit;True;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;121;-1866.487,-2956.858;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;194;3947.344,-3772.311;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;119;-2119.515,-2060.423;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;192;3823.03,-3699.093;Inherit;False;Property;_Fres_2_Scale_MinNew;Fres_2_Scale_MinNew;13;0;Create;True;0;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;4769.787,-1978.646;Inherit;False;Noise_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;17;-201.5943,-2797.664;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;18;-209.2144,-2948.396;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;193;3819.854,-3464.635;Inherit;False;Property;_Fres_2_Power_MinNew;Fres_2_Power_MinNew;19;0;Create;True;0;0;0;False;0;False;1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;3819.854,-3391.635;Inherit;False;Property;_Fres_2_Power_MaxNew;Fres_2_Power_MaxNew;15;0;Create;True;0;0;0;False;0;False;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;105;-2495.935,-2440.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;3822.03,-3626.093;Inherit;False;Property;_Fres_Scale_MaxNew1;Fres_Scale_MaxNew;18;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;2781.652,-2322.583;Inherit;False;Property;_BottomCull;BottomCull;26;0;Create;True;0;0;0;False;0;False;0.1294118;0.431;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;2771.726,-2238.002;Inherit;False;Property;_BottomFade;BottomFade;28;0;Create;True;0;0;0;False;0;False;-0.5;-0.5;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;10;28.51257,-2309.244;Inherit;True;0;0;1;3;8;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleTimeNode;120;-1850.349,-2409.189;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;3051.035,-2756.417;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;3046.812,-2642.396;Inherit;False;Property;_TopCull;TopCull;23;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;118;-1824.247,-2834.721;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;106;-2496.935,-2539.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;3047.812,-2569.396;Inherit;False;Property;_TopFade;TopFade;14;0;Create;True;0;0;0;False;0;False;0;0.5;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;190;3944.167,-3537.853;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;122;-1892.589,-2531.328;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;96;-2492.935,-2339.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;123;-1641.846,-2955.511;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;125;-2034.521,-2273.858;Inherit;True;Property;_Texture2;Texture 2;6;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;19;113.2383,-2530.983;Inherit;False;148;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-2344.951,-2446.355;Inherit;False;FlashingOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;124;-1919.998,-2062.476;Inherit;True;Flipbook;-1;;9;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-2343.265,-2546.528;Inherit;False;FlashingOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;-1791.275,-2724.495;Inherit;True;Property;_Texture3;Texture 3;4;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;20;77.83693,-2754.776;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;88fe50336f30e04478eb04534ac134a4;88fe50336f30e04478eb04534ac134a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;128;-1667.949,-2529.98;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;197;4062.344,-3767.31;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-2343.951,-2346.355;Inherit;False;FlashingOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;126;-1719.66,-3152.703;Inherit;True;Property;_Texture1;Texture 1;3;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;3421.224,-3052.52;Inherit;False;Fresnel_Pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;56;3417.234,-2767.393;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;73.14943,-2957.352;Inherit;True;Property;_MAT_VFX_FlameOrbSprite_Base_1;MAT_VFX_FlameOrbSprite_Base_1;2;0;Create;True;0;0;0;False;0;False;-1;de68d8344b3bf444c88752a1e7691c07;de68d8344b3bf444c88752a1e7691c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;152.045,-3059.46;Inherit;False;148;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;224.546,-2315.33;Inherit;False;VoronoiOriginal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;196;4075.167,-3535.853;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;41;3088.865,-2468.105;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;26;445.6431,-2518.152;Inherit;False;Property;_Flame2Remap;Flame 2 Remap;17;0;Create;True;0;0;0;False;0;False;0,1,0,1.5;0,1,0,1.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;132;-1380.716,-2451.519;Inherit;False;108;FlashingOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;4334.86,-3506.808;Inherit;False;29;VoronoiOriginal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;-1309.1,-2879.728;Inherit;False;107;FlashingOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;-1471.854,-2217.856;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;451.2406,-2742.373;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-1364.962,-2019.884;Inherit;False;95;FlashingOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;129;-1487.608,-2649.491;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;25;468.606,-2916.658;Inherit;False;Constant;_Flame1Remap;Flame 1 Remap;6;0;Create;True;0;0;0;False;0;False;0,1,0,1.5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;436.8052,-3142.29;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;3484.289,-2540.102;Inherit;False;88;Fresnel_Pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;3670.881,-2770.111;Inherit;False;TopCull;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;3406.223,-2417.682;Inherit;False;BottomCull;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;134;-1415.993,-3077.7;Inherit;True;Property;_MAT_VFX_LightningTrailSprite;MAT_VFX_LightningTrailSprite;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;199;4262.903,-3720.737;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1135.727,-2209.571;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1151.48,-2641.207;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1079.865,-3069.415;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;28;807.5363,-2730.709;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;3900.172,-2714.749;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;4606.834,-3719.391;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;3899.146,-2445.852;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;27;811.7809,-2954.818;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;204;4155.116,-2533.784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;201;4833.475,-3715.783;Inherit;True;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;1154.932,-2877.775;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;-898.9777,-3075.204;Inherit;True;LightningMain_X;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-954.8387,-2215.36;Inherit;True;LightningMain_Z;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-935.0757,-2648.105;Inherit;True;LightningMain_Y;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;750.854,-1433.481;Inherit;False;140;LightningMain_Y;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;4269.116,-2527.784;Inherit;False;FresnelNoColour;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;1401.71,-2883.516;Inherit;False;Fire;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;5145.227,-3725.763;Inherit;False;Fresnel_PulseFire;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;749.7727,-1520.002;Inherit;False;138;LightningMain_X;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;750.8542,-1351.285;Inherit;False;139;LightningMain_Z;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;162;1162.114,-1393.024;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;1164.827,-1175.927;Inherit;False;31;Fire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;1137.759,-1004.324;Inherit;False;206;FresnelNoColour;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;1135.536,-1087.86;Inherit;False;202;Fresnel_PulseFire;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;158;-602.7798,-1853.643;Inherit;False;783.3865;817.8458;Colours;10;32;34;150;149;33;35;151;152;153;154;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;4492.424,-2591.901;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-206.3932,-1216.434;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;64;2663.535,-2092.638;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-58.3932,-1351.434;Inherit;False;LightingColour1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-208.3932,-1344.434;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2834.351,-2167.135;Inherit;False;Property;_EdgeFade;EdgeFade;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;911.6251,-1981.016;Inherit;False;94;SoftEdgeMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;67;2876.82,-2072.287;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;4313.559,-2434.446;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-57.3932,-1223.434;Inherit;False;LightningColour2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;1984.371,-1125.447;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;1702.895,-1289.759;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;1690.895,-1190.759;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;1686.81,-1088.648;Inherit;False;48;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;1702.691,-1388.81;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;1418.846,-1458.76;Inherit;False;153;LightingColour1;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;1418.724,-1535.766;Inherit;False;202;Fresnel_PulseFire;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;1450.895,-1224.759;Inherit;False;34;FireColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;167;1589.241,-998.13;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;74;2753.211,-1874.805;Inherit;False;Property;_SmoothStep_Fill;SmoothStep_Fill;33;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;3249.38,-1858.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;2755.21,-1794.805;Inherit;False;Property;_Smoothstep_Fade;Smoothstep_Fade;31;0;Create;True;0;0;0;False;0;False;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;59;2276.237,-2094.021;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;85;3434.432,-2019.718;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1.63,0,0,0;False;2;COLOR;1.54,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-552.3432,-1611.521;Inherit;False;Property;_FireColour;FireColour;35;1;[HDR];Create;True;0;0;0;False;0;False;0.990566,0.2478243,0,0;2.118547,0.2067708,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;4738.603,-2595.168;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-265.4522,-1667.615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-2342.861,-2256.325;Inherit;False;SoftEdgeMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;90;-3139.826,-2250.14;Inherit;True;Property;_MAT_Masking_SquareMaskSprite;MAT_Masking_SquareMaskSprite;4;0;Create;True;0;0;0;False;0;False;-1;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;89;-3434.479,-2251.701;Inherit;True;Property;_Texture0;Texture 0;9;0;Create;True;0;0;0;False;0;False;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;1171.7,-2238.614;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;93;-2542.328,-2256.008;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;150;-550.8398,-1431.016;Inherit;False;Property;_LightningColour_1;LightningColour_1;21;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;6.498019,2.560996,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;79;3060.683,-1983.058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;33;-550.5419,-1803.643;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-107.4523,-1655.615;Inherit;False;FireColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;149;-552.7797,-1247.797;Inherit;False;Property;_LightningColour_2;LightningColour_2;25;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;4.237095,1.281912,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;44;4111.558,-2627.446;Inherit;False;154;LightningColour2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;3244.163,-2024.419;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;4304.559,-2699.446;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;4125.559,-2361.446;Inherit;False;34;FireColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2683.373,-2251.137;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;61;2452.074,-2101.961;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;3689.875,-2013.309;Inherit;False;DisolveAlpha;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;3060.911,-2058.404;Inherit;False;31;Fire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2183.162,-989.2198;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_LaserbeamOrb;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637912841205879581;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;637912841370404105;  Use Shadow Threshold;0;0;Receive Shadows;0;637912841378622713;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;5176.817,-2884.395;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;62;0;58;0
WireConnection;62;1;60;1
WireConnection;63;0;58;0
WireConnection;63;1;60;2
WireConnection;177;0;173;0
WireConnection;177;1;174;0
WireConnection;178;0;175;0
WireConnection;178;1;177;0
WireConnection;178;2;176;0
WireConnection;66;0;63;0
WireConnection;65;0;62;0
WireConnection;70;0;65;0
WireConnection;180;0;178;0
WireConnection;180;3;179;1
WireConnection;180;4;179;2
WireConnection;72;0;66;0
WireConnection;142;0;141;0
WireConnection;110;0;109;3
WireConnection;183;0;180;0
WireConnection;38;0;37;0
WireConnection;77;0;72;0
WireConnection;77;3;71;0
WireConnection;77;4;68;0
WireConnection;78;0;70;0
WireConnection;78;3;69;0
WireConnection;78;4;73;0
WireConnection;100;0;102;0
WireConnection;100;1;99;2
WireConnection;145;0;142;0
WireConnection;145;2;144;0
WireConnection;145;1;143;0
WireConnection;101;0;102;0
WireConnection;101;1;99;1
WireConnection;98;0;102;0
WireConnection;98;1;99;3
WireConnection;111;0;109;2
WireConnection;82;2;78;0
WireConnection;82;3;77;0
WireConnection;186;0;185;0
WireConnection;186;1;184;2
WireConnection;40;0;38;0
WireConnection;112;0;109;1
WireConnection;187;0;185;0
WireConnection;187;1;184;1
WireConnection;84;0;82;0
WireConnection;84;1;83;0
WireConnection;8;0;6;0
WireConnection;8;1;5;0
WireConnection;97;0;98;0
WireConnection;50;0;40;1
WireConnection;104;0;100;0
WireConnection;114;0;113;0
WireConnection;189;0;186;0
WireConnection;103;0;101;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;188;0;187;0
WireConnection;86;0;84;0
WireConnection;194;0;188;0
WireConnection;119;0;116;0
WireConnection;119;1;114;0
WireConnection;148;0;147;0
WireConnection;17;0;16;0
WireConnection;17;2;14;0
WireConnection;18;0;16;0
WireConnection;18;2;15;0
WireConnection;105;0;104;0
WireConnection;10;0;7;0
WireConnection;10;1;8;0
WireConnection;10;2;9;0
WireConnection;120;0;115;0
WireConnection;49;0;50;0
WireConnection;118;0;117;0
WireConnection;106;0;103;0
WireConnection;190;0;189;0
WireConnection;96;0;97;0
WireConnection;123;0;121;0
WireConnection;123;1;118;0
WireConnection;108;0;105;0
WireConnection;124;13;119;0
WireConnection;107;0;106;0
WireConnection;20;1;17;0
WireConnection;128;0;122;0
WireConnection;128;1;120;0
WireConnection;197;0;194;0
WireConnection;197;3;192;0
WireConnection;197;4;195;0
WireConnection;95;0;96;0
WireConnection;88;0;86;0
WireConnection;56;0;49;0
WireConnection;56;1;52;0
WireConnection;56;2;57;0
WireConnection;21;1;18;0
WireConnection;29;0;10;0
WireConnection;196;0;190;0
WireConnection;196;3;193;0
WireConnection;196;4;191;0
WireConnection;41;0;50;0
WireConnection;41;1;36;0
WireConnection;41;2;39;0
WireConnection;130;0;125;0
WireConnection;130;1;124;0
WireConnection;23;0;20;1
WireConnection;23;1;19;0
WireConnection;129;0;127;0
WireConnection;129;1;128;0
WireConnection;24;0;21;0
WireConnection;24;1;22;0
WireConnection;51;0;56;0
WireConnection;45;0;41;0
WireConnection;134;0;126;0
WireConnection;134;1;123;0
WireConnection;199;2;197;0
WireConnection;199;3;196;0
WireConnection;135;0;130;0
WireConnection;135;1;133;0
WireConnection;137;0;129;0
WireConnection;137;1;132;0
WireConnection;136;0;134;0
WireConnection;136;1;131;0
WireConnection;28;0;23;0
WireConnection;28;1;26;1
WireConnection;28;2;26;2
WireConnection;28;3;26;3
WireConnection;28;4;26;4
WireConnection;53;0;51;0
WireConnection;53;1;55;0
WireConnection;200;0;199;0
WireConnection;200;1;198;0
WireConnection;54;0;45;0
WireConnection;54;1;55;0
WireConnection;27;0;24;0
WireConnection;27;1;25;1
WireConnection;27;2;25;2
WireConnection;27;3;25;3
WireConnection;27;4;25;4
WireConnection;204;0;53;0
WireConnection;204;1;54;0
WireConnection;201;0;200;0
WireConnection;30;0;27;0
WireConnection;30;1;28;0
WireConnection;138;0;136;0
WireConnection;139;0;135;0
WireConnection;140;0;137;0
WireConnection;206;0;204;0
WireConnection;31;0;30;0
WireConnection;202;0;201;0
WireConnection;162;0;159;0
WireConnection;162;1;160;0
WireConnection;162;2;161;0
WireConnection;47;0;43;0
WireConnection;47;1;42;0
WireConnection;152;0;33;0
WireConnection;152;1;149;0
WireConnection;64;0;61;0
WireConnection;153;0;151;0
WireConnection;151;0;33;0
WireConnection;151;1;150;0
WireConnection;67;0;64;1
WireConnection;42;0;54;0
WireConnection;42;1;46;0
WireConnection;154;0;152;0
WireConnection;172;0;168;0
WireConnection;172;1;169;0
WireConnection;172;2;166;0
WireConnection;172;3;208;0
WireConnection;168;0;171;0
WireConnection;168;1;162;0
WireConnection;169;0;170;0
WireConnection;169;1;163;0
WireConnection;208;0;207;0
WireConnection;208;1;170;0
WireConnection;167;0;162;0
WireConnection;167;1;163;0
WireConnection;167;2;203;0
WireConnection;167;3;205;0
WireConnection;81;0;74;0
WireConnection;81;1;75;0
WireConnection;85;0;80;0
WireConnection;85;1;74;0
WireConnection;85;2;81;0
WireConnection;48;0;47;0
WireConnection;35;0;33;0
WireConnection;35;1;32;0
WireConnection;94;0;93;0
WireConnection;90;0;89;0
WireConnection;182;0;178;0
WireConnection;182;1;181;0
WireConnection;93;0;92;0
WireConnection;79;0;67;0
WireConnection;34;0;35;0
WireConnection;80;0;76;0
WireConnection;80;1;79;0
WireConnection;43;0;53;0
WireConnection;43;1;44;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;61;0;59;0
WireConnection;87;0;85;0
WireConnection;1;2;172;0
WireConnection;1;3;167;0
ASEEND*/
//CHKSM=FC6056519A67C018E75A7DE979604C0FAE6F4E72