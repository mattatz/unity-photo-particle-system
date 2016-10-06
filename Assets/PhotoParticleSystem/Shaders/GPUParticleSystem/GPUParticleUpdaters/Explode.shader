Shader "mattatz/GPUParticleUpdater/Explode" {

	Properties {
		_F ("Force", Float) = 1.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "./GPUParticleUpdaterCommon.cginc"
			#include "Assets/Common/Shaders/Random.cginc"

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position;
			sampler2D _Velocity;
			float _F;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float4 vel = tex2D(_Velocity, IN.uv);
				vel.xyz = normalize(pos.xyz + nrand3(IN.uv, _Time.y) * 0.01) * unity_DeltaTime * 0.00001 * _F;
				return vel;
			}

			ENDCG
		}

	}
}
