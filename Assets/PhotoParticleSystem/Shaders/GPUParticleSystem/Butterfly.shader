Shader "mattatz/Butterfly" {

	Properties  {
		_TextureArray ("Texture", 2DArray) = "" {}

		_Position ("Position", 2D) = "gray" {}
		_Velocity ("Velocity", 2D) = "gray" {}
		_Rotation ("Rotation", 2D) = "gray" {}

		_Depth ("Depth", Float) = 1.0
		_Size ("Size", Range(0, 3)) = 0.5
		_BendScale ("Bend Scale", Range(0.0, 1.57)) = 1.2
		_BendSpeed ("Bend Speed", Float) = 2.0
	}

	SubShader {

		CGINCLUDE

		#pragma target 4.0
		#include "UnityCG.cginc"
		#include "Assets/Common/Shaders/Math.cginc"
		#include "Assets/Common/Shaders/Random.cginc"

		half _Size;
		half _Depth;
		half _BendScale, _BendSpeed;

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2g {
			float4 pos : SV_POSITION;
			float4 col : COLOR;
			float4 rot : NORMAL;
			float2 uv : TEXCOORD0;
			float depth : TEXCOORD1;
			float angle : TEXCOORD2;
			float speed : TEXCOORD3;
			float bend : TEXCOORD4;
		};

		struct g2f {
			float4 pos : SV_POSITION;
			float4 col : COLOR;
			float3 uv : TEXCOORD0;
		};

		sampler2D _Position, _Velocity, _Rotation, _Color;
		float4 _Position_TexelSize;

		UNITY_DECLARE_TEX2DARRAY(_TextureArray);

		v2g vert (appdata IN) {
			v2g OUT;

			IN.uv += _Position_TexelSize.xy * 0.5;

			float4 position = tex2Dlod(_Position, float4(IN.uv, 0, 0));
			IN.vertex.xyz = position.xyz;

			OUT.pos = mul(unity_ObjectToWorld, IN.vertex);
			OUT.rot = tex2Dlod(_Rotation, float4(IN.uv, 0, 0));
			OUT.col = tex2Dlod(_Color, float4(IN.uv, 0, 0));

			OUT.uv = IN.uv;

			float4 texel = _Position_TexelSize;
			// OUT.depth = floor(fmod((IN.uv.x * texel.z) + nrand(IN.uv.y) * texel.w, _Depth));
			OUT.depth = floor(fmod((nrand(IN.uv.x) + nrand((nrand(IN.uv.x) + IN.uv.y) * texel.w + 1.0)) * texel.z, _Depth));

			float4 vel = tex2Dlod(_Velocity, float4(IN.uv, 0, 0));
			OUT.angle = position.a * 10.0 + IN.uv.x;
			OUT.speed = max(0.25, position.a);
			OUT.bend = vel.a;

			return OUT;
		}

		ENDCG

		Pass {
			Tags { "RenderType"="Opaque" }
			LOD 200
			Cull Off ZWrite On
		
			CGPROGRAM

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			[maxvertexcount(8)]
			void geom (point v2g IN[1], inout TriangleStream<g2f> triStream) {
				float halfS = 0.5f * _Size;
				float3 right = rotate_vector(float3(1, 0, 0), IN[0].rot) * halfS;
				float3 up = rotate_vector(float3(0, 1, 0), IN[0].rot) * halfS;
						
				float4 v[6];
				v[0] = float4(IN[0].pos + halfS * right - halfS * up, 1.0f);
				v[1] = float4(IN[0].pos + halfS * right + halfS * up, 1.0f);
				v[2] = float4(IN[0].pos                 - halfS * up, 1.0f);
				v[3] = float4(IN[0].pos                 + halfS * up, 1.0f);
				v[4] = float4(IN[0].pos - halfS * right - halfS * up, 1.0f);
				v[5] = float4(IN[0].pos - halfS * right + halfS * up, 1.0f);

				float t = _Time.y * _BendSpeed * IN[0].speed;
				float forward = sin(IN[0].angle + UNITY_PI * t) * _BendScale * IN[0].bend;
				float backward = sin(IN[0].angle + UNITY_PI * t + halfS) * _BendScale * IN[0].bend;
				v[0].xyz = rotate_vector_at(v[0].xyz, v[2].xyz, rotate_angle_axis(forward, up)); 
				v[1].xyz = rotate_vector_at(v[1].xyz, v[3].xyz, rotate_angle_axis(backward, up)); 
				v[4].xyz = rotate_vector_at(v[4].xyz, v[2].xyz, rotate_angle_axis(-forward, up)); 
				v[5].xyz = rotate_vector_at(v[5].xyz, v[3].xyz, rotate_angle_axis(-backward, up)); 

				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);
				float depth = IN[0].depth;

				g2f pIn;
				pIn.pos = mul(vp, v[0]);
				pIn.uv = float3(1.0f, 0.0f, depth);
				pIn.col = IN[0].col;
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[1]);
				pIn.uv = float3(1.0f, 1.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[2]);
				pIn.uv = float3(0.5f, 0.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[3]);
				pIn.uv = float3(0.5f, 1.0f, depth);
				triStream.Append(pIn);

				triStream.RestartStrip();

				pIn.pos = mul(vp, v[2]);
				pIn.uv = float3(0.5f, 0.0f, depth);
				pIn.col = IN[0].col;
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[3]);
				pIn.uv = float3(0.5f, 1.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[4]);
				pIn.uv = float3(0.0f, 0.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[5]);
				pIn.uv = float3(0.0f, 1.0f, depth);
				triStream.Append(pIn);

				triStream.RestartStrip();
			}

			float4 frag (g2f IN) : COLOR {
				float4 col = UNITY_SAMPLE_TEX2DARRAY(_TextureArray, IN.uv);
				col.rgb = lerp(col.rgb, IN.col.rgb, IN.col.a);
				return col;
			}

			ENDCG
		}
	} 
}
