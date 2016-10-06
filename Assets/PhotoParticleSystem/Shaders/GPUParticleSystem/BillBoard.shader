Shader "mattatz/Billboard" {

	Properties  {
		_TextureArray ("Texture", 2DArray) = "" {}

		_Position ("Position", 2D) = "gray" {}
		_Velocity ("Velocity", 2D) = "gray" {}
		_Rotation ("Rotation", 2D) = "gray" {}

		_Depth ("Depth", Float) = 1.0
		_Size ("Size", Range(0, 3)) = 0.5
	}

	SubShader {

		CGINCLUDE

		#pragma target 4.0
		#include "UnityCG.cginc"

		half _Size;
		half _Depth;

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2g {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float depth : TEXCOORD1;
		};

		struct g2f {
			float4 pos : SV_POSITION;
			float3 uv : TEXCOORD0;
		};

		sampler2D _Position;
		sampler2D _Velocity;
		sampler2D _Rotation;

		UNITY_DECLARE_TEX2DARRAY(_TextureArray);

		v2g vert (appdata IN) {
			v2g OUT;

			float4 position = tex2Dlod(_Position, float4(IN.uv, 0, 0));
			IN.vertex.xyz = position.xyz;
			OUT.pos = mul(unity_ObjectToWorld, IN.vertex);

			OUT.uv = IN.uv;
			OUT.depth = IN.uv.x * _Depth;

			return OUT;
		}

		ENDCG

		Pass {
			Tags { "RenderType"="Opaque" }
			LOD 200
		
			CGPROGRAM

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			Texture2D _MainTex;

			[maxvertexcount(4)]
			void geom (point v2g IN[1], inout TriangleStream<g2f> triStream) {
				float3 up = float3(0, 1, 0);
				float3 look = _WorldSpaceCameraPos - IN[0].pos;
				look.y = 0;
				look = normalize(look);
				float3 right = cross(up, look);
				
				float halfS = 0.5f * _Size;
						
				float4 v[4];
				v[0] = float4(IN[0].pos + halfS * right - halfS * up, 1.0f);
				v[1] = float4(IN[0].pos + halfS * right + halfS * up, 1.0f);
				v[2] = float4(IN[0].pos - halfS * right - halfS * up, 1.0f);
				v[3] = float4(IN[0].pos - halfS * right + halfS * up, 1.0f);

				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);
				float depth = IN[0].depth;

				g2f pIn;
				pIn.pos = mul(vp, v[0]);
				pIn.uv = float3(1.0f, 0.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[1]);
				pIn.uv = float3(1.0f, 1.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[2]);
				pIn.uv = float3(0.0f, 0.0f, depth);
				triStream.Append(pIn);

				pIn.pos =  mul(vp, v[3]);
				pIn.uv = float3(0.0f, 1.0f, depth);
				triStream.Append(pIn);
			}

			float4 frag (g2f IN) : COLOR {
				return UNITY_SAMPLE_TEX2DARRAY(_TextureArray, IN.uv);
			}

			ENDCG
		}
	} 
}
