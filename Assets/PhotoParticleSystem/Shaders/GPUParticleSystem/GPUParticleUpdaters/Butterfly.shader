Shader "mattatz/GPUParticleUpdater/Butterfly" {

	Properties {
		_T ("T", Range(0.0, 1.0)) = 1.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"

		float _T;

		ENDCG

		Pass {
			CGPROGRAM

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Velocity;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 vel = tex2D(_Velocity, IN.uv);
				vel.a = lerp(vel.a, _T, unity_DeltaTime.x);
				return vel;
			}

			ENDCG
		}

	}
}
