// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_AcidCloudOrb"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Noise_1_Scale("Noise_1_Scale", Float) = 3.38
		_MAT_VFX_FlameOrbSprite_Base_1("MAT_VFX_FlameOrbSprite_Base_1", 2D) = "white" {}
		[HDR]_AcidColour("AcidColour", Color) = (0,1,0.08572555,0)
		_Noise_2_Scale("Noise_2_Scale", Float) = 1.4
		_Voronoi_Speed("Voronoi_Speed", Float) = 5
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Brightest_Parts_Intense("Brightest_Parts_Intense", Float) = 5
		_Texture0("Texture 0", 2D) = "white" {}
		_EdgeFade("EdgeFade", Float) = 1
		_BaseFire_2_Panning("BaseFire_2_Panning", Vector) = (-1,0,0,0)
		_BaseFire_1_Panning("BaseFire_1_Panning", Vector) = (1,0,0,0)
		_Voronoi_Scale("Voronoi_Scale", Float) = 5
		_TopColourFade("TopColourFade", Range( -100 , 100)) = 0
		_RemapNews("Remap News", Vector) = (-3.14,1.95,0,0)
		_Flame2Remap("Flame 2 Remap", Vector) = (0,1,0,10)
		_TopColourCull("TopColourCull", Range( 0 , 1)) = 1
		_VertOffset_Intensity("VertOffset_Intensity", Float) = 0
		_BottomColourCull("BottomColourCull", Range( 0 , 1)) = 0.1294118
		_Fres_Scale_MinNew("Fres_Scale_MinNew", Float) = 1
		_BottomColourFade("BottomColourFade", Range( -100 , 100)) = -0.5
		_Bright_Step_Value("Bright_Step_Value", Float) = 0.1
		_Fres_Power_MaxNew("Fres_Power_MaxNew", Float) = 5
		_Base_Intensity("Base_Intensity", Float) = 1
		_Fres_Scale_MaxNew("Fres_Scale_MaxNew", Float) = 5
		_Smoothstep_Fade("Smoothstep_Fade", Range( 0 , 100)) = 0
		_Fres_Power_MinNew("Fres_Power_MinNew", Float) = 1
		_SmoothStep_Fill("SmoothStep_Fill", Range( -2 , 2)) = 0
		_Fres_ScaleX_PowerY_Speeds("Fres_Scale(X)_Power(Y)_Speeds", Vector) = (1,1,0,0)
		[ASEEnd][HDR]_FireColour("FireColour", Color) = (0.990566,0.2478243,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR


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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Flame2Remap;
			float4 _Texture0_ST;
			float4 _AcidColour;
			float4 _FireColour;
			float2 _BaseFire_2_Panning;
			float2 _BaseFire_1_Panning;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float _Noise_1_Scale;
			float _Brightest_Parts_Intense;
			float _Bright_Step_Value;
			float _Base_Intensity;
			float _EdgeFade;
			float _Noise_2_Scale;
			float _BottomColourFade;
			float _BottomColourCull;
			float _Voronoi_Speed;
			float _Voronoi_Scale;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _TopColourFade;
			float _TopColourCull;
			float _VertOffset_Intensity;
			float _SmoothStep_Fill;
			float _Smoothstep_Fade;
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
			
					float2 voronoihash122( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi122( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash122( n + g );
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

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( ase_worldPos, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( v.ase_normal * ( Noise_131 * _VertOffset_Intensity ) );
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
				float3 worldToObj242 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float temp_output_240_0 = ( worldToObj242.y * 0.88 );
				float smoothstepResult249 = smoothstep( _TopColourCull , _TopColourFade , ( 1.0 - temp_output_240_0 ));
				float TopCull252 = smoothstepResult249;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV174 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode174 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV174, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float time122 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId122 = 0;
				float2 texCoord117 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords122 = texCoord117 * _Voronoi_Scale;
				float2 id122 = 0;
				float2 uv122 = 0;
				float fade122 = 0.5;
				float voroi122 = 0;
				float rest122 = 0;
				for( int it122 = 0; it122 <8; it122++ ){
				voroi122 += fade122 * voronoi122( coords122, time122, id122, uv122, 0,voronoiSmoothId122 );
				rest122 += fade122;
				coords122 *= 2;
				fade122 *= 0.5;
				}//Voronoi122
				voroi122 /= rest122;
				float VoronoiOriginal157 = voroi122;
				float Fresnel_Pulse200 = ( fresnelNode174 * VoronoiOriginal157 );
				float4 AcidColours111 = ( IN.ase_color * _AcidColour );
				float smoothstepResult246 = smoothstep( _BottomColourCull , _BottomColourFade , temp_output_240_0);
				float BottomCull253 = smoothstepResult246;
				float4 FireColour217 = ( IN.ase_color * _FireColour );
				float4 Fresnel269 = ( ( ( TopCull252 * Fresnel_Pulse200 ) * AcidColours111 ) + ( ( BottomCull253 * Fresnel_Pulse200 ) * FireColour217 ) );
				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				float2 panner19 = ( _TimeParameters.x * float2( 0.1,0.1 ) + worldToObj13.xy);
				float simplePerlin3D28 = snoise( float3( panner19 ,  0.0 )*_Noise_2_Scale );
				simplePerlin3D28 = simplePerlin3D28*0.5 + 0.5;
				float Noise_232 = simplePerlin3D28;
				float2 uv_Texture0 = IN.ase_texcoord4.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 SoftEdgeMask38 = (( tex2D( _Texture0, uv_Texture0 ) * _EdgeFade )).rgba;
				float4 Acid_Base_Section84 = ( ( (0.3 + (( (-0.7 + (Noise_131 - 0.0) * (4.0 - -0.7) / (1.0 - 0.0)) * (-0.3 + (Noise_232 - 0.0) * (1.0 - -0.3) / (1.0 - 0.0)) ) - 0.0) * (1.0 - 0.3) / (1.0 - 0.0)) * SoftEdgeMask38 ) * _Base_Intensity );
				float temp_output_3_0_g11 = ( Noise_232 - Noise_131 );
				float temp_output_58_0 = ( (-0.2 + (Noise_131 - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) * saturate( ( temp_output_3_0_g11 / fwidth( temp_output_3_0_g11 ) ) ) );
				float Voronoi136 = (_RemapNews.x + (voroi122 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float temp_output_3_0_g10 = ( _Bright_Step_Value - Voronoi136 );
				float4 Acid_Bright_Sections83 = ( ( temp_output_58_0 * (( temp_output_58_0 * ( saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) ) * SoftEdgeMask38 ) )).rgba ) * _Brightest_Parts_Intense );
				float4 Acid224 = ( Acid_Base_Section84 + Acid_Bright_Sections83 );
				float2 texCoord169 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner185 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord169);
				float4 _Flame1Remap = float4(0,1,0,1.5);
				float4 temp_cast_4 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_5 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_6 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_7 = (_Flame1Remap.w).xxxx;
				float2 panner181 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord169);
				float4 Fire219 = ( (temp_cast_6 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner185 ) * Noise_131 ) - temp_cast_4) * (temp_cast_7 - temp_cast_6) / (temp_cast_5 - temp_cast_4)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner181 ).r * Noise_232 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) );
				
				float3 worldToObj70 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult96 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Noise_131 + ( 1.0 - (0.0 + (worldToObj70.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha99 = smoothstepResult96;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Fresnel269 + ( ( ( AcidColours111 * Acid224 ) * TopCull252 ) + ( ( FireColour217 * Fire219 ) * BottomCull253 ) ) ).rgb;
				float Alpha = ( ( ( Acid224 + Fire219 ) * DisolveAlpha99 ) + Fresnel_Pulse200 ).r;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
			float4 _Flame2Remap;
			float4 _Texture0_ST;
			float4 _AcidColour;
			float4 _FireColour;
			float2 _BaseFire_2_Panning;
			float2 _BaseFire_1_Panning;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float _Noise_1_Scale;
			float _Brightest_Parts_Intense;
			float _Bright_Step_Value;
			float _Base_Intensity;
			float _EdgeFade;
			float _Noise_2_Scale;
			float _BottomColourFade;
			float _BottomColourCull;
			float _Voronoi_Speed;
			float _Voronoi_Scale;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _TopColourFade;
			float _TopColourCull;
			float _VertOffset_Intensity;
			float _SmoothStep_Fill;
			float _Smoothstep_Fade;
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
			
					float2 voronoihash122( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi122( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash122( n + g );
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
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( ase_worldPos, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				
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
				float3 vertexValue = ( v.ase_normal * ( Noise_131 * _VertOffset_Intensity ) );
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

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

				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				float2 panner19 = ( _TimeParameters.x * float2( 0.1,0.1 ) + worldToObj13.xy);
				float simplePerlin3D28 = snoise( float3( panner19 ,  0.0 )*_Noise_2_Scale );
				simplePerlin3D28 = simplePerlin3D28*0.5 + 0.5;
				float Noise_232 = simplePerlin3D28;
				float2 uv_Texture0 = IN.ase_texcoord2.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 SoftEdgeMask38 = (( tex2D( _Texture0, uv_Texture0 ) * _EdgeFade )).rgba;
				float4 Acid_Base_Section84 = ( ( (0.3 + (( (-0.7 + (Noise_131 - 0.0) * (4.0 - -0.7) / (1.0 - 0.0)) * (-0.3 + (Noise_232 - 0.0) * (1.0 - -0.3) / (1.0 - 0.0)) ) - 0.0) * (1.0 - 0.3) / (1.0 - 0.0)) * SoftEdgeMask38 ) * _Base_Intensity );
				float temp_output_3_0_g11 = ( Noise_232 - Noise_131 );
				float temp_output_58_0 = ( (-0.2 + (Noise_131 - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) * saturate( ( temp_output_3_0_g11 / fwidth( temp_output_3_0_g11 ) ) ) );
				float time122 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId122 = 0;
				float2 texCoord117 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords122 = texCoord117 * _Voronoi_Scale;
				float2 id122 = 0;
				float2 uv122 = 0;
				float fade122 = 0.5;
				float voroi122 = 0;
				float rest122 = 0;
				for( int it122 = 0; it122 <8; it122++ ){
				voroi122 += fade122 * voronoi122( coords122, time122, id122, uv122, 0,voronoiSmoothId122 );
				rest122 += fade122;
				coords122 *= 2;
				fade122 *= 0.5;
				}//Voronoi122
				voroi122 /= rest122;
				float Voronoi136 = (_RemapNews.x + (voroi122 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float temp_output_3_0_g10 = ( _Bright_Step_Value - Voronoi136 );
				float4 Acid_Bright_Sections83 = ( ( temp_output_58_0 * (( temp_output_58_0 * ( saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) ) * SoftEdgeMask38 ) )).rgba ) * _Brightest_Parts_Intense );
				float4 Acid224 = ( Acid_Base_Section84 + Acid_Bright_Sections83 );
				float2 texCoord169 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner185 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord169);
				float4 _Flame1Remap = float4(0,1,0,1.5);
				float4 temp_cast_4 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_5 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_6 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_7 = (_Flame1Remap.w).xxxx;
				float2 panner181 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord169);
				float4 Fire219 = ( (temp_cast_6 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner185 ) * Noise_131 ) - temp_cast_4) * (temp_cast_7 - temp_cast_6) / (temp_cast_5 - temp_cast_4)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner181 ).r * Noise_232 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) );
				float3 worldToObj70 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult96 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Noise_131 + ( 1.0 - (0.0 + (worldToObj70.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha99 = smoothstepResult96;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV174 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode174 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV174, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float VoronoiOriginal157 = voroi122;
				float Fresnel_Pulse200 = ( fresnelNode174 * VoronoiOriginal157 );
				
				float Alpha = ( ( ( Acid224 + Fire219 ) * DisolveAlpha99 ) + Fresnel_Pulse200 ).r;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

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
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70701

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
			float4 _Flame2Remap;
			float4 _Texture0_ST;
			float4 _AcidColour;
			float4 _FireColour;
			float2 _BaseFire_2_Panning;
			float2 _BaseFire_1_Panning;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float _Noise_1_Scale;
			float _Brightest_Parts_Intense;
			float _Bright_Step_Value;
			float _Base_Intensity;
			float _EdgeFade;
			float _Noise_2_Scale;
			float _BottomColourFade;
			float _BottomColourCull;
			float _Voronoi_Speed;
			float _Voronoi_Scale;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _TopColourFade;
			float _TopColourCull;
			float _VertOffset_Intensity;
			float _SmoothStep_Fill;
			float _Smoothstep_Fade;
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
			
					float2 voronoihash122( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi122( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash122( n + g );
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

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( ase_worldPos, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				
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
				float3 vertexValue = ( v.ase_normal * ( Noise_131 * _VertOffset_Intensity ) );
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

				float3 worldToObj13 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float2 panner16 = ( _TimeParameters.x * float2( -0.4,-0.1 ) + worldToObj13.xy);
				float simplePerlin3D30 = snoise( float3( panner16 ,  0.0 )*_Noise_1_Scale );
				simplePerlin3D30 = simplePerlin3D30*0.5 + 0.5;
				float Noise_131 = simplePerlin3D30;
				float2 panner19 = ( _TimeParameters.x * float2( 0.1,0.1 ) + worldToObj13.xy);
				float simplePerlin3D28 = snoise( float3( panner19 ,  0.0 )*_Noise_2_Scale );
				simplePerlin3D28 = simplePerlin3D28*0.5 + 0.5;
				float Noise_232 = simplePerlin3D28;
				float2 uv_Texture0 = IN.ase_texcoord2.xy * _Texture0_ST.xy + _Texture0_ST.zw;
				float4 SoftEdgeMask38 = (( tex2D( _Texture0, uv_Texture0 ) * _EdgeFade )).rgba;
				float4 Acid_Base_Section84 = ( ( (0.3 + (( (-0.7 + (Noise_131 - 0.0) * (4.0 - -0.7) / (1.0 - 0.0)) * (-0.3 + (Noise_232 - 0.0) * (1.0 - -0.3) / (1.0 - 0.0)) ) - 0.0) * (1.0 - 0.3) / (1.0 - 0.0)) * SoftEdgeMask38 ) * _Base_Intensity );
				float temp_output_3_0_g11 = ( Noise_232 - Noise_131 );
				float temp_output_58_0 = ( (-0.2 + (Noise_131 - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) * saturate( ( temp_output_3_0_g11 / fwidth( temp_output_3_0_g11 ) ) ) );
				float time122 = ( _TimeParameters.x * _Voronoi_Speed );
				float2 voronoiSmoothId122 = 0;
				float2 texCoord117 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords122 = texCoord117 * _Voronoi_Scale;
				float2 id122 = 0;
				float2 uv122 = 0;
				float fade122 = 0.5;
				float voroi122 = 0;
				float rest122 = 0;
				for( int it122 = 0; it122 <8; it122++ ){
				voroi122 += fade122 * voronoi122( coords122, time122, id122, uv122, 0,voronoiSmoothId122 );
				rest122 += fade122;
				coords122 *= 2;
				fade122 *= 0.5;
				}//Voronoi122
				voroi122 /= rest122;
				float Voronoi136 = (_RemapNews.x + (voroi122 - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float temp_output_3_0_g10 = ( _Bright_Step_Value - Voronoi136 );
				float4 Acid_Bright_Sections83 = ( ( temp_output_58_0 * (( temp_output_58_0 * ( saturate( ( temp_output_3_0_g10 / fwidth( temp_output_3_0_g10 ) ) ) * SoftEdgeMask38 ) )).rgba ) * _Brightest_Parts_Intense );
				float4 Acid224 = ( Acid_Base_Section84 + Acid_Bright_Sections83 );
				float2 texCoord169 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner185 = ( 1.0 * _Time.y * _BaseFire_1_Panning + texCoord169);
				float4 _Flame1Remap = float4(0,1,0,1.5);
				float4 temp_cast_4 = (_Flame1Remap.x).xxxx;
				float4 temp_cast_5 = (_Flame1Remap.y).xxxx;
				float4 temp_cast_6 = (_Flame1Remap.z).xxxx;
				float4 temp_cast_7 = (_Flame1Remap.w).xxxx;
				float2 panner181 = ( 1.0 * _Time.y * _BaseFire_2_Panning + texCoord169);
				float4 Fire219 = ( (temp_cast_6 + (( tex2D( _MAT_VFX_FlameOrbSprite_Base_1, panner185 ) * Noise_131 ) - temp_cast_4) * (temp_cast_7 - temp_cast_6) / (temp_cast_5 - temp_cast_4)) + (_Flame2Remap.z + (( tex2D( _TextureSample0, panner181 ).r * Noise_232 ) - _Flame2Remap.x) * (_Flame2Remap.w - _Flame2Remap.z) / (_Flame2Remap.y - _Flame2Remap.x)) );
				float3 worldToObj70 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult96 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Noise_131 + ( 1.0 - (0.0 + (worldToObj70.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha99 = smoothstepResult96;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV174 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode174 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (10.0 - 0.0)) * pow( 1.0 - fresnelNdotV174, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float VoronoiOriginal157 = voroi122;
				float Fresnel_Pulse200 = ( fresnelNode174 * VoronoiOriginal157 );
				
				float Alpha = ( ( ( Acid224 + Fire219 ) * DisolveAlpha99 ) + Fresnel_Pulse200 ).r;
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
0;0;1920;1019;1040.078;3734.065;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;225;-1345.228,-3848.563;Inherit;False;3648.076;1508.634;FireSections;31;166;169;172;181;185;189;192;195;197;198;199;201;202;209;219;210;215;214;217;188;187;113;114;115;116;117;122;126;136;157;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;218;-4765.203,-3849.832;Inherit;False;3396.64;1642.586;AcidSections;55;7;8;11;12;13;14;15;16;17;19;20;21;22;26;28;30;31;32;34;38;39;40;42;43;50;51;52;53;54;55;56;58;59;60;64;65;67;68;69;72;73;74;75;77;79;105;106;110;111;83;84;221;222;223;224;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;113;-672.4961,-2741.137;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-670.373,-2660.439;Inherit;False;Property;_Voronoi_Speed;Voronoi_Speed;4;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-4715.203,-3307.897;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;8;-4151.06,-3121.939;Inherit;False;Constant;_Noise_2_Speed;Noise_2_Speed;2;0;Create;True;0;0;0;False;0;False;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;11;-4444.148,-2438.807;Inherit;True;Property;_Texture0;Texture 0;7;0;Create;True;0;0;0;False;0;False;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;14;-4141.449,-3380.121;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;13;-4550.501,-3310.991;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;12;-4153.383,-3001.866;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;117;-531.7071,-2859.922;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-450.067,-2737.501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-472.0386,-2640.35;Inherit;False;Property;_Voronoi_Scale;Voronoi_Scale;11;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;15;-4148.395,-3502.462;Inherit;False;Constant;_Noise_1_Speed;Noise_1_Speed;2;0;Create;True;0;0;0;False;0;False;-0.4,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VoronoiNode;122;-260.9137,-2767.957;Inherit;True;0;0;1;3;8;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.Vector2Node;123;-264.9274,-2503.929;Inherit;False;Property;_RemapNews;Remap News;13;0;Create;True;0;0;0;False;0;False;-3.14,1.95;-3.14,1.95;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;-3864.021,-2337.24;Inherit;False;Property;_EdgeFade;EdgeFade;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-3927.054,-3175.021;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;22;-4149.496,-2437.246;Inherit;True;Property;_MAT_Masking_SquareMaskSprite;MAT_Masking_SquareMaskSprite;4;0;Create;True;0;0;0;False;0;False;-1;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;16;-3929.373,-3544.371;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3929.536,-3425.055;Inherit;False;Property;_Noise_1_Scale;Noise_1_Scale;0;0;Create;True;0;0;0;False;0;False;3.38;3.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3919.661,-3056.107;Inherit;False;Property;_Noise_2_Scale;Noise_2_Scale;3;0;Create;True;0;0;0;False;0;False;1.4;1.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;28;-3739.489,-3138.504;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;30;-3749.454,-3492.052;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;126;-57.73291,-2736.124;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-3713.043,-2421.243;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;227.0056,-2751.875;Inherit;True;Voronoi;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-3559.396,-3486.459;Inherit;True;Noise_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-3503.698,-3139.222;Inherit;True;Noise_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;-3571.998,-2426.114;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-2946.685,-3035.126;Inherit;False;32;Noise_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2945.716,-2870.014;Inherit;False;Property;_Bright_Step_Value;Bright_Step_Value;20;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-3372.531,-2426.431;Inherit;False;SoftEdgeMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2949.19,-3110.456;Inherit;False;31;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2940.085,-2954.538;Inherit;False;136;Voronoi;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2943.318,-2575.73;Inherit;False;31;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2716.617,-2832.845;Inherit;False;38;SoftEdgeMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;51;-2710.445,-3028.861;Inherit;False;Step Antialiasing;-1;;11;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2935.318,-2483.73;Inherit;False;32;Noise_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;50;-2699.619,-3203.389;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;54;-2710.34,-2926.517;Inherit;False;Step Antialiasing;-1;;10;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;59;-2750.318,-2465.73;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2478.138,-3112.921;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;60;-2750.318,-2637.73;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.7;False;4;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-2495.927,-2975.927;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2567.723,-2550.186;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-2340.046,-3028.174;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-2376.893,-2332.365;Inherit;False;38;SoftEdgeMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;63;-3752.355,-1155.358;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;68;-2211.179,-3019.995;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;67;-2425.817,-2549.592;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;119;-3398.188,-505.125;Inherit;False;Property;_Fres_ScaleX_PowerY_Speeds;Fres_Scale(X)_Power(Y)_Speeds;27;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;166;-1294.718,-3337.852;Inherit;False;Property;_BaseFire_1_Panning;BaseFire_1_Panning;10;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;172;-1292.375,-3215.97;Inherit;False;Property;_BaseFire_2_Panning;BaseFire_2_Panning;9;0;Create;True;0;0;0;False;0;False;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;169;-1295.228,-3459.373;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;120;-3274.882,-571.688;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;181;-936.1032,-3238.237;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;70;-3576.518,-1163.298;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;72;-2110.375,-2323.88;Inherit;False;Property;_Base_Intensity;Base_Intensity;22;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2206.188,-2943.426;Inherit;False;Property;_Brightest_Parts_Intense;Brightest_Parts_Intense;6;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2123.723,-2542.452;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2015.284,-3113.469;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;185;-943.7233,-3388.969;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-3073.221,-634.2689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-3076.396,-399.8112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;71;-3365.057,-1153.975;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1897.314,-2527.74;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;132;-2938.528,-629.0717;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1870.749,-3111.276;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-582.464,-3500.033;Inherit;False;31;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-621.2706,-2971.556;Inherit;False;32;Noise_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;192;-656.672,-3195.349;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;88fe50336f30e04478eb04534ac134a4;88fe50336f30e04478eb04534ac134a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;189;-661.3595,-3397.925;Inherit;True;Property;_MAT_VFX_FlameOrbSprite_Base_1;MAT_VFX_FlameOrbSprite_Base_1;1;0;Create;True;0;0;0;False;0;False;-1;de68d8344b3bf444c88752a1e7691c07;de68d8344b3bf444c88752a1e7691c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;134;-2941.702,-394.614;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-297.7037,-3582.863;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-283.2682,-3182.946;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2948.366,-243.6667;Inherit;False;Property;_Fres_Power_MaxNew;Fres_Power_MaxNew;21;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-2945.19,-551.125;Inherit;False;Property;_Fres_Scale_MinNew;Fres_Scale_MinNew;18;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;153;-2820.876,-624.3427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-2948.366,-316.6671;Inherit;False;Property;_Fres_Power_MinNew;Fres_Power_MinNew;25;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;148;-2824.053,-389.8849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-2946.19,-478.1251;Inherit;False;Property;_Fres_Scale_MaxNew;Fres_Scale_MaxNew;23;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;199;-254.6827,-2952.314;Inherit;False;Property;_Flame2Remap;Flame 2 Remap;14;0;Create;True;0;0;0;False;0;False;0,1,0,10;0,1,0,1.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;197;-265.9029,-3357.231;Inherit;False;Constant;_Flame1Remap;Flame 1 Remap;6;0;Create;True;0;0;0;False;0;False;0,1,0,1.5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1735.604,-2535.409;Inherit;False;Acid_Base_Section;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-1625.563,-3115.623;Inherit;False;Acid_Bright_Sections;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;80;-3151.772,-1133.624;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;202;77.27197,-3395.391;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-2244.04,-3593.783;Inherit;False;84;Acid_Base_Section;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-2257.125,-3512.853;Inherit;False;83;Acid_Bright_Sections;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;163;-2705.876,-619.3417;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;201;73.02734,-3171.282;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;162;-2693.053,-387.8849;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2967.681,-1119.742;Inherit;False;31;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3273.381,-856.1418;Inherit;False;Property;_Smoothstep_Fade;Smoothstep_Fade;24;0;Create;True;0;0;0;False;0;False;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-3275.381,-936.1415;Inherit;False;Property;_SmoothStep_Fill;SmoothStep_Fill;26;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;88;-2967.909,-1044.396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-38.94287,-2844.074;Inherit;False;VoronoiOriginal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-2779.211,-919.5616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2433.359,-358.84;Inherit;False;157;VoronoiOriginal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;174;-2505.316,-572.769;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-2784.429,-1085.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;209;420.4233,-3318.348;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;223;-2004.515,-3591.248;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;667.2012,-3324.089;Inherit;False;Fire;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2161.383,-571.4233;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;96;-2594.16,-1081.055;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1.63;False;2;FLOAT;1.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-1715.515,-3542.248;Inherit;False;Acid;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-661.4669,-906.9769;Inherit;True;219;Fire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-653.4669,-1114.976;Inherit;True;224;Acid;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2338.717,-1074.647;Inherit;False;DisolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;193;-1934.742,-567.8159;Inherit;True;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-1695.99,-564.7959;Inherit;False;Fresnel_Pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-302.8702,-350.3375;Inherit;False;31;Noise_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;228;-180.5873,-836.3643;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-338.9122,-268.8282;Inherit;False;Property;_VertOffset_Intensity;VertOffset_Intensity;16;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;-151.5356,-602.4368;Inherit;False;99;DisolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;147.0664,-612.9282;Inherit;False;200;Fresnel_Pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;134.4644,-840.4368;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;104;-152.6693,-499.4197;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-123.5653,-321.1276;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;243;-2076.327,-1799.725;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-175.3873,-1283.564;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;106;-4417.909,-3799.832;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-3929.884,-3737.579;Inherit;False;AcidColours;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;113.3307,-415.4197;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;271;628.2777,-1215.952;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-475.6873,-1301.764;Inherit;False;111;AcidColours;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;105;-4407.106,-3625.319;Inherit;False;Property;_AcidColour;AcidColour;2;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.08572555,0;1.277263,2.996078,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;256;29.67004,-1160.592;Inherit;False;252;TopCull;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;368.9122,-1228.565;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;388.2777,-1324.952;Inherit;False;269;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-4166.401,-3729.555;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;41.67004,-946.5916;Inherit;False;253;BottomCull;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;262;402.0664,-852.9282;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;163.67,-1041.592;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-395.087,-1072.965;Inherit;False;217;FireColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-177.9871,-1059.963;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;196.67,-1264.592;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-524.297,-3650.535;Inherit;False;FireColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;214;-969.1877,-3606.44;Inherit;False;Property;_FireColour;FireColour;28;1;[HDR];Create;True;0;0;0;False;0;False;0.990566,0.2478243,0,0;1.319508,0.2794252,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;-682.2972,-3662.535;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;242;-1892.321,-1781.345;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;245;-1489.463,-1542.892;Inherit;False;Property;_BottomColourFade;BottomColourFade;19;0;Create;True;0;0;0;False;0;False;-0.5;-1;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;241;-1665.07,-1790.88;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;246;-1172.324,-1772.996;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;52.37024,-1739.336;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;264;43.37024,-2004.336;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-149.6298,-1931.336;Inherit;False;111;AcidColours;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;-847.5613,-1755.896;Inherit;False;BottomCull;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-135.6298,-1666.336;Inherit;False;217;FireColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-1479.537,-1627.473;Inherit;False;Property;_BottomColourCull;BottomColourCull;17;0;Create;True;0;0;0;False;0;False;0.1294118;0.453;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;231.2366,-1896.791;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;250;-1210.154,-2061.307;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-1458.288,-1845.297;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.88;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-590.3089,-2075.001;Inherit;False;TopCull;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1214.377,-1947.287;Inherit;False;Property;_TopColourCull;TopColourCull;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-361.0179,-2019.639;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-362.0441,-1750.742;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-776.9008,-1844.992;Inherit;False;200;Fresnel_Pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;249;-843.9553,-2072.283;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-1213.377,-1874.287;Inherit;False;Property;_TopColourFade;TopColourFade;12;0;Create;True;0;0;0;False;0;False;0;0;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;477.4153,-1900.059;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;215;-967.3865,-3798.563;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;886.0101,-921.1548;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_AcidCloudOrb;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637912745812101339;  Blend;0;0;Two Sided;1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;13;0;7;0
WireConnection;116;0;113;0
WireConnection;116;1;114;0
WireConnection;122;0;117;0
WireConnection;122;1;116;0
WireConnection;122;2;115;0
WireConnection;19;0;13;0
WireConnection;19;2;8;0
WireConnection;19;1;12;0
WireConnection;22;0;11;0
WireConnection;16;0;13;0
WireConnection;16;2;15;0
WireConnection;16;1;14;0
WireConnection;28;0;19;0
WireConnection;28;1;20;0
WireConnection;30;0;16;0
WireConnection;30;1;17;0
WireConnection;126;0;122;0
WireConnection;126;3;123;1
WireConnection;126;4;123;2
WireConnection;26;0;22;0
WireConnection;26;1;21;0
WireConnection;136;0;126;0
WireConnection;31;0;30;0
WireConnection;32;0;28;0
WireConnection;34;0;26;0
WireConnection;38;0;34;0
WireConnection;51;1;42;0
WireConnection;51;2;39;0
WireConnection;50;0;42;0
WireConnection;54;1;40;0
WireConnection;54;2;43;0
WireConnection;59;0;55;0
WireConnection;58;0;50;0
WireConnection;58;1;51;0
WireConnection;60;0;53;0
WireConnection;56;0;54;0
WireConnection;56;1;52;0
WireConnection;64;0;60;0
WireConnection;64;1;59;0
WireConnection;65;0;58;0
WireConnection;65;1;56;0
WireConnection;68;0;65;0
WireConnection;67;0;64;0
WireConnection;181;0;169;0
WireConnection;181;2;172;0
WireConnection;70;0;63;0
WireConnection;74;0;67;0
WireConnection;74;1;69;0
WireConnection;75;0;58;0
WireConnection;75;1;68;0
WireConnection;185;0;169;0
WireConnection;185;2;166;0
WireConnection;127;0;120;0
WireConnection;127;1;119;1
WireConnection;125;0;120;0
WireConnection;125;1;119;2
WireConnection;71;0;70;0
WireConnection;79;0;74;0
WireConnection;79;1;72;0
WireConnection;132;0;127;0
WireConnection;77;0;75;0
WireConnection;77;1;73;0
WireConnection;192;1;181;0
WireConnection;189;1;185;0
WireConnection;134;0;125;0
WireConnection;198;0;189;0
WireConnection;198;1;187;0
WireConnection;195;0;192;1
WireConnection;195;1;188;0
WireConnection;153;0;132;0
WireConnection;148;0;134;0
WireConnection;84;0;79;0
WireConnection;83;0;77;0
WireConnection;80;0;71;1
WireConnection;202;0;198;0
WireConnection;202;1;197;1
WireConnection;202;2;197;2
WireConnection;202;3;197;3
WireConnection;202;4;197;4
WireConnection;163;0;153;0
WireConnection;163;3;151;0
WireConnection;163;4;154;0
WireConnection;201;0;195;0
WireConnection;201;1;199;1
WireConnection;201;2;199;2
WireConnection;201;3;199;3
WireConnection;201;4;199;4
WireConnection;162;0;148;0
WireConnection;162;3;152;0
WireConnection;162;4;149;0
WireConnection;88;0;80;0
WireConnection;157;0;122;0
WireConnection;90;0;85;0
WireConnection;90;1;87;0
WireConnection;174;2;163;0
WireConnection;174;3;162;0
WireConnection;89;0;86;0
WireConnection;89;1;88;0
WireConnection;209;0;202;0
WireConnection;209;1;201;0
WireConnection;223;0;221;0
WireConnection;223;1;222;0
WireConnection;219;0;209;0
WireConnection;177;0;174;0
WireConnection;177;1;171;0
WireConnection;96;0;89;0
WireConnection;96;1;85;0
WireConnection;96;2;90;0
WireConnection;224;0;223;0
WireConnection;99;0;96;0
WireConnection;193;0;177;0
WireConnection;200;0;193;0
WireConnection;228;0;226;0
WireConnection;228;1;227;0
WireConnection;236;0;228;0
WireConnection;236;1;237;0
WireConnection;103;0;97;0
WireConnection;103;1;100;0
WireConnection;230;0;233;0
WireConnection;230;1;226;0
WireConnection;111;0;110;0
WireConnection;109;0;104;0
WireConnection;109;1;103;0
WireConnection;271;0;270;0
WireConnection;271;1;229;0
WireConnection;229;0;255;0
WireConnection;229;1;254;0
WireConnection;110;0;106;0
WireConnection;110;1;105;0
WireConnection;262;0;236;0
WireConnection;262;1;263;0
WireConnection;254;0;231;0
WireConnection;254;1;257;0
WireConnection;231;0;232;0
WireConnection;231;1;227;0
WireConnection;255;0;230;0
WireConnection;255;1;256;0
WireConnection;217;0;210;0
WireConnection;210;0;215;0
WireConnection;210;1;214;0
WireConnection;242;0;243;0
WireConnection;241;0;242;0
WireConnection;246;0;240;0
WireConnection;246;1;244;0
WireConnection;246;2;245;0
WireConnection;266;0;260;0
WireConnection;266;1;267;0
WireConnection;264;0;259;0
WireConnection;264;1;265;0
WireConnection;253;0;246;0
WireConnection;268;0;264;0
WireConnection;268;1;266;0
WireConnection;250;0;240;0
WireConnection;240;0;241;1
WireConnection;252;0;249;0
WireConnection;259;0;252;0
WireConnection;259;1;203;0
WireConnection;260;0;253;0
WireConnection;260;1;203;0
WireConnection;249;0;250;0
WireConnection;249;1;248;0
WireConnection;249;2;247;0
WireConnection;269;0;268;0
WireConnection;1;2;271;0
WireConnection;1;3;262;0
WireConnection;1;5;109;0
ASEEND*/
//CHKSM=B28D4103A07599349B1FBB6D77B4E3D63435B955