// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX_Shader_NecroOrbChannel"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Main("Main", 2D) = "white" {}
		_TextureScale("TextureScale", Vector) = (5,5,0,0)
		_PanningSpeed("PanningSpeed", Vector) = (0,2,0,0)
		_Voronoi_2_Angle("Voronoi_2_Angle", Float) = 2
		_Noise_Speed("Noise_Speed", Vector) = (5,0,0,0)
		_Voronoi_2_Scale("Voronoi_2_Scale", Float) = 3
		_Opacity("Opacity", Float) = 20
		_PanningSpeed2("PanningSpeed2", Vector) = (0,-2,0,0)
		_NoiseScale("NoiseScale", Float) = 2.78
		_Voronoi_2_Power_Exp("Voronoi_2_Power_Exp", Range( 0 , 2)) = 0.7647059
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		_SideGradient("SideGradient", 2D) = "white" {}
		_Hight_Rec("Hight_Rec", Float) = 1.5
		_Disolve("Disolve", 2D) = "white" {}
		_Voronoi_Power("Voronoi_Power", Float) = 2
		[HDR]_Main_Colour("Main_Colour", Color) = (1,1,1,1)
		_Width_Rec("Width_Rec", Float) = 1
		_Emissive("Emissive", Range( 0 , 10)) = 1
		_Remaping("Remaping", Vector) = (0,1,0.4,1)
		_Voronoi_1_Scale("Voronoi_1_Scale", Float) = 0
		_PowerEXP("PowerEXP", Float) = 4.32
		[ASEEnd]_PolarPowerEXP("PolarPowerEXP", Float) = 1.15
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
				float4 ase_texcoord1 : TEXCOORD1;
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
			float4 _Main_Colour;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Main_ST;
			float4 _Remaping;
			float4 _SideGradient_ST;
			float2 _Noise_Speed;
			float2 _TextureScale;
			float2 _PanningSpeed;
			float2 _PanningSpeed2;
			float _Hight_Rec;
			float _Voronoi_1_Scale;
			float _PowerEXP;
			float _Voronoi_2_Angle;
			float _Voronoi_Power;
			float _NoiseScale;
			float _Emissive;
			float _Opacity;
			float _PolarPowerEXP;
			float _Voronoi_2_Scale;
			float _Width_Rec;
			float _Voronoi_2_Power_Exp;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _SideGradient;
			sampler2D _Main;
			sampler2D _Disolve;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
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
						return F1;
					}
			
					float2 voronoihash229( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi229( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash229( n + g );
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
						return F1;
					}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				o.ase_texcoord4 = v.ase_texcoord1;
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
				float4 ase_texcoord1 : TEXCOORD1;

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
				o.ase_texcoord1 = v.ase_texcoord1;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
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
				float2 texCoord242 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g3 = ( texCoord242 - float2( 0.5,0.5 ) );
				float2 break17_g3 = CenteredUV15_g3;
				float2 appendResult23_g3 = (float2(( length( CenteredUV15_g3 ) * 1.0 * 2.0 ) , ( atan2( break17_g3.x , break17_g3.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float clampResult257 = clamp( ( 1.0 - pow( appendResult23_g3.x , _PolarPowerEXP ) ) , 0.0 , 1.0 );
				float2 texCoord263 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner261 = ( _TimeParameters.x * _PanningSpeed2 + texCoord263);
				float simplePerlin2D260 = snoise( panner261*_NoiseScale );
				simplePerlin2D260 = simplePerlin2D260*0.5 + 0.5;
				float2 texCoord237 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner241 = ( _TimeParameters.x * _PanningSpeed + texCoord237);
				float simplePerlin2D244 = snoise( panner241*_NoiseScale );
				simplePerlin2D244 = simplePerlin2D244*0.5 + 0.5;
				float2 temp_cast_0 = ((-10.0 + (pow( ( simplePerlin2D260 + simplePerlin2D244 ) , _PowerEXP ) - 0.0) * (10.0 - -10.0) / (1.0 - 0.0))).xx;
				float2 appendResult10_g10 = (float2(_Width_Rec , _Hight_Rec));
				float2 temp_output_11_0_g10 = ( abs( (temp_cast_0*2.0 + -1.0) ) - appendResult10_g10 );
				float2 break16_g10 = ( 1.0 - ( temp_output_11_0_g10 / fwidth( temp_output_11_0_g10 ) ) );
				float ElecticalCurrents259 = ( clampResult257 * saturate( min( break16_g10.x , break16_g10.y ) ) );
				float time122 = 0.0;
				float2 voronoiSmoothId122 = 0;
				float2 texCoord111 = IN.ase_texcoord3.xy * _TextureScale + float2( 0,0 );
				float2 panner116 = ( 1.0 * _Time.y * _Noise_Speed + texCoord111);
				float2 coords122 = panner116 * _Voronoi_1_Scale;
				float2 id122 = 0;
				float2 uv122 = 0;
				float voroi122 = voronoi122( coords122, time122, id122, uv122, 0, voronoiSmoothId122 );
				float2 uv_SideGradient = IN.ase_texcoord3.xy * _SideGradient_ST.xy + _SideGradient_ST.zw;
				float4 temp_cast_1 = (_Voronoi_Power).xxxx;
				float4 temp_cast_2 = (_Remaping.x).xxxx;
				float4 temp_cast_3 = (_Remaping.y).xxxx;
				float4 temp_cast_4 = (_Remaping.z).xxxx;
				float4 temp_cast_5 = (_Remaping.w).xxxx;
				float4 clampResult200 = clamp( (temp_cast_4 + (pow( ( ( ElecticalCurrents259 * 3.0 ) * ( voroi122 * tex2D( _SideGradient, uv_SideGradient ) ) ) , temp_cast_1 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
				float2 uv_Main = IN.ase_texcoord3.xy * _Main_ST.xy + _Main_ST.zw;
				float clampResult190 = clamp( ( tex2D( _Main, uv_Main ).a * _Opacity ) , 0.0 , 1.0 );
				float4 appendResult172 = (float4(0.0 , 0.0 , _SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
				float4 texCoord173 = IN.ase_texcoord3;
				texCoord173.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner174 = ( 1.0 * _Time.y * appendResult172.xy + texCoord173.xy);
				float2 break175 = panner174;
				float4 texCoord176 = IN.ase_texcoord4;
				texCoord176.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult179 = (float2(break175.x , ( texCoord176.w + break175.y )));
				float t178 = texCoord173.w;
				float w183 = texCoord173.z;
				float3 _Vector0 = float3(0.3,0,1);
				float ifLocalVar191 = 0;
				if( ( tex2D( _Disolve, appendResult179 ).r * t178 ) >= w183 )
				ifLocalVar191 = _Vector0.y;
				else
				ifLocalVar191 = _Vector0.z;
				float4 appendResult193 = (float4(0.0 , 0.0 , 0.0 , ( IN.ase_color.a * clampResult190 * ifLocalVar191 )));
				float4 appendResult194 = (float4(( ( _Main_Colour * IN.ase_color ) + ( clampResult200 * _Emissive * IN.ase_color ) ).rgb , appendResult193.x));
				
				float time229 = ( _Voronoi_2_Angle * _TimeParameters.x );
				float2 voronoiSmoothId229 = 0;
				float2 coords229 = IN.ase_texcoord3.xy * _Voronoi_2_Scale;
				float2 id229 = 0;
				float2 uv229 = 0;
				float voroi229 = voronoi229( coords229, time229, id229, uv229, 0, voronoiSmoothId229 );
				float4 appendResult228 = (float4(IN.ase_texcoord4.x , IN.ase_texcoord4.y , _Voronoi_2_Power_Exp , _Voronoi_2_Power_Exp));
				float Disolve231 = pow( voroi229 , appendResult228.x );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( appendResult194 + appendResult193 ).xyz;
				float Alpha = ( clampResult200.a * Disolve231 );
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
				float4 ase_texcoord1 : TEXCOORD1;
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
			float4 _Main_Colour;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Main_ST;
			float4 _Remaping;
			float4 _SideGradient_ST;
			float2 _Noise_Speed;
			float2 _TextureScale;
			float2 _PanningSpeed;
			float2 _PanningSpeed2;
			float _Hight_Rec;
			float _Voronoi_1_Scale;
			float _PowerEXP;
			float _Voronoi_2_Angle;
			float _Voronoi_Power;
			float _NoiseScale;
			float _Emissive;
			float _Opacity;
			float _PolarPowerEXP;
			float _Voronoi_2_Scale;
			float _Width_Rec;
			float _Voronoi_2_Power_Exp;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _SideGradient;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
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
						return F1;
					}
			
					float2 voronoihash229( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi229( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash229( n + g );
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
						return F1;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
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
				float4 ase_texcoord1 : TEXCOORD1;

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
				o.ase_texcoord1 = v.ase_texcoord1;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
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

				float2 texCoord242 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g3 = ( texCoord242 - float2( 0.5,0.5 ) );
				float2 break17_g3 = CenteredUV15_g3;
				float2 appendResult23_g3 = (float2(( length( CenteredUV15_g3 ) * 1.0 * 2.0 ) , ( atan2( break17_g3.x , break17_g3.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float clampResult257 = clamp( ( 1.0 - pow( appendResult23_g3.x , _PolarPowerEXP ) ) , 0.0 , 1.0 );
				float2 texCoord263 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner261 = ( _TimeParameters.x * _PanningSpeed2 + texCoord263);
				float simplePerlin2D260 = snoise( panner261*_NoiseScale );
				simplePerlin2D260 = simplePerlin2D260*0.5 + 0.5;
				float2 texCoord237 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner241 = ( _TimeParameters.x * _PanningSpeed + texCoord237);
				float simplePerlin2D244 = snoise( panner241*_NoiseScale );
				simplePerlin2D244 = simplePerlin2D244*0.5 + 0.5;
				float2 temp_cast_0 = ((-10.0 + (pow( ( simplePerlin2D260 + simplePerlin2D244 ) , _PowerEXP ) - 0.0) * (10.0 - -10.0) / (1.0 - 0.0))).xx;
				float2 appendResult10_g10 = (float2(_Width_Rec , _Hight_Rec));
				float2 temp_output_11_0_g10 = ( abs( (temp_cast_0*2.0 + -1.0) ) - appendResult10_g10 );
				float2 break16_g10 = ( 1.0 - ( temp_output_11_0_g10 / fwidth( temp_output_11_0_g10 ) ) );
				float ElecticalCurrents259 = ( clampResult257 * saturate( min( break16_g10.x , break16_g10.y ) ) );
				float time122 = 0.0;
				float2 voronoiSmoothId122 = 0;
				float2 texCoord111 = IN.ase_texcoord2.xy * _TextureScale + float2( 0,0 );
				float2 panner116 = ( 1.0 * _Time.y * _Noise_Speed + texCoord111);
				float2 coords122 = panner116 * _Voronoi_1_Scale;
				float2 id122 = 0;
				float2 uv122 = 0;
				float voroi122 = voronoi122( coords122, time122, id122, uv122, 0, voronoiSmoothId122 );
				float2 uv_SideGradient = IN.ase_texcoord2.xy * _SideGradient_ST.xy + _SideGradient_ST.zw;
				float4 temp_cast_1 = (_Voronoi_Power).xxxx;
				float4 temp_cast_2 = (_Remaping.x).xxxx;
				float4 temp_cast_3 = (_Remaping.y).xxxx;
				float4 temp_cast_4 = (_Remaping.z).xxxx;
				float4 temp_cast_5 = (_Remaping.w).xxxx;
				float4 clampResult200 = clamp( (temp_cast_4 + (pow( ( ( ElecticalCurrents259 * 3.0 ) * ( voroi122 * tex2D( _SideGradient, uv_SideGradient ) ) ) , temp_cast_1 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
				float time229 = ( _Voronoi_2_Angle * _TimeParameters.x );
				float2 voronoiSmoothId229 = 0;
				float2 coords229 = IN.ase_texcoord2.xy * _Voronoi_2_Scale;
				float2 id229 = 0;
				float2 uv229 = 0;
				float voroi229 = voronoi229( coords229, time229, id229, uv229, 0, voronoiSmoothId229 );
				float4 appendResult228 = (float4(IN.ase_texcoord3.x , IN.ase_texcoord3.y , _Voronoi_2_Power_Exp , _Voronoi_2_Power_Exp));
				float Disolve231 = pow( voroi229 , appendResult228.x );
				
				float Alpha = ( clampResult200.a * Disolve231 );
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
385;224;1139;440;2076.82;280.175;1.578919;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;263;-4486.121,-1201.539;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;238;-4439.55,-928.9553;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;239;-4445.17,-589.7523;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;240;-4452.17,-717.7523;Inherit;False;Property;_PanningSpeed;PanningSpeed;2;0;Create;True;0;0;0;False;0;False;0,2;0,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;237;-4458.17,-842.7523;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;262;-4446.55,-1056.955;Inherit;False;Property;_PanningSpeed2;PanningSpeed2;7;0;Create;True;0;0;0;False;0;False;0,-2;0,-2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;242;-4242.827,-618.2194;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;243;-4252.534,-872.6233;Inherit;False;Property;_NoiseScale;NoiseScale;8;0;Create;True;0;0;0;False;0;False;2.78;3.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;261;-4232.55,-1078.955;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;241;-4238.17,-739.7522;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;260;-4046.642,-1033.363;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;245;-4011.914,-615.5743;Inherit;False;Polar Coordinates;-1;;3;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;244;-4050.975,-766.8732;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-3774.764,-503.9883;Inherit;False;Property;_PolarPowerEXP;PolarPowerEXP;21;0;Create;True;0;0;0;False;0;False;1.15;2.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-3857.999,-812.3163;Inherit;False;Property;_PowerEXP;PowerEXP;20;0;Create;True;0;0;0;False;0;False;4.32;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;248;-3848.981,-924.7833;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;249;-3728.012,-617.4484;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;250;-3730.796,-919.2244;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;251;-3575.197,-583.7103;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-3581.866,-662.4873;Inherit;False;Property;_Hight_Rec;Hight_Rec;12;0;Create;True;0;0;0;False;0;False;1.5;15.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;254;-3431.904,-593.1783;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;255;-3590.658,-916.2063;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-10;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;253;-3579.21,-748.1802;Inherit;False;Property;_Width_Rec;Width_Rec;16;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;256;-3395.142,-916.1263;Inherit;False;Rectangle;-1;;10;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;257;-3284.213,-598.2883;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;112;-3414.729,-391.0016;Inherit;False;Property;_TextureScale;TextureScale;1;0;Create;True;0;0;0;False;0;False;5,5;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;258;-3128.341,-766.8383;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-3179.182,-402.4181;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;117;-3224.277,-68.58639;Inherit;False;Property;_Noise_Speed;Noise_Speed;4;0;Create;True;0;0;0;False;0;False;5,0;5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-2902.527,-768.6572;Inherit;False;ElecticalCurrents;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;116;-2943.254,-212.2567;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-2862.231,15.05789;Inherit;False;Property;_Voronoi_1_Scale;Voronoi_1_Scale;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-2596.324,-339.0537;Inherit;False;259;ElecticalCurrents;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;122;-2574.942,-215.806;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT;1;FLOAT2;2
Node;AmplifyShaderEditor.SamplerNode;124;-2592.258,50.40567;Inherit;True;Property;_SideGradient;SideGradient;11;0;Create;True;0;0;0;False;0;False;-1;None;b6939a0a96d4bf742bb2cbafe58e8f4d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-2204.281,-347.2848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;222;-189.3876,1201.591;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2246.4,-140.2722;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-190.2496,1127.545;Inherit;False;Property;_Voronoi_2_Angle;Voronoi_2_Angle;3;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-1933.669,3.282318;Inherit;False;Property;_Voronoi_Power;Voronoi_Power;14;0;Create;True;0;0;0;False;0;False;2;1.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;52.61243,1114.591;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;225;-221.1505,1268.431;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;224;30.82751,1206.56;Inherit;False;Property;_Voronoi_2_Scale;Voronoi_2_Scale;5;0;Create;True;0;0;0;False;0;False;3;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-1950.005,-223.1721;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-175.7345,1436.976;Inherit;False;Property;_Voronoi_2_Power_Exp;Voronoi_2_Power_Exp;9;0;Create;True;0;0;0;False;0;False;0.7647059;0.721;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;228;369.8495,1346.431;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;198;-1605.245,-104.9727;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;197;-1580.91,135.8674;Inherit;False;Property;_Remaping;Remaping;18;0;Create;True;0;0;0;False;0;False;0,1,0.4,1;0,1,0,1.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;229;227.3354,1111.037;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TFHCRemapNode;199;-1301.813,-63.28764;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;230;561.5562,1113.536;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT4;2,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;789.7058,1111.108;Inherit;False;Disolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;200;-1009.654,0.5103416;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;217;437.7929,757.7086;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;234;679.1469,869.8582;Inherit;False;231;Disolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;191;-856.5403,1012.29;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-734.8198,-45.3416;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;190;-843.7293,875.9069;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;176;-1920.05,1041.992;Inherit;True;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;195;461.4861,519.8169;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;-511.0031,-14.43669;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;174;-2102.547,935.9807;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;196;-2229.655,459.3922;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-1104.277,1130.302;Inherit;False;183;w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-1956.278,776.6522;Inherit;False;t;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;175;-1882.237,932.8801;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;179;-1543.216,1002.062;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-1072.455,226.3323;Inherit;False;Property;_Emissive;Emissive;17;0;Create;True;0;0;0;False;0;False;1;2.74;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;193;-470.9563,696.1804;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-1947.321,670.8301;Inherit;False;w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-1010.832,867.6328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-1305.266,1195.032;Inherit;False;178;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-1656.223,1071.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;182;-1399.739,992.9246;Inherit;True;Property;_Disolve;Disolve;13;0;Create;True;0;0;0;False;0;False;-1;None;bb7c81375e179db4e8b896b8219c8151;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1077.482,1029.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;201;-986.0286,-199.2405;Inherit;False;Property;_Main_Colour;Main_Colour;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1.41976,0.6100529,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;173;-2250.853,645.8861;Inherit;True;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-673.485,732.6975;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-2235.252,940.7278;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-1166.078,911.3698;Inherit;False;Property;_Opacity;Opacity;6;0;Create;True;0;0;0;False;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;189;-914.9583,694.1606;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;871.1469,751.8582;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;185;-1101.95,1208.419;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0.3,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;171;-2619.23,623.9706;Inherit;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-683.7097,95.15034;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;194;175.71,423.3661;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;181;-1320.384,718.6064;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;210;1119.267,605.3928;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;212;1119.267,605.3928;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;209;1198.267,616.3928;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;VFX_Shader_NecroOrbChannel;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637913691294526853;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;637913691340214833;  Use Shadow Threshold;0;0;Receive Shadows;0;637913691351281562;GPU Instancing;1;637913691349223196;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;208;1119.267,605.3928;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;211;1119.267,605.3928;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;261;0;263;0
WireConnection;261;2;262;0
WireConnection;261;1;238;0
WireConnection;241;0;237;0
WireConnection;241;2;240;0
WireConnection;241;1;239;0
WireConnection;260;0;261;0
WireConnection;260;1;243;0
WireConnection;245;1;242;0
WireConnection;244;0;241;0
WireConnection;244;1;243;0
WireConnection;248;0;260;0
WireConnection;248;1;244;0
WireConnection;249;0;245;0
WireConnection;250;0;248;0
WireConnection;250;1;247;0
WireConnection;251;0;249;0
WireConnection;251;1;246;0
WireConnection;254;0;251;0
WireConnection;255;0;250;0
WireConnection;256;1;255;0
WireConnection;256;2;253;0
WireConnection;256;3;252;0
WireConnection;257;0;254;0
WireConnection;258;0;257;0
WireConnection;258;1;256;0
WireConnection;111;0;112;0
WireConnection;259;0;258;0
WireConnection;116;0;111;0
WireConnection;116;2;117;0
WireConnection;122;0;116;0
WireConnection;122;2;235;0
WireConnection;236;0;264;0
WireConnection;125;0;122;0
WireConnection;125;1;124;0
WireConnection;227;0;223;0
WireConnection;227;1;222;0
WireConnection;218;0;236;0
WireConnection;218;1;125;0
WireConnection;228;0;225;1
WireConnection;228;1;225;2
WireConnection;228;2;226;0
WireConnection;228;3;226;0
WireConnection;198;0;218;0
WireConnection;198;1;206;0
WireConnection;229;1;227;0
WireConnection;229;2;224;0
WireConnection;199;0;198;0
WireConnection;199;1;197;1
WireConnection;199;2;197;2
WireConnection;199;3;197;3
WireConnection;199;4;197;4
WireConnection;230;0;229;0
WireConnection;230;1;228;0
WireConnection;231;0;230;0
WireConnection;200;0;199;0
WireConnection;217;0;200;0
WireConnection;191;0;186;0
WireConnection;191;1;188;0
WireConnection;191;2;185;2
WireConnection;191;3;185;2
WireConnection;191;4;185;3
WireConnection;204;0;201;0
WireConnection;204;1;189;0
WireConnection;190;0;187;0
WireConnection;195;0;194;0
WireConnection;195;1;193;0
WireConnection;205;0;204;0
WireConnection;205;1;203;0
WireConnection;174;0;173;0
WireConnection;174;2;172;0
WireConnection;196;0;171;1
WireConnection;196;1;171;2
WireConnection;178;0;173;4
WireConnection;175;0;174;0
WireConnection;179;0;175;0
WireConnection;179;1;177;0
WireConnection;193;3;192;0
WireConnection;183;0;173;3
WireConnection;187;0;181;4
WireConnection;187;1;180;0
WireConnection;177;0;176;4
WireConnection;177;1;175;1
WireConnection;182;1;179;0
WireConnection;186;0;182;1
WireConnection;186;1;184;0
WireConnection;192;0;189;4
WireConnection;192;1;190;0
WireConnection;192;2;191;0
WireConnection;172;2;171;3
WireConnection;172;3;171;4
WireConnection;233;0;217;3
WireConnection;233;1;234;0
WireConnection;203;0;200;0
WireConnection;203;1;202;0
WireConnection;203;2;189;0
WireConnection;194;0;205;0
WireConnection;194;3;193;0
WireConnection;209;2;195;0
WireConnection;209;3;233;0
ASEEND*/
//CHKSM=52740EE696D63E6FC0969A2030FC6F856CEE9F36