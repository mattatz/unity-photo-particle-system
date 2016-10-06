Shader "mattatz/GPUParticleUpdater/Wall" {

	Properties {
		_Intensity ("Intensity", Range(0.0, 0.2)) = 0.1
		_Offset ("Offset", Vector) = (0.0, 0.0, -1.0, -1.0)
		_Depth ("Depth", Float) = 0.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		#include "Assets/Common/Shaders/Random.cginc"

		float _Count, _Side; 
		float _Size, _Intensity, _Depth;
		float2 _Offset;

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

				float y = floor(uv.y / _Position_TexelSize.y);
				float seed = nrand(y);
				uv.x += sin(_Time.x * (seed - 0.5)) * _Intensity;

				float3 to = float3((uv - 0.5 + _Offset) * (_Side * _Size * 0.4), _Depth);
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
				float4 rot = tex2D(_Rotation, IN.uv);
				rot = lerp(rot, float4(0, 0, 0, 1), unity_DeltaTime.x);
				return rot;
			}

			ENDCG
		}

	}
}
