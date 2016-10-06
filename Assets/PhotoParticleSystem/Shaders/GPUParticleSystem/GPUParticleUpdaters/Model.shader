Shader "mattatz/GPUParticleUpdater/Model" {

	Properties {
		_Model ("Model Position", 2D) = "" {}
		_UV ("UV Position", 2D) = "" {}
		_Texture ("Color Texture", 2D) = "" {}
		_Speed ("Speed", Float) = 1.5
		_Depth ("Depth", Float) = 0.0
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		#include "Assets/Common/Shaders/Random.cginc"

		float _Count, _Side; 
		float _Speed, _Size, _Depth;

		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position, _Velocity, _Model;
			float4x4 _Matrix;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float4 vel = tex2D(_Velocity, IN.uv);

				float3 model = tex2D(_Model, IN.uv).xyz;
				float3 to = (model.xyz - 0.5);
				to = mul(_Matrix, float4(to, 1.0)).xyz;
				to.z += _Depth;

				vel.xyz += (to.xyz - pos.xyz) * unity_DeltaTime.x * _Speed;
				return vel;
			}
			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Color, _UV, _Texture;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 col = tex2D(_Color, IN.uv);
				float2 uv = tex2D(_UV, IN.uv).xy;
				float4 to = tex2D(_Texture, uv);
				return lerp(col, to, unity_DeltaTime.x * _Speed);
			}
			ENDCG
		}

	}
}
