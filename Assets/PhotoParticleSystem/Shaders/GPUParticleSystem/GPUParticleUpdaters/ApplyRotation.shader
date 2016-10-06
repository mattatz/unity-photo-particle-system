Shader "mattatz/GPUParticleUpdater/ApplyRotation" {

	Properties {
		_Amount ("amount of rotation", Float) = 0.005
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		Tags {
			"PreviewType"="Plane"
		}

		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Assets/Common/Shaders/Math.cginc"
			#include "Assets/Common/Shaders/Random.cginc"
			#include "./GPUParticleUpdaterCommon.cginc"

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Velocity, _Rotation;
			float _Amount;

			float4 update_rotation(float2 seed, float4 r, float3 v) {
				float theta = (length(v) * _Amount);

				// Spin quaternion
				float4 dq = float4(random_point_on_sphere(seed) * sin(theta), cos(theta));

				// Applying the quaternion and normalize the result.
				return normalize(qmul(dq, r));
			}

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 vel = tex2D(_Velocity, IN.uv);
				float4 rot = tex2D(_Rotation, IN.uv);
				rot = update_rotation(IN.uv, rot, vel);
				return rot;
			}

			ENDCG
		}

	}
}
