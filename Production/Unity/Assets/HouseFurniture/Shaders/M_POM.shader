// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_POM"
{
	Properties
	{
		Material_Texture2D_1("Albedo", 2D) = "white" {}
		Material_Texture2D_0("Normal", 2D) = "bump" {}
		Material_Texture2D_2("Roughness", 2D) = "white" {}
		_Brightness("Brightness", Range( 0 , 5)) = 1
		Material_Texture2D_4("Mask", 2D) = "white" {}
		_Roughness("Roughness", Range( 0 , 5)) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Invert("Invert", Float) = 0
		[Toggle(_COLORMASK_ON)] _ColorMask("ColorMask", Float) = 0
		_UV("UV", Range( 0.1 , 10)) = 1
		[Toggle(_MASKINVERT_ON)] _MaskInvert("MaskInvert", Float) = 0
		_Color("Color", Color) = (0,0,0,0)
		_Desaturation("Desaturation", Range( 0 , 1)) = 0
		_Height("Height", 2D) = "white" {}
		_Scale("Scale", Range( 0 , 0.1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature_local _COLORMASK_ON
		#pragma shader_feature_local _MASKINVERT_ON
		#pragma surface surf Standard keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldPos;
		};

		uniform sampler2D Material_Texture2D_0;
		uniform float _UV;
		uniform sampler2D _Height;
		uniform float _Scale;
		uniform float4 _Height_ST;
		uniform float _Invert;
		uniform sampler2D Material_Texture2D_1;
		uniform float4 _Color;
		uniform sampler2D Material_Texture2D_4;
		uniform float4 Material_Texture2D_4_ST;
		uniform float _Brightness;
		uniform float _Desaturation;
		uniform sampler2D Material_Texture2D_2;
		uniform float _Roughness;
		uniform float _Cutoff = 0.5;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 2;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_UV).xx;
			float2 uv_TexCoord1 = i.uv_texcoord * temp_cast_0;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 OffsetPOM31 = POM( _Height, uv_TexCoord1, ddx(uv_TexCoord1), ddy(uv_TexCoord1), ase_worldNormal, ase_worldViewDir, i.viewDir, 8, 8, _Scale, 0, _Height_ST.xy, float2(0,0), 0 );
			float2 myVarName35 = OffsetPOM31;
			float3 break14 = UnpackNormal( tex2D( Material_Texture2D_0, myVarName35 ) );
			float4 appendResult27 = (float4(break14.x , ( break14.y * _Invert ) , break14.z , 0.0));
			o.Normal = appendResult27.xyz;
			float4 tex2DNode6 = tex2D( Material_Texture2D_1, myVarName35 );
			float2 uvMaterial_Texture2D_4 = i.uv_texcoord * Material_Texture2D_4_ST.xy + Material_Texture2D_4_ST.zw;
			float4 tex2DNode4 = tex2D( Material_Texture2D_4, uvMaterial_Texture2D_4 );
			#ifdef _MASKINVERT_ON
				float staticSwitch8 = ( 1.0 - tex2DNode4.r );
			#else
				float staticSwitch8 = tex2DNode4.r;
			#endif
			float4 lerpResult10 = lerp( tex2DNode6 , ( tex2DNode6 * _Color ) , staticSwitch8);
			#ifdef _COLORMASK_ON
				float4 staticSwitch13 = lerpResult10;
			#else
				float4 staticSwitch13 = tex2DNode6;
			#endif
			float3 desaturateInitialColor26 = ( staticSwitch13 * _Brightness ).rgb;
			float desaturateDot26 = dot( desaturateInitialColor26, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar26 = lerp( desaturateInitialColor26, desaturateDot26.xxx, _Desaturation );
			o.Albedo = desaturateVar26;
			o.Smoothness = ( ( 1.0 - tex2D( Material_Texture2D_2, myVarName35 ).r ) * _Roughness );
			o.Alpha = tex2DNode6.a;
			clip( tex2DNode6.a - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
2634;245;1820;777;1728.588;722.7668;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;2;-5433.965,-14.12117;Inherit;False;Property;_UV;UV;9;0;Create;True;0;0;0;False;0;False;1;1;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;32;-4531.334,298.1872;Inherit;True;Property;_Height;Height;13;0;Create;True;0;0;0;False;0;False;abc00000000006137192369973331666;abc00000000006137192369973331666;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;34;-4601.029,538.9171;Inherit;False;Property;_Scale;Scale;14;0;Create;True;0;0;0;False;0;False;0;0.0062;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;33;-4566.748,673.7928;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-5205.856,-268.4927;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;31;-3870.328,344.7014;Inherit;False;0;8;False;-1;16;False;-1;2;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-2726.074,-124.2305;Inherit;True;Property;Material_Texture2D_4;Mask;4;0;Create;False;0;0;0;False;0;False;-1;abc00000000013474387870728954763;abc00000000013474387870728954763;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-3498.277,437.8243;Inherit;False;myVarName;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;7;-2319.438,145.0617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-2223.567,-972.9327;Inherit;True;Property;Material_Texture2D_1;Albedo;0;0;Create;False;0;0;0;False;0;False;-1;abc00000000013474387870728954763;abc00000000011915554025324327820;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-1965.132,-506.8734;Inherit;False;Property;_Color;Color;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8113207,0.8113207,0.8113207,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1654.733,-447.673;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;8;-2245.312,-55.31046;Inherit;False;Property;_MaskInvert;MaskInvert;10;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;10;-1444.404,-424.8758;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;11;-1388.508,79.88244;Inherit;True;Property;Material_Texture2D_0;Normal;1;0;Create;False;0;0;0;False;0;False;-1;abc00000000005546889098118452484;abc00000000003362371242100579722;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1196.171,-315.2015;Inherit;False;Property;_Brightness;Brightness;3;0;Create;True;0;0;0;False;0;False;1;0.7;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;13;-1227.127,-452.6736;Inherit;False;Property;_ColorMask;ColorMask;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-1788.976,525.0242;Inherit;True;Property;Material_Texture2D_2;Roughness;2;0;Create;False;0;0;0;False;0;False;-1;abc00000000012000771315061351522;abc00000000011915554025324327820;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1094.146,-55.3508;Inherit;False;Property;_Invert;Invert;7;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;14;-1046.509,146.3037;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;23;-905.6987,-201.8447;Inherit;False;Property;_Desaturation;Desaturation;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1449.947,735.0151;Inherit;False;Property;_Roughness;Roughness;5;0;Create;True;0;0;0;False;0;False;1;0.7;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-863.4164,-50.9877;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;16;-1471.637,542.5742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-897.507,-352.7176;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;26;-562.0387,-255.4866;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1130.179,408.6589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-4970.086,-92.65728;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;37;-4318.055,880.5996;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;0;False;0;False;-1;abc00000000006137192369973331666;abc00000000006137192369973331666;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxMappingNode;36;-3775.348,650.9696;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-699.4093,126.8037;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1121.047,524.4152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-132.3286,-258.5497;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;M_POM;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;2;0
WireConnection;31;0;1;0
WireConnection;31;1;32;0
WireConnection;31;2;34;0
WireConnection;31;3;33;0
WireConnection;35;0;31;0
WireConnection;7;0;4;1
WireConnection;6;1;35;0
WireConnection;9;0;6;0
WireConnection;9;1;5;0
WireConnection;8;1;4;1
WireConnection;8;0;7;0
WireConnection;10;0;6;0
WireConnection;10;1;9;0
WireConnection;10;2;8;0
WireConnection;11;1;35;0
WireConnection;13;1;6;0
WireConnection;13;0;10;0
WireConnection;12;1;35;0
WireConnection;14;0;11;0
WireConnection;19;0;14;1
WireConnection;19;1;17;0
WireConnection;16;0;12;1
WireConnection;22;0;13;0
WireConnection;22;1;15;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;21;0;6;4
WireConnection;21;1;18;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;36;0;1;0
WireConnection;36;1;37;1
WireConnection;36;2;34;0
WireConnection;36;3;33;0
WireConnection;27;0;14;0
WireConnection;27;1;19;0
WireConnection;27;2;14;2
WireConnection;20;0;16;0
WireConnection;20;1;18;0
WireConnection;0;0;26;0
WireConnection;0;1;27;0
WireConnection;0;4;20;0
WireConnection;0;9;6;4
WireConnection;0;10;6;4
ASEEND*/
//CHKSM=31F2BC0EE56A94F54978D9C12E19CB14DD829765