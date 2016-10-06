Shader "mattatz/GPUParticleUpdater/Attenuation" {

	Properties {
		_Atten ("Attenuation", Range(0.0, 1.0)) = 0.9
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "./GPUParticleUpdaterCommon.cginc"

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position;
			sampler2D _Velocity;

			float _Atten;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float4 vel = tex2D(_Velocity, IN.uv);
				vel.xyz *= _Atten;
				return vel;
			}

			ENDCG
		}

	}
}
