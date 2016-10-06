Shader "mattatz/GPUParticleUpdater/Cylinder" {

	Properties {
		_Radius ("Radius", Float) = 5.0
		_Spacing ("Spacing", Float) = 1.0
		_Depth ("Depth", Float) = 0.0
		_Speed ("Speed", Vector) = (0.25, 5.0, -1, -1)
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "./GPUParticleUpdaterCommon.cginc"
		#include "Assets/Common/Shaders/Random.cginc"
		#include "Assets/Common/Shaders/Math.cginc"

		#ifndef UNITY_PI_2
		#define UNITY_PI_2 (UNITY_PI*2.0)
		#endif

		#ifndef INV_UNITY_PI
		#define INV_UNITY_PI (1.0/UNITY_PI)
		#endif

		float _Count, _Side, _Unit; 
		float _Size;
		float3 _Center;

		float _Radius, _Spacing;
		float2 _Speed;

		float3 get_position (float2 uv) {
			float separate = (1.0 - (fmod(uv.y, _Unit * 2) / _Unit));
			float offset = _Time.x * separate * _Speed.x;

			float radius = (_Side * (_Size * 0.25 + _Spacing)) * INV_UNITY_PI;
			float x = cos((uv.x + offset) * UNITY_PI_2) * radius;
			float z = sin((uv.x + offset) * UNITY_PI_2) * radius;

			float y = (uv.y - 0.5) * (_Size * 0.5 + _Spacing) * _Side;

			return float3(x, y, z) + _Center;
		}

		ENDCG

		Pass {
			CGPROGRAM

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);

				float3 to = get_position(IN.uv);
				pos.xyz = lerp(pos.xyz, to, unity_DeltaTime.x * _Speed.y);
				return pos;
			}

			ENDCG
		}

		Pass {
			CGPROGRAM

			#pragma vertex vert_gpu_particle
			#pragma fragment frag

			sampler2D _Position, _Rotation;

			float4 frag (v2f_gpu_particle IN) : SV_Target {
				float4 pos = tex2D(_Position, IN.uv);
				float4 rot = tex2D(_Rotation, IN.uv);

				float4x4 m = look_at_matrix(float3(_Center.x, pos.y, _Center.z), pos.xyz, float3(0, 1, 0));
				rot = lerp(rot, matrix_to_quaternion(m), unity_DeltaTime.x * _Speed.y);

				return rot;
			}

			ENDCG
		}

	}
}
