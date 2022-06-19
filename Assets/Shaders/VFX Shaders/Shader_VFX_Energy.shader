// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_Energy"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Voronoi_Speed("Voronoi_Speed", Float) = 1
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		_PanningSpeed("PanningSpeed", Vector) = (0,2,0,0)
		_Texture2("Texture 2", 2D) = "white" {}
		_Smoothstep_Fade("Smoothstep_Fade", Range( 0 , 100)) = 0
		_PanningSpeed2("PanningSpeed2", Vector) = (0,-2,0,0)
		_NoiseScale("NoiseScale", Float) = 2.78
		_SmoothStep_Fill("SmoothStep_Fill", Range( -2 , 2)) = 0
		_Hight_Rec("Hight_Rec", Float) = 1.5
		_Flashing_MainXYZ("Flashing_Main (XYZ)", Vector) = (1,1,1,0)
		_Width_Rec("Width_Rec", Float) = 1
		_Panning_MainXYZ("Panning_Main (XYZ)", Vector) = (1,1,1,0)
		[HDR]_BaseColour_2("BaseColour_2", Color) = (1,1,1,0)
		[HDR]_BaseColour_1("BaseColour_1", Color) = (1,1,1,0)
		_PowerEXP("PowerEXP", Float) = 4.32
		_RemapNews("Remap News", Vector) = (0,0,0,0)
		_PolarPowerEXP("PolarPowerEXP", Float) = 1.15
		_Fres_Scale_MinNew("Fres_Scale_MinNew", Float) = 1
		_Fres_Power_MaxNew("Fres_Power_MaxNew", Float) = 5
		_Fres_Scale_MaxNew("Fres_Scale_MaxNew", Float) = 2
		_Fres_Power_MinNew("Fres_Power_MinNew", Float) = 3
		[ASEEnd]_Fres_ScaleX_PowerY_Speeds("Fres_Scale(X)_Power(Y)_Speeds", Vector) = (1,1,0,0)

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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour_2;
			float4 _BaseColour_1;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float2 _PanningSpeed2;
			float2 _PanningSpeed;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _Hight_Rec;
			float _SmoothStep_Fill;
			float _Width_Rec;
			float _PowerEXP;
			float _NoiseScale;
			float _PolarPowerEXP;
			float _Voronoi_Speed;
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
			sampler2D _Texture1;
			sampler2D _Texture3;
			sampler2D _Texture2;


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
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
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
				float PanningOnX145 = _Panning_MainXYZ.x;
				float mulTime166 = _TimeParameters.x * PanningOnX145;
				float2 texCoord169 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner172 = ( mulTime166 * float2( 1.5,0.3 ) + texCoord169);
				float FlashingOnX161 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X187 = ( tex2D( _Texture1, panner172 ) * FlashingOnX161 );
				float PanningOnY143 = _Panning_MainXYZ.y;
				float mulTime168 = _TimeParameters.x * PanningOnY143;
				float2 texCoord167 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner176 = ( mulTime168 * float2( 0,1.5 ) + texCoord167);
				float FlashingOnY160 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y189 = ( tex2D( _Texture3, panner176 ) * FlashingOnY160 );
				float PanningOnZ144 = _Panning_MainXYZ.z;
				float mulTime171 = _TimeParameters.x * PanningOnZ144;
				float2 texCoord170 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner173 = ( mulTime171 * float2( 1.5,0 ) + texCoord170);
				float temp_output_4_0_g9 = 1.0;
				float temp_output_5_0_g9 = 2.0;
				float2 appendResult7_g9 = (float2(temp_output_4_0_g9 , temp_output_5_0_g9));
				float totalFrames39_g9 = ( temp_output_4_0_g9 * temp_output_5_0_g9 );
				float2 appendResult8_g9 = (float2(totalFrames39_g9 , temp_output_5_0_g9));
				float clampResult42_g9 = clamp( 0.0 , 0.0001 , ( totalFrames39_g9 - 1.0 ) );
				float temp_output_35_0_g9 = frac( ( ( _TimeParameters.x + clampResult42_g9 ) / totalFrames39_g9 ) );
				float2 appendResult29_g9 = (float2(temp_output_35_0_g9 , ( 1.0 - temp_output_35_0_g9 )));
				float2 temp_output_15_0_g9 = ( ( panner173 / appendResult7_g9 ) + ( floor( ( appendResult8_g9 * appendResult29_g9 ) ) / appendResult7_g9 ) );
				float FlashingOnZ159 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z188 = ( tex2D( _Texture2, temp_output_15_0_g9 ) * FlashingOnZ159 );
				float2 texCoord73 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g3 = ( texCoord73 - float2( 0.5,0.5 ) );
				float2 break17_g3 = CenteredUV15_g3;
				float2 appendResult23_g3 = (float2(( length( CenteredUV15_g3 ) * 1.0 * 2.0 ) , ( atan2( break17_g3.x , break17_g3.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float clampResult92 = clamp( ( 1.0 - pow( appendResult23_g3.x , _PolarPowerEXP ) ) , 0.0 , 1.0 );
				float2 texCoord102 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner107 = ( _TimeParameters.x * _PanningSpeed2 + texCoord102);
				float simplePerlin2D116 = snoise( panner107*_NoiseScale );
				simplePerlin2D116 = simplePerlin2D116*0.5 + 0.5;
				float2 texCoord99 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner106 = ( _TimeParameters.x * _PanningSpeed + texCoord99);
				float simplePerlin2D117 = snoise( panner106*_NoiseScale );
				simplePerlin2D117 = simplePerlin2D117*0.5 + 0.5;
				float2 temp_cast_0 = ((-10.0 + (pow( ( simplePerlin2D116 + simplePerlin2D117 ) , _PowerEXP ) - 0.0) * (10.0 - -10.0) / (1.0 - 0.0))).xx;
				float2 appendResult10_g10 = (float2(_Width_Rec , _Hight_Rec));
				float2 temp_output_11_0_g10 = ( abs( (temp_cast_0*2.0 + -1.0) ) - appendResult10_g10 );
				float2 break16_g10 = ( 1.0 - ( temp_output_11_0_g10 / fwidth( temp_output_11_0_g10 ) ) );
				float ElecticalCurrents118 = ( clampResult92 * saturate( min( break16_g10.x , break16_g10.y ) ) );
				float2 texCoord18 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv17 = 0;
				float3 unityVoronoy17 = UnityVoronoi(texCoord18,( _TimeParameters.x * _Voronoi_Speed ),10.0,uv17);
				float Voronoi40 = (_RemapNews.x + (unityVoronoy17.x - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV63 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode63 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (1.0 - 0.0)) * pow( 1.0 - fresnelNdotV63, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float Fresnel_Pulse65 = fresnelNode63;
				float temp_output_67_0 = ( Voronoi40 * Fresnel_Pulse65 );
				
				float3 worldToObj6 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult15 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Voronoi40 + ( 1.0 - (0.0 + (worldToObj6.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha16 = smoothstepResult15;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( _BaseColour_2 * ( LightningMain_X187 + LightningMain_Y189 + LightningMain_Z188 + ElecticalCurrents118 ) ) + ( _BaseColour_1 * temp_output_67_0 ) ).rgb;
				float Alpha = ( ( LightningMain_Z188 + temp_output_67_0 + LightningMain_X187 + LightningMain_Y189 + ElecticalCurrents118 ) * DisolveAlpha16 ).r;
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
			float4 _BaseColour_2;
			float4 _BaseColour_1;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float2 _PanningSpeed2;
			float2 _PanningSpeed;
			float2 _Fres_ScaleX_PowerY_Speeds;
			float2 _RemapNews;
			float _Fres_Power_MaxNew;
			float _Fres_Power_MinNew;
			float _Fres_Scale_MaxNew;
			float _Fres_Scale_MinNew;
			float _Hight_Rec;
			float _SmoothStep_Fill;
			float _Width_Rec;
			float _PowerEXP;
			float _NoiseScale;
			float _PolarPowerEXP;
			float _Voronoi_Speed;
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
			sampler2D _Texture2;
			sampler2D _Texture1;
			sampler2D _Texture3;


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

				float PanningOnZ144 = _Panning_MainXYZ.z;
				float mulTime171 = _TimeParameters.x * PanningOnZ144;
				float2 texCoord170 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner173 = ( mulTime171 * float2( 1.5,0 ) + texCoord170);
				float temp_output_4_0_g9 = 1.0;
				float temp_output_5_0_g9 = 2.0;
				float2 appendResult7_g9 = (float2(temp_output_4_0_g9 , temp_output_5_0_g9));
				float totalFrames39_g9 = ( temp_output_4_0_g9 * temp_output_5_0_g9 );
				float2 appendResult8_g9 = (float2(totalFrames39_g9 , temp_output_5_0_g9));
				float clampResult42_g9 = clamp( 0.0 , 0.0001 , ( totalFrames39_g9 - 1.0 ) );
				float temp_output_35_0_g9 = frac( ( ( _TimeParameters.x + clampResult42_g9 ) / totalFrames39_g9 ) );
				float2 appendResult29_g9 = (float2(temp_output_35_0_g9 , ( 1.0 - temp_output_35_0_g9 )));
				float2 temp_output_15_0_g9 = ( ( panner173 / appendResult7_g9 ) + ( floor( ( appendResult8_g9 * appendResult29_g9 ) ) / appendResult7_g9 ) );
				float FlashingOnZ159 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z188 = ( tex2D( _Texture2, temp_output_15_0_g9 ) * FlashingOnZ159 );
				float2 texCoord18 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv17 = 0;
				float3 unityVoronoy17 = UnityVoronoi(texCoord18,( _TimeParameters.x * _Voronoi_Speed ),10.0,uv17);
				float Voronoi40 = (_RemapNews.x + (unityVoronoy17.x - 0.0) * (_RemapNews.y - _RemapNews.x) / (1.0 - 0.0));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV63 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode63 = ( 0.0 + (_Fres_Scale_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.x ) ) ) - 0.0) * (_Fres_Scale_MaxNew - _Fres_Scale_MinNew) / (1.0 - 0.0)) * pow( 1.0 - fresnelNdotV63, (_Fres_Power_MinNew + (abs( sin( ( _TimeParameters.x * _Fres_ScaleX_PowerY_Speeds.y ) ) ) - 0.0) * (_Fres_Power_MaxNew - _Fres_Power_MinNew) / (1.0 - 0.0)) ) );
				float Fresnel_Pulse65 = fresnelNode63;
				float temp_output_67_0 = ( Voronoi40 * Fresnel_Pulse65 );
				float PanningOnX145 = _Panning_MainXYZ.x;
				float mulTime166 = _TimeParameters.x * PanningOnX145;
				float2 texCoord169 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner172 = ( mulTime166 * float2( 1.5,0.3 ) + texCoord169);
				float FlashingOnX161 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X187 = ( tex2D( _Texture1, panner172 ) * FlashingOnX161 );
				float PanningOnY143 = _Panning_MainXYZ.y;
				float mulTime168 = _TimeParameters.x * PanningOnY143;
				float2 texCoord167 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner176 = ( mulTime168 * float2( 0,1.5 ) + texCoord167);
				float FlashingOnY160 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y189 = ( tex2D( _Texture3, panner176 ) * FlashingOnY160 );
				float2 texCoord73 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g3 = ( texCoord73 - float2( 0.5,0.5 ) );
				float2 break17_g3 = CenteredUV15_g3;
				float2 appendResult23_g3 = (float2(( length( CenteredUV15_g3 ) * 1.0 * 2.0 ) , ( atan2( break17_g3.x , break17_g3.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float clampResult92 = clamp( ( 1.0 - pow( appendResult23_g3.x , _PolarPowerEXP ) ) , 0.0 , 1.0 );
				float2 texCoord102 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner107 = ( _TimeParameters.x * _PanningSpeed2 + texCoord102);
				float simplePerlin2D116 = snoise( panner107*_NoiseScale );
				simplePerlin2D116 = simplePerlin2D116*0.5 + 0.5;
				float2 texCoord99 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner106 = ( _TimeParameters.x * _PanningSpeed + texCoord99);
				float simplePerlin2D117 = snoise( panner106*_NoiseScale );
				simplePerlin2D117 = simplePerlin2D117*0.5 + 0.5;
				float2 temp_cast_0 = ((-10.0 + (pow( ( simplePerlin2D116 + simplePerlin2D117 ) , _PowerEXP ) - 0.0) * (10.0 - -10.0) / (1.0 - 0.0))).xx;
				float2 appendResult10_g10 = (float2(_Width_Rec , _Hight_Rec));
				float2 temp_output_11_0_g10 = ( abs( (temp_cast_0*2.0 + -1.0) ) - appendResult10_g10 );
				float2 break16_g10 = ( 1.0 - ( temp_output_11_0_g10 / fwidth( temp_output_11_0_g10 ) ) );
				float ElecticalCurrents118 = ( clampResult92 * saturate( min( break16_g10.x , break16_g10.y ) ) );
				float3 worldToObj6 = mul( GetWorldToObjectMatrix(), float4( WorldPosition, 1 ) ).xyz;
				float smoothstepResult15 = smoothstep( _SmoothStep_Fill , ( _SmoothStep_Fill + _Smoothstep_Fade ) , ( Voronoi40 + ( 1.0 - (0.0 + (worldToObj6.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				float DisolveAlpha16 = smoothstepResult15;
				
				float Alpha = ( ( LightningMain_Z188 + temp_output_67_0 + LightningMain_X187 + LightningMain_Y189 + ElecticalCurrents118 ) * DisolveAlpha16 ).r;
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
665;219;1920;994;2378.452;782.3721;2.584121;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;99;-4621.676,1233.088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;146;-3136.342,-370.0543;Inherit;False;Property;_Panning_MainXYZ;Panning_Main (XYZ);13;0;Create;True;0;0;0;False;0;False;1,1,1;1,0.2,-0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;101;-4610.055,1018.885;Inherit;False;Property;_PanningSpeed2;PanningSpeed2;6;0;Create;True;0;0;0;False;0;False;0,-2;0,-2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;103;-4603.055,1146.885;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-4649.626,874.3018;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;68;-4608.676,1486.088;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;100;-4615.676,1358.088;Inherit;False;Property;_PanningSpeed;PanningSpeed;3;0;Create;True;0;0;0;False;0;False;0,2;0,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;50;-4090.327,327.8163;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;49;-4213.633,394.3794;Inherit;False;Property;_Fres_ScaleX_PowerY_Speeds;Fres_Scale(X)_Power(Y)_Speeds;24;0;Create;True;0;0;0;False;0;False;1,1;5,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;106;-4401.676,1336.088;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-3891.84,499.6931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-4014.635,-713.3743;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-4406.332,1457.621;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-4024.635,-642.3745;Inherit;False;Property;_Voronoi_Speed;Voronoi_Speed;0;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-2831.7,-298.6973;Inherit;False;PanningOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;150;-3480.37,-185.7561;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;148;-3494.98,-72.86404;Inherit;False;Property;_Flashing_MainXYZ;Flashing_Main (XYZ);11;0;Create;True;0;0;0;False;0;False;1,1,1;5,10,3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;107;-4396.055,996.8849;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-3888.665,265.2357;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-4416.039,1203.217;Inherit;False;Property;_NoiseScale;NoiseScale;7;0;Create;True;0;0;0;False;0;False;2.78;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;54;-3753.972,270.4328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;116;-4210.146,1042.477;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-3916.276,-835.796;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-3839.636,-611.3745;Inherit;False;Constant;_Voronoi_Scale;Voronoi_Scale;2;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;117;-4214.479,1308.967;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-4175.418,1460.266;Inherit;False;Polar Coordinates;-1;;3;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-4352.799,709.3568;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;53;-3757.147,504.8901;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-2831.865,-373.7382;Inherit;False;PanningOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-3268.102,-106.8097;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-3264.102,-11.8095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-2775.429,650.1886;Inherit;False;144;PanningOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-3272.708,-215.3369;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-2835.626,-447.4452;Inherit;False;PanningOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-3834.636,-713.3743;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;55;-3639.498,509.619;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3938.268,1571.852;Inherit;False;Property;_PolarPowerEXP;PolarPowerEXP;19;0;Create;True;0;0;0;False;0;False;1.15;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;17;-3645.483,-743.8311;Inherit;True;0;0;1;3;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.Vector2Node;48;-3365.601,-519.1703;Inherit;False;Property;_RemapNews;Remap News;18;0;Create;True;0;0;0;False;0;False;0,0;0,1.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;56;-3760.635,348.3794;Inherit;False;Property;_Fres_Scale_MinNew;Fres_Scale_MinNew;20;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-4021.503,1263.524;Inherit;False;Property;_PowerEXP;PowerEXP;17;0;Create;True;0;0;0;False;0;False;4.32;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-3763.811,582.837;Inherit;False;Property;_Fres_Power_MinNew;Fres_Power_MinNew;23;0;Create;True;0;0;0;False;0;False;3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3761.635,421.3794;Inherit;False;Property;_Fres_Scale_MaxNew;Fres_Scale_MaxNew;22;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;57;-3636.321,275.1618;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;6;-4161.47,723.2875;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;60;-3763.811,655.837;Inherit;False;Property;_Fres_Power_MaxNew;Fres_Power_MaxNew;21;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;171;-2588.608,651.8776;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;154;-3134.41,-109.6126;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-2337.864,179.6306;Inherit;False;143;PanningOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;170;-2630.848,529.7394;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;165;-2311.762,-245.9005;Inherit;False;145;PanningOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-4012.485,1151.057;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;153;-3130.41,-14.61241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;155;-3145.015,-212.14;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;82;-3891.516,1458.392;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;166;-2110.942,-243.2116;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;173;-2406.21,531.0865;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;168;-2137.044,182.3196;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;115;-3894.3,1156.616;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;158;-2979.411,-11.41509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;157;-2983.411,-211.415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;169;-2153.182,-365.3491;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;85;-3738.701,1492.13;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;62;-3508.498,511.619;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;61;-3521.321,280.162;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;45;-3109.601,-733.1697;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;7;-3950.01,732.6105;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.AbsOpNode;156;-2982.411,-112.4151;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;167;-2179.284,60.18138;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;172;-1928.541,-364.0022;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;203;-2206.693,529.0329;Inherit;True;Flipbook;-1;;9;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;1;False;5;FLOAT;2;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-2831.427,-117.8955;Inherit;False;FlashingOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-2829.741,-218.0678;Inherit;False;FlashingOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;175;-2321.216,317.6505;Inherit;True;Property;_Texture2;Texture 2;4;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TFHCRemapNode;8;-3736.726,752.9619;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;174;-2006.355,-561.1937;Inherit;True;Property;_Texture1;Texture 1;1;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;76;-3745.37,1413.353;Inherit;False;Property;_Hight_Rec;Hight_Rec;10;0;Create;True;0;0;0;False;0;False;1.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-2830.427,-17.89507;Inherit;False;FlashingOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;177;-2077.97,-132.9856;Inherit;True;Property;_Texture3;Texture 3;2;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;79;-3742.714,1327.66;Inherit;False;Property;_Width_Rec;Width_Rec;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;87;-3595.408,1482.662;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;176;-1954.644,61.52861;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;63;-3320.762,326.7353;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-2842.963,-530.6932;Inherit;False;Voronoi;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;88;-3754.162,1159.634;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-10;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;181;-1774.303,-57.98248;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;180;-1758.549,373.6532;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1595.795,-288.2185;Inherit;False;161;FlashingOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-1667.411,139.9898;Inherit;False;160;FlashingOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3858.335,1030.442;Inherit;False;Property;_Smoothstep_Fade;Smoothstep_Fade;5;0;Create;True;0;0;0;False;0;False;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-1651.657,571.6255;Inherit;False;159;FlashingOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-3556.405,755.7126;Inherit;False;40;Voronoi;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3860.335,950.4435;Inherit;False;Property;_SmoothStep_Fill;SmoothStep_Fill;8;0;Create;True;0;0;0;False;0;False;0;-2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;91;-3558.646,1159.714;Inherit;False;Rectangle;-1;;10;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;64;-3095.45,324.7215;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;92;-3447.717,1477.552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-3552.864,842.1893;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;182;-1702.688,-486.1907;Inherit;True;Property;_MAT_VFX_LightningTrailSprite;MAT_VFX_LightningTrailSprite;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-1422.422,381.9384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-3364.168,967.0233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1366.56,-477.9058;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-2827.681,153.3938;Inherit;False;Fresnel_Pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-3291.845,1309.002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-3395.385,784.8286;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-1438.175,-49.6975;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2829.942,322.4179;Inherit;False;ElecticalCurrents;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;15;-3216.116,802.5305;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1.63;False;2;FLOAT;1.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1185.673,-483.6947;Inherit;False;LightningMain_X;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-583.4169,58.60313;Inherit;False;65;Fresnel_Pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-563.0917,-14.88873;Inherit;False;40;Voronoi;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-1241.534,376.1494;Inherit;False;LightningMain_Z;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;-1221.771,-56.59642;Inherit;False;LightningMain_Y;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2829.653,234.6024;Inherit;False;DisolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;192;-386.3271,-320.0043;Inherit;False;187;LightningMain_X;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-388.6986,6.300846;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-386.7294,-171.7121;Inherit;False;188;LightningMain_Z;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-386.5283,-245.8908;Inherit;False;189;LightningMain_Y;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-387.7776,-79.93699;Inherit;False;118;ElecticalCurrents;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;4.214576,-36.15101;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;165.4395,33.07707;Inherit;False;16;DisolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;32;-3028.804,72.45172;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;384.7669,-279.0712;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;175.4668,-229.671;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3320.827,161.3254;Inherit;False;Property;_EdgeFade;EdgeFade;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-3648.364,-478.0547;Inherit;False;33;SoftEdgeMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;35;-56.43795,-247.4057;Inherit;False;Property;_BaseColour_1;BaseColour_1;16;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1.135301,0.3507667,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;194;-67.49815,-561.624;Inherit;False;Property;_BaseColour_2;BaseColour_2;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,0.8313726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-3169.849,77.32284;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-3920.955,76.75866;Inherit;True;Property;_Texture0;Texture 0;9;0;Create;True;0;0;0;False;0;False;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-33.83315,-390.871;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;183.2669,-349.2711;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;398.2231,-39.9941;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;29;-3626.302,78.31976;Inherit;True;Property;_MAT_Masking_SquareMaskSprite;MAT_Masking_SquareMaskSprite;4;0;Create;True;0;0;0;False;0;False;-1;9a7be70759d48ff48a8ef359791bfa99;9a7be70759d48ff48a8ef359791bfa99;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-2829.337,72.13452;Inherit;False;SoftEdgeMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-3388.29,-735.6509;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;367.8746,-34.36191;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;623.6654,-77.4158;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_Energy;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637906834023764802;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;637906843009833841;  Use Shadow Threshold;0;0;Receive Shadows;0;637906843016997842;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
WireConnection;106;0;99;0
WireConnection;106;2;100;0
WireConnection;106;1;68;0
WireConnection;52;0;50;0
WireConnection;52;1;49;2
WireConnection;144;0;146;3
WireConnection;107;0;102;0
WireConnection;107;2;101;0
WireConnection;107;1;103;0
WireConnection;51;0;50;0
WireConnection;51;1;49;1
WireConnection;54;0;51;0
WireConnection;116;0;107;0
WireConnection;116;1;104;0
WireConnection;117;0;106;0
WireConnection;117;1;104;0
WireConnection;75;1;73;0
WireConnection;53;0;52;0
WireConnection;143;0;146;2
WireConnection;151;0;150;0
WireConnection;151;1;148;2
WireConnection;152;0;150;0
WireConnection;152;1;148;3
WireConnection;149;0;150;0
WireConnection;149;1;148;1
WireConnection;145;0;146;1
WireConnection;22;0;21;0
WireConnection;22;1;19;0
WireConnection;55;0;53;0
WireConnection;17;0;18;0
WireConnection;17;1;22;0
WireConnection;17;2;20;0
WireConnection;57;0;54;0
WireConnection;6;0;5;0
WireConnection;171;0;164;0
WireConnection;154;0;151;0
WireConnection;114;0;116;0
WireConnection;114;1;117;0
WireConnection;153;0;152;0
WireConnection;155;0;149;0
WireConnection;82;0;75;0
WireConnection;166;0;165;0
WireConnection;173;0;170;0
WireConnection;173;1;171;0
WireConnection;168;0;163;0
WireConnection;115;0;114;0
WireConnection;115;1;69;0
WireConnection;158;0;153;0
WireConnection;157;0;155;0
WireConnection;85;0;82;0
WireConnection;85;1;70;0
WireConnection;62;0;55;0
WireConnection;62;3;59;0
WireConnection;62;4;60;0
WireConnection;61;0;57;0
WireConnection;61;3;56;0
WireConnection;61;4;58;0
WireConnection;45;0;17;0
WireConnection;45;3;48;1
WireConnection;45;4;48;2
WireConnection;7;0;6;0
WireConnection;156;0;154;0
WireConnection;172;0;169;0
WireConnection;172;1;166;0
WireConnection;203;13;173;0
WireConnection;160;0;156;0
WireConnection;161;0;157;0
WireConnection;8;0;7;1
WireConnection;159;0;158;0
WireConnection;87;0;85;0
WireConnection;176;0;167;0
WireConnection;176;1;168;0
WireConnection;63;2;61;0
WireConnection;63;3;62;0
WireConnection;40;0;45;0
WireConnection;88;0;115;0
WireConnection;181;0;177;0
WireConnection;181;1;176;0
WireConnection;180;0;175;0
WireConnection;180;1;203;0
WireConnection;91;1;88;0
WireConnection;91;2;79;0
WireConnection;91;3;76;0
WireConnection;64;0;63;0
WireConnection;92;0;87;0
WireConnection;9;0;8;0
WireConnection;182;0;174;0
WireConnection;182;1;172;0
WireConnection;185;0;180;0
WireConnection;185;1;178;0
WireConnection;14;0;11;0
WireConnection;14;1;12;0
WireConnection;186;0;182;0
WireConnection;186;1;179;0
WireConnection;65;0;64;0
WireConnection;93;0;92;0
WireConnection;93;1;91;0
WireConnection;13;0;162;0
WireConnection;13;1;9;0
WireConnection;184;0;181;0
WireConnection;184;1;183;0
WireConnection;118;0;93;0
WireConnection;15;0;13;0
WireConnection;15;1;11;0
WireConnection;15;2;14;0
WireConnection;187;0;186;0
WireConnection;188;0;185;0
WireConnection;189;0;184;0
WireConnection;16;0;15;0
WireConnection;67;0;41;0
WireConnection;67;1;66;0
WireConnection;198;0;191;0
WireConnection;198;1;67;0
WireConnection;198;2;192;0
WireConnection;198;3;190;0
WireConnection;198;4;119;0
WireConnection;32;0;31;0
WireConnection;202;0;201;0
WireConnection;202;1;199;0
WireConnection;199;0;35;0
WireConnection;199;1;67;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;200;0;192;0
WireConnection;200;1;190;0
WireConnection;200;2;191;0
WireConnection;200;3;119;0
WireConnection;201;0;194;0
WireConnection;201;1;200;0
WireConnection;43;0;198;0
WireConnection;43;1;44;0
WireConnection;29;0;28;0
WireConnection;33;0;32;0
WireConnection;27;0;17;0
WireConnection;27;1;34;0
WireConnection;1;2;202;0
WireConnection;1;3;43;0
ASEEND*/
//CHKSM=2D5E55247DF694623EDA6CED3BB78D35BCDC0BB5