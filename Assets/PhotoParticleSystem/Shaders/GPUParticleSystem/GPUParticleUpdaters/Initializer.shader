Shader "mattatz/GPUParticleUpdater/Initializer" {

	Properties {
		_Radius ("Radius", Float) = 10.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "Assets/Common/Shaders/Random.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		ENDCG

		// init position buffer
		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag
			float _Radius;
			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float radius = nrand(IN.uv, 12.7) * _Radius;
				return float4(random_point_on_sphere(IN.uv) * radius, nrand(IN.uv));
			}
			ENDCG
		}

		// init velocity buffer
		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag
			float4 frag (v2f_gpu_particle IN) : SV_Target {
				return float4(0, 0, 0, 0);
			}
			ENDCG
		}

		// init color buffer
		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag
			float4 frag (v2f_gpu_particle IN) : SV_Target {
				return float4(1, 1, 1, 0);
			}
			ENDCG
		}

	}
}
