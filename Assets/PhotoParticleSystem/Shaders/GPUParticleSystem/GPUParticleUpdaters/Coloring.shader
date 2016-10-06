Shader "mattatz/GPUParticleUpdater/Coloring" {

	Properties {
		_Col ("Color", Color) = (1, 1, 1, 1)
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"

		fixed4 _Col;

		ENDCG

		Pass {
			CGPROGRAM

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Color;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 col = tex2D(_Color, IN.uv);
				return lerp(col, _Col, unity_DeltaTime.x);
			}

			ENDCG
		}

	}
}
