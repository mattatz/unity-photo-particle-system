Shader "mattatz/GPUParticleUpdater/Mosaic" {

	Properties {
		_Depth ("Depth", Float) = 0.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		#include "Assets/Common/Shaders/Random.cginc"

		float _Count, _Side; 
		float _Size, _Depth;

		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag
			sampler2D _Position;
			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float2 uv = IN.uv;
				float3 to = float3((uv - 0.5) * (_Side * _Size * 0.5), _Depth);
				pos.xyz = lerp(pos.xyz, to, unity_DeltaTime.x);
				return pos;
			}
			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Rotation;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 from = tex2D(_Rotation, IN.uv);
				float4 to = float4(0, 0, 0, 1);
				return lerp(from, to, unity_DeltaTime.x);
			}

			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _MainTex, _Color;
			float4 _MainTex_TexelSize;
			float _Ratio, _Scale;
			float2 _Offset;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 from = tex2D(_Color, IN.uv);

				float2 uv = IN.uv;
				uv.y *= _Ratio;
				uv *= _Scale;
				uv += _Offset.xy;

				float4 to = tex2D(_MainTex, uv);
				return lerp(from, to, unity_DeltaTime.x);
			}

			ENDCG
		}

	}
}
