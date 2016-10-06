Shader "mattatz/GPUParticleUpdater/Turbulence" {

	Properties {
		_F ("Force", Float) = 1.0
		_Scale ("Scale", Vector) = (1, 1, 1, -1)
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM

			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "./GPUParticleUpdaterCommon.cginc"
			#include "Assets/Common/Shaders/Random.cginc"
			// #include "Assets/Common/Shaders/Noises/SimplexNoiseGrad3D.cginc"
			#include "Assets/Common/Shaders/Noises/SimplexNoise3D.cginc"

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position;
			sampler2D _Velocity;

			float _F;
			float3 _Scale;

			float3 snoise3 (float3 x) {
				float s = snoise(x);
				float s1 = snoise(float3(
					x.y + 0.072,
					x.z + 0.139,
					x.x + 0.051
				));
				float s2 = snoise(float3(
					x.z + 0.213,
					x.x + 0.077,
					x.y + 0.109
				));
				return float3(s, s1, s2);
			}

			float3 curl (float3 seed) {
				const float e = 0.1;
				const float e2 = e * 2.0;

				float3 dx = float3(e, 0, 0);
				float3 dy = float3(0, e, 0);
				float3 dz = float3(0, 0, e);

				float3 x0 = snoise3(seed - dx);
				float3 x1 = snoise3(seed + dx);
				float3 y0 = snoise3(seed - dy);
				float3 y1 = snoise3(seed + dy);
				float3 z0 = snoise3(seed - dz);
				float3 z1 = snoise3(seed + dz);

				float x = y1.z - y0.z - z1.y + z0.y;
				float y = z1.x - z0.x - x1.z + x0.z;
				float z = x1.y - x0.x - y1.x + y0.x;
				return normalize(float3(x, y, z));
			}

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float4 vel = tex2D(_Velocity, IN.uv);
				vel.xyz += curl(pos.xyz * _Scale) * _F * unity_DeltaTime.x;
				return vel;
			}

			ENDCG
		}

	}
}
