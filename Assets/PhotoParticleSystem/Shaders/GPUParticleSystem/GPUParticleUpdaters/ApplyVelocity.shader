Shader "mattatz/GPUParticleUpdater/ApplyVelocity" {

	Properties {
		_Limit ("Limit", Range(0.1, 30.0)) = 5.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		Tags {
			"PreviewType"="Plane"
		}

		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "./GPUParticleUpdaterCommon.cginc"

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position, _Velocity;
			float _Limit;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 vel = tex2D(_Velocity, IN.uv);
				float4 pos = tex2D(_Position, IN.uv);
				float len = length(vel.xyz);
				if(len > _Limit) {
					vel.xyz = normalize(vel.xyz) * _Limit;
				}
				pos.xyz += (pos.a * 0.5 + 0.5) * vel.xyz * unity_DeltaTime.x;
				return pos;
			}

			ENDCG
		}

	}
}
