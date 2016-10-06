#ifndef __GPU_PARTICLE_UPDATER_COMMON__

#define __GPU_PARTICLE_UPDATER_COMMON__

struct appdata_gpu_particle {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct v2f_gpu_particle {
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
};

v2f_gpu_particle vert_gpu_particle (appdata_gpu_particle IN) {
	v2f_gpu_particle OUT;
	OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
	OUT.uv = IN.uv;
	return OUT;
}
		
#endif // __GPU_PARTICLE_UPDATER_COMMON__