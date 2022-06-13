// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader_VFX_Laserbeam"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Texture0("Texture 0", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		_Texture4("Texture 4", 2D) = "white" {}
		_Texture5("Texture 5", 2D) = "white" {}
		_Texture6("Texture 6", 2D) = "white" {}
		_Texture7("Texture 7", 2D) = "white" {}
		_Flashing_MainXYZ("Flashing_Main (XYZ)", Vector) = (1,1,1,0)
		_Panning_MainXYZ("Panning_Main (XYZ)", Vector) = (1,1,1,0)
		[HDR]_BaseColour("BaseColour", Color) = (30.87059,11.92157,1.380392,0)
		[HDR]_SecondaryColour("SecondaryColour", Color) = (30.87059,11.92157,1.380392,0)
		[HDR]_CentreBeamColour("CentreBeamColour", Color) = (30.87059,11.92157,1.380392,0)
		_Flashing_OuterXYZW("Flashing_Outer (XYZW)", Vector) = (10,10,10,10)
		_Panning_OuterXYZW("Panning_Outer (XYZW)", Vector) = (1,1,1,1)
		[ASEEnd]_CentreBeam_Flash("CentreBeam_Flash", Float) = 0
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
			
			Blend One One, One OneMinusSrcAlpha
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
			float4 _SecondaryColour;
			float4 _Panning_OuterXYZW;
			float4 _Flashing_OuterXYZW;
			float4 _Texture7_ST;
			float4 _CentreBeamColour;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float _CentreBeam_Flash;
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
			sampler2D _Texture3;
			sampler2D _Texture4;
			sampler2D _Texture2;
			sampler2D _Texture5;
			sampler2D _Texture6;
			sampler2D _Texture7;


						
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
				float4 Laser_Colour19 = ( IN.ase_color * _BaseColour );
				float PanningOnX58 = _Panning_MainXYZ.x;
				float mulTime101 = _TimeParameters.x * PanningOnX58;
				float2 texCoord102 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner103 = ( mulTime101 * float2( 1.5,0 ) + texCoord102);
				float FlashingOnX72 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X109 = ( tex2D( _Texture0, panner103 ) * FlashingOnX72 );
				float PanningOnY60 = _Panning_MainXYZ.y;
				float mulTime115 = _TimeParameters.x * PanningOnY60;
				float2 texCoord116 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner117 = ( mulTime115 * float2( 1.5,0 ) + texCoord116);
				float FlashingOnY73 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y112 = ( tex2D( _Texture1, panner117 ) * FlashingOnY73 );
				float4 LaserMain_Diffuse55 = ( LightningMain_X109 + LightningMain_Y112 );
				float4 LaserOuter_Colour96 = ( IN.ase_color * _SecondaryColour );
				float Panning2OnX80 = _Panning_OuterXYZW.x;
				float mulTime130 = _TimeParameters.x * Panning2OnX80;
				float2 texCoord131 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner132 = ( mulTime130 * float2( 1.5,0 ) + texCoord131);
				float Flashing2OnX77 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.x ) ) );
				float4 LightningOuter_X136 = ( tex2D( _Texture3, panner132 ) * Flashing2OnX77 );
				float Panning2OnY82 = _Panning_OuterXYZW.y;
				float mulTime139 = _TimeParameters.x * Panning2OnY82;
				float2 texCoord140 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner141 = ( mulTime139 * float2( 1.5,0 ) + texCoord140);
				float Flashing2OnY94 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.y ) ) );
				float4 LightningOuter_Y145 = ( tex2D( _Texture4, panner141 ) * Flashing2OnY94 );
				float PanningOnZ57 = _Panning_MainXYZ.z;
				float mulTime124 = _TimeParameters.x * PanningOnZ57;
				float2 texCoord125 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner126 = ( mulTime124 * float2( 1.5,0 ) + texCoord125);
				float FlashingOnZ71 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z121 = ( tex2D( _Texture2, panner126 ) * FlashingOnZ71 );
				float4 LaserOuter_Diffuse167 = ( LightningOuter_X136 + LightningOuter_Y145 + LightningMain_Z121 );
				float Panning2OnZ79 = _Panning_OuterXYZW.z;
				float mulTime148 = _TimeParameters.x * Panning2OnZ79;
				float2 texCoord149 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner150 = ( mulTime148 * float2( 1.5,0 ) + texCoord149);
				float Flashing2OnZ93 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.z ) ) );
				float4 LightningOuter_Z154 = ( tex2D( _Texture5, panner150 ) * Flashing2OnZ93 );
				float Panning2OnW81 = _Panning_OuterXYZW.w;
				float mulTime157 = _TimeParameters.x * Panning2OnW81;
				float2 texCoord158 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner159 = ( mulTime157 * float2( 1.5,0 ) + texCoord158);
				float Flashing2OnW95 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.w ) ) );
				float4 LightningOuter_W163 = ( tex2D( _Texture6, panner159 ) * Flashing2OnW95 );
				float4 LaserSparks_Diffuse198 = ( LightningOuter_Z154 + LightningOuter_W163 );
				float2 uv_Texture7 = IN.ase_texcoord3.xy * _Texture7_ST.xy + _Texture7_ST.zw;
				float CentreBeamFlashing208 = (0.3 + (abs( sin( ( _TimeParameters.x * _CentreBeam_Flash ) ) ) - 0.0) * (1.2 - 0.3) / (1.0 - 0.0));
				float4 CentreBeam212 = ( tex2D( _Texture7, uv_Texture7 ) * CentreBeamFlashing208 );
				float4 CentreBeam_Colour219 = ( IN.ase_color * _CentreBeamColour );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( Laser_Colour19 * LaserMain_Diffuse55 ) + ( LaserOuter_Colour96 * LaserOuter_Diffuse167 ) + ( Laser_Colour19 * LaserSparks_Diffuse198 ) + ( CentreBeam212 * CentreBeam_Colour219 ) ).rgb;
				float Alpha = ( LaserMain_Diffuse55 + LaserOuter_Diffuse167 + LaserSparks_Diffuse198 + CentreBeam212 ).r;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColour;
			float4 _SecondaryColour;
			float4 _Panning_OuterXYZW;
			float4 _Flashing_OuterXYZW;
			float4 _Texture7_ST;
			float4 _CentreBeamColour;
			float3 _Panning_MainXYZ;
			float3 _Flashing_MainXYZ;
			float _CentreBeam_Flash;
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
			sampler2D _Texture3;
			sampler2D _Texture4;
			sampler2D _Texture2;
			sampler2D _Texture5;
			sampler2D _Texture6;
			sampler2D _Texture7;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
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

				float PanningOnX58 = _Panning_MainXYZ.x;
				float mulTime101 = _TimeParameters.x * PanningOnX58;
				float2 texCoord102 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner103 = ( mulTime101 * float2( 1.5,0 ) + texCoord102);
				float FlashingOnX72 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.x ) ) );
				float4 LightningMain_X109 = ( tex2D( _Texture0, panner103 ) * FlashingOnX72 );
				float PanningOnY60 = _Panning_MainXYZ.y;
				float mulTime115 = _TimeParameters.x * PanningOnY60;
				float2 texCoord116 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner117 = ( mulTime115 * float2( 1.5,0 ) + texCoord116);
				float FlashingOnY73 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.y ) ) );
				float4 LightningMain_Y112 = ( tex2D( _Texture1, panner117 ) * FlashingOnY73 );
				float4 LaserMain_Diffuse55 = ( LightningMain_X109 + LightningMain_Y112 );
				float Panning2OnX80 = _Panning_OuterXYZW.x;
				float mulTime130 = _TimeParameters.x * Panning2OnX80;
				float2 texCoord131 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner132 = ( mulTime130 * float2( 1.5,0 ) + texCoord131);
				float Flashing2OnX77 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.x ) ) );
				float4 LightningOuter_X136 = ( tex2D( _Texture3, panner132 ) * Flashing2OnX77 );
				float Panning2OnY82 = _Panning_OuterXYZW.y;
				float mulTime139 = _TimeParameters.x * Panning2OnY82;
				float2 texCoord140 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner141 = ( mulTime139 * float2( 1.5,0 ) + texCoord140);
				float Flashing2OnY94 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.y ) ) );
				float4 LightningOuter_Y145 = ( tex2D( _Texture4, panner141 ) * Flashing2OnY94 );
				float PanningOnZ57 = _Panning_MainXYZ.z;
				float mulTime124 = _TimeParameters.x * PanningOnZ57;
				float2 texCoord125 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner126 = ( mulTime124 * float2( 1.5,0 ) + texCoord125);
				float FlashingOnZ71 = abs( sin( ( _TimeParameters.x * _Flashing_MainXYZ.z ) ) );
				float4 LightningMain_Z121 = ( tex2D( _Texture2, panner126 ) * FlashingOnZ71 );
				float4 LaserOuter_Diffuse167 = ( LightningOuter_X136 + LightningOuter_Y145 + LightningMain_Z121 );
				float Panning2OnZ79 = _Panning_OuterXYZW.z;
				float mulTime148 = _TimeParameters.x * Panning2OnZ79;
				float2 texCoord149 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner150 = ( mulTime148 * float2( 1.5,0 ) + texCoord149);
				float Flashing2OnZ93 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.z ) ) );
				float4 LightningOuter_Z154 = ( tex2D( _Texture5, panner150 ) * Flashing2OnZ93 );
				float Panning2OnW81 = _Panning_OuterXYZW.w;
				float mulTime157 = _TimeParameters.x * Panning2OnW81;
				float2 texCoord158 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner159 = ( mulTime157 * float2( 1.5,0 ) + texCoord158);
				float Flashing2OnW95 = abs( sin( ( _TimeParameters.x * _Flashing_OuterXYZW.w ) ) );
				float4 LightningOuter_W163 = ( tex2D( _Texture6, panner159 ) * Flashing2OnW95 );
				float4 LaserSparks_Diffuse198 = ( LightningOuter_Z154 + LightningOuter_W163 );
				float2 uv_Texture7 = IN.ase_texcoord2.xy * _Texture7_ST.xy + _Texture7_ST.zw;
				float CentreBeamFlashing208 = (0.3 + (abs( sin( ( _TimeParameters.x * _CentreBeam_Flash ) ) ) - 0.0) * (1.2 - 0.3) / (1.0 - 0.0));
				float4 CentreBeam212 = ( tex2D( _Texture7, uv_Texture7 ) * CentreBeamFlashing208 );
				
				float Alpha = ( LaserMain_Diffuse55 + LaserOuter_Diffuse167 + LaserSparks_Diffuse198 + CentreBeam212 ).r;
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
112;73;1682;871;6264.144;1579.05;4.029937;True;False
Node;AmplifyShaderEditor.Vector3Node;75;-3862.181,-85.1963;Inherit;False;Property;_Panning_MainXYZ;Panning_Main (XYZ);9;0;Create;True;0;0;0;False;0;False;1,1,1;-3,-6,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;78;-3834.923,103.5805;Inherit;False;Property;_Panning_OuterXYZW;Panning_Outer (XYZW);14;0;Create;True;0;0;0;False;0;False;1,1,1,1;-0.1,-0.2,0.5,-2.3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;83;-4289.955,506.6331;Inherit;False;Property;_Flashing_OuterXYZW;Flashing_Outer (XYZW);13;0;Create;True;0;0;0;False;0;False;10,10,10,10;4,10,20,15;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;84;-4209.876,415.4031;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;76;-4220.819,930.0839;Inherit;False;Property;_Flashing_MainXYZ;Flashing_Main (XYZ);8;0;Create;True;0;0;0;False;0;False;1,1,1;5,10,3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;62;-4206.209,817.1919;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-3993.608,589.3491;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-3561.465,-162.587;Inherit;False;PanningOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-4002.214,385.8222;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-3997.608,494.349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-3998.547,787.611;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3993.941,896.1383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-3989.941,991.1385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-3557.539,-13.83907;Inherit;False;PanningOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-3557.704,-88.88005;Inherit;False;PanningOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-3553.79,144.5006;Inherit;False;Panning2OnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-3553.625,221.5416;Inherit;False;Panning2OnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-3991.608,688.3492;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-3557.551,65.79351;Inherit;False;Panning2OnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-3551.06,298.2372;Inherit;False;Panning2OnW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-3137.715,1372.227;Inherit;False;79;Panning2OnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;91;-3857.916,685.5472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;90;-3863.916,491.546;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-4238.381,1233.554;Inherit;False;Property;_CentreBeam_Flash;CentreBeam_Flash;15;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-3108.743,-826.415;Inherit;False;58;PanningOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-3180.358,-398.2065;Inherit;False;60;PanningOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;67;-3870.854,790.808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;68;-3860.249,893.3353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;70;-3856.249,988.3356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-3147.948,553.1949;Inherit;False;80;Panning2OnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-3144.625,1769.595;Inherit;False;81;Panning2OnW;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;89;-3874.521,389.0192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-3164.604,33.42932;Inherit;False;57;PanningOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-3141.172,961.0366;Inherit;False;82;Panning2OnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;204;-4214.492,1152.678;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;92;-3859.916,586.546;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;124;-2963.784,36.11829;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;148;-2936.895,1374.916;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;190;-3705.25,495.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;192;-3702.25,687.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;139;-2940.352,963.7256;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-3006.024,-86.01986;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-2950.163,-945.8636;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;115;-2979.538,-395.5176;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;-3021.778,-517.6558;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;101;-2907.923,-823.7261;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-4024.611,1186.436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;130;-2947.128,555.8839;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;191;-3708.25,586.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;158;-2986.045,1650.146;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;195;-3705.25,991.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;193;-3709.25,791.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;194;-3708.25,890.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;157;-2943.805,1772.284;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-2979.135,1252.778;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;140;-2982.592,841.5874;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;131;-2989.368,433.7457;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;189;-3722.25,393.5329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;106;-2848.849,-1139.031;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;41bc13a0b2b7ee84196f8f26ec56af2d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;126;-2781.385,-84.67269;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;103;-2725.522,-944.5167;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-3557.266,885.0525;Inherit;False;FlashingOnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-3556.266,985.0529;Inherit;False;FlashingOnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;-2904.71,-279.1868;Inherit;True;Property;_Texture2;Texture 2;2;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;39d0a903fd38fa045901d864a3f0ca8f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-3555.58,784.8801;Inherit;False;FlashingOnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;117;-2797.138,-516.3086;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-3559.933,583.2633;Inherit;False;Flashing2OnZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;132;-2764.729,435.0929;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;159;-2761.406,1651.493;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;142;-2893.56,654.3016;Inherit;True;Property;_Texture4;Texture 4;4;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;bf00e325700b0714d8090cb909018828;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-3560.933,483.2633;Inherit;False;Flashing2OnY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;141;-2757.953,842.9346;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;133;-2960.336,241.4599;Inherit;True;Property;_Texture3;Texture 3;3;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;bcf9928001deb8c4485e99ef210908a9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-3560.247,387.0916;Inherit;False;Flashing2OnX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;151;-2904.208,1056.676;Inherit;True;Property;_Texture5;Texture 5;5;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;a876fbcd2d6ea9f4d88d89bae37d0489;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;160;-2938.395,1459.833;Inherit;True;Property;_Texture6;Texture 6;6;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;0076bf24fba01f84bb03e9df4d7fe5b1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-3567.933,685.2635;Inherit;False;Flashing2OnW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;150;-2754.496,1254.125;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;206;-3898.021,1188.545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;118;-2920.464,-710.8228;Inherit;True;Property;_Texture1;Texture 1;1;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;de220d106c1ee234787d813c220f9e0d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;128;-2584.387,315.5817;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2494.151,-6.21172;Inherit;False;71;FlashingOnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-2474.173,1729.954;Inherit;False;95;Flashing2OnW;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;-2577.611,723.4234;Inherit;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;135;-2477.495,513.5538;Inherit;False;77;Flashing2OnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;155;-2581.064,1531.982;Inherit;True;Property;_TextureSample4;Texture Sample 4;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;153;-2467.262,1332.586;Inherit;False;93;Flashing2OnZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;146;-2574.154,1134.614;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;215;-3776.365,1193.847;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2509.905,-437.8474;Inherit;False;73;FlashingOnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;107;-2545.182,-1064.028;Inherit;True;Property;_MAT_VFX_LightningTrailSprite;MAT_VFX_LightningTrailSprite;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;110;-2616.797,-635.8197;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;119;-2601.043,-204.184;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2470.719,921.3955;Inherit;False;94;Flashing2OnY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-2438.289,-866.0557;Inherit;False;72;FlashingOnX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-2280.669,-627.5347;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-2209.054,-1055.743;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2238.027,1142.899;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-2248.26,323.8669;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-2246.413,731.7086;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-2244.938,1540.267;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-2264.916,-195.8988;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;223;-3657.981,1183.078;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.3;False;4;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-2028.167,-1061.532;Inherit;False;LightningMain_X;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-2099.782,-633.3237;Inherit;False;LightningMain_Y;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-2067.372,318.0778;Inherit;False;LightningOuter_X;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-2106.006,728.9352;Inherit;True;LightningOuter_Y;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-3483.424,1173.968;Inherit;True;CentreBeamFlashing;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;209;-3062.76,1898.002;Inherit;True;Property;_Texture7;Texture 7;7;0;Create;True;0;0;0;False;0;False;5512be1e0e083f24eb6f50956c6066f6;8b9790e1445f49640a8caeb52392efd2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-2064.049,1534.478;Inherit;False;LightningOuter_W;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-2057.139,1137.11;Inherit;False;LightningOuter_Z;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-2084.028,-201.6879;Inherit;False;LightningMain_Z;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1617.921,-1005.014;Inherit;False;109;LightningMain_X;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-1607.824,-525.3814;Inherit;False;154;LightningOuter_Z;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;210;-2705.429,1970.151;Inherit;True;Property;_TextureSample6;Texture Sample 6;0;0;Create;True;0;0;0;False;0;False;-1;5512be1e0e083f24eb6f50956c6066f6;5512be1e0e083f24eb6f50956c6066f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;175;-1611.081,-445.5849;Inherit;False;163;LightningOuter_W;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;-1620.873,-622.0284;Inherit;False;121;LightningMain_Z;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-1621.127,-913.4159;Inherit;False;112;LightningMain_Y;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-1628.338,-706.664;Inherit;False;145;LightningOuter_Y;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-1629.081,-786.6895;Inherit;False;136;LightningOuter_X;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-2668.608,2163.325;Inherit;False;208;CentreBeamFlashing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-2369.303,1978.436;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;199;-1392.676,-507.6422;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;-1393.139,-725.6076;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-1298.663,-998.9258;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-1268.73,-516.117;Inherit;True;LaserSparks_Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-1240.331,-719.1356;Inherit;False;LaserOuter_Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1035.931,-1011.999;Inherit;False;LaserMain_Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-2199.803,1950.353;Inherit;True;CentreBeam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-828.4532,-495.9547;Inherit;False;55;LaserMain_Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-819.7589,-338.7737;Inherit;False;198;LaserSparks_Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-820.531,-413.8812;Inherit;False;167;LaserOuter_Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-805.8657,-240.0431;Inherit;False;212;CentreBeam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;16;-4084.788,-429.3636;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;216;-4016.48,-1102.232;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;99;-4031.815,-766.7151;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;188;277.4684,-603.8705;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-292.1868,-361.727;Inherit;False;96;LaserOuter_Colour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-3551.653,-418.3894;Inherit;False;CentreBeam_Colour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;217;-4057,-936.1909;Inherit;False;Property;_CentreBeamColour;CentreBeamColour;12;1;[HDR];Create;True;0;0;0;False;0;False;30.87059,11.92157,1.380392,0;3.688605,1.178036,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;-129.5368,-485.1564;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-449.0376,-502.202;Inherit;False;219;CentreBeam_Colour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-117.1769,-595.8308;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-117.5662,-192.9888;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-3831.347,-551.194;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-410.0163,-740.4781;Inherit;False;19;Laser_Colour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;98;-4093.014,-602.3779;Inherit;False;Property;_SecondaryColour;SecondaryColour;11;1;[HDR];Create;True;0;0;0;False;0;False;30.87059,11.92157,1.380392,0;5.278032,0.1066673,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-3834.229,-326.3917;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-201.909,-736.6698;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-3560.773,-250.9653;Inherit;False;Laser_Colour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;15;-4090.987,-263.0263;Inherit;False;Property;_BaseColour;BaseColour;10;1;[HDR];Create;True;0;0;0;False;0;False;30.87059,11.92157,1.380392,0;30.87059,11.92157,1.380392,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-3810.583,-771.7163;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-3559.527,-335.0353;Inherit;False;LaserOuter_Colour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-62.7344,-290.6873;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;14;-195.3324,-202.8452;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;13;-195.3324,-202.8452;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;-195.3324,-202.8452;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;12;-195.3324,-202.8452;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;690.3246,-490.9075;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Shader_VFX_Laserbeam;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;1;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637897413900316199;  Blend;2;637897428582022256;Two Sided;1;0;Cast Shadows;0;637897429434782055;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;False;True;False;False;;False;0
WireConnection;88;0;84;0
WireConnection;88;1;83;3
WireConnection;58;0;75;1
WireConnection;85;0;84;0
WireConnection;85;1;83;1
WireConnection;87;0;84;0
WireConnection;87;1;83;2
WireConnection;63;0;62;0
WireConnection;63;1;76;1
WireConnection;65;0;62;0
WireConnection;65;1;76;2
WireConnection;66;0;62;0
WireConnection;66;1;76;3
WireConnection;57;0;75;3
WireConnection;60;0;75;2
WireConnection;82;0;78;2
WireConnection;79;0;78;3
WireConnection;86;0;84;0
WireConnection;86;1;83;4
WireConnection;80;0;78;1
WireConnection;81;0;78;4
WireConnection;91;0;86;0
WireConnection;90;0;87;0
WireConnection;67;0;63;0
WireConnection;68;0;65;0
WireConnection;70;0;66;0
WireConnection;89;0;85;0
WireConnection;92;0;88;0
WireConnection;124;0;123;0
WireConnection;148;0;152;0
WireConnection;190;0;90;0
WireConnection;192;0;91;0
WireConnection;139;0;143;0
WireConnection;115;0;114;0
WireConnection;101;0;100;0
WireConnection;205;0;204;0
WireConnection;205;1;202;0
WireConnection;130;0;134;0
WireConnection;191;0;92;0
WireConnection;195;0;70;0
WireConnection;193;0;67;0
WireConnection;194;0;68;0
WireConnection;157;0;161;0
WireConnection;189;0;89;0
WireConnection;126;0;125;0
WireConnection;126;1;124;0
WireConnection;103;0;102;0
WireConnection;103;1;101;0
WireConnection;73;0;194;0
WireConnection;71;0;195;0
WireConnection;72;0;193;0
WireConnection;117;0;116;0
WireConnection;117;1;115;0
WireConnection;93;0;191;0
WireConnection;132;0;131;0
WireConnection;132;1;130;0
WireConnection;159;0;158;0
WireConnection;159;1;157;0
WireConnection;94;0;190;0
WireConnection;141;0;140;0
WireConnection;141;1;139;0
WireConnection;77;0;189;0
WireConnection;95;0;192;0
WireConnection;150;0;149;0
WireConnection;150;1;148;0
WireConnection;206;0;205;0
WireConnection;128;0;133;0
WireConnection;128;1;132;0
WireConnection;137;0;142;0
WireConnection;137;1;141;0
WireConnection;155;0;160;0
WireConnection;155;1;159;0
WireConnection;146;0;151;0
WireConnection;146;1;150;0
WireConnection;215;0;206;0
WireConnection;107;0;106;0
WireConnection;107;1;103;0
WireConnection;110;0;118;0
WireConnection;110;1;117;0
WireConnection;119;0;127;0
WireConnection;119;1;126;0
WireConnection;111;0;110;0
WireConnection;111;1;113;0
WireConnection;108;0;107;0
WireConnection;108;1;104;0
WireConnection;147;0;146;0
WireConnection;147;1;153;0
WireConnection;129;0;128;0
WireConnection;129;1;135;0
WireConnection;138;0;137;0
WireConnection;138;1;144;0
WireConnection;156;0;155;0
WireConnection;156;1;162;0
WireConnection;120;0;119;0
WireConnection;120;1;122;0
WireConnection;223;0;215;0
WireConnection;109;0;108;0
WireConnection;112;0;111;0
WireConnection;136;0;129;0
WireConnection;145;0;138;0
WireConnection;208;0;223;0
WireConnection;163;0;156;0
WireConnection;154;0;147;0
WireConnection;121;0;120;0
WireConnection;210;0;209;0
WireConnection;211;0;210;0
WireConnection;211;1;214;0
WireConnection;199;0;174;0
WireConnection;199;1;175;0
WireConnection;182;0;172;0
WireConnection;182;1;173;0
WireConnection;182;2;166;0
WireConnection;181;0;164;0
WireConnection;181;1;165;0
WireConnection;198;0;199;0
WireConnection;167;0;182;0
WireConnection;55;0;181;0
WireConnection;212;0;211;0
WireConnection;188;0;36;0
WireConnection;188;1;187;0
WireConnection;188;2;201;0
WireConnection;188;3;222;0
WireConnection;219;0;218;0
WireConnection;201;0;18;0
WireConnection;201;1;200;0
WireConnection;222;0;220;0
WireConnection;222;1;221;0
WireConnection;184;0;54;0
WireConnection;184;1;183;0
WireConnection;184;2;200;0
WireConnection;184;3;220;0
WireConnection;97;0;99;0
WireConnection;97;1;98;0
WireConnection;17;0;16;0
WireConnection;17;1;15;0
WireConnection;36;0;18;0
WireConnection;36;1;54;0
WireConnection;19;0;17;0
WireConnection;218;0;216;0
WireConnection;218;1;217;0
WireConnection;96;0;97;0
WireConnection;187;0;186;0
WireConnection;187;1;183;0
WireConnection;11;2;188;0
WireConnection;11;3;184;0
ASEEND*/
//CHKSM=05243504080D09D8AFE5DEEDBAD298F7C9287E4C