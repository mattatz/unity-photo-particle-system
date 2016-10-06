Shader "mattatz/GPUParticleUpdater/Space" {

	Properties {
		_Wave ("Wave", Vector) = (0.1, 0, -1, -1)
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		#include "Assets/Common/Shaders/Random.cginc"

		float _Count, _Speed, _Size;
		float2 _Side;
		float3 _Offset;
		float2 _Wave;

		ENDCG

		Pass {
			CGPROGRAM

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position;
			float4 _Position_TexelSize;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);

				float2 uv = IN.uv;

				float id = uv.x / _Position_TexelSize.x + (uv.y / _Position_TexelSize.y) * _Position_TexelSize.z;

				float x = fmod(id, _Side.x);
				float y = id * _Side.y;

				float3 to = float3(floor(x), floor(fmod(y, _Side.x)), floor(y * _Side.y));

				float dy = nrand(id);
				to.y += cos(_Time.y * dy) * _Wave.x;

				to += _Offset;

				pos.xyz = lerp(pos.xyz, to, unity_DeltaTime.x * _Speed);

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
				float4 rot = tex2D(_Rotation, IN.uv);
				rot = lerp(rot, float4(0, 0, 0, 1), unity_DeltaTime.x);
				return rot;
			}

			ENDCG
		}

	}
}
