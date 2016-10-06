using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class Cylinder : GPUParticleUpdater {

		[SerializeField] float distance = 1f;
		[SerializeField] float interval = 10f;
		[SerializeField] List<float> offsets;

		int current = 0;

		void OnEnable () {
			StartCoroutine(Repeater());
		}

		IEnumerator Repeater () {
			yield return 0;
			while(true) {
				yield return new WaitForSeconds(interval);
				current++;
			}
		}

		public override void Render (GPUParticleSystem system) {
			material.SetFloat("_Count", system.Count);

			float side = Mathf.Sqrt(system.Count);
			material.SetFloat("_Side", side);
			material.SetFloat("_Unit", 1f / side);

			material.SetFloat("_Size", system.Size);

			var offset = offsets[current % offsets.Count];
			material.SetVector("_Center", new Vector3(0f, offset, Camera.main.transform.position.z + distance));

			var position = system.GetProp("_Position");
			var rotation = system.GetProp("_Rotation");

			if(position != null && rotation != null) {
				material.SetTexture(position.Key, position.FBO.ReadTex);
				Blit(position.FBO, material, 0);

				material.SetTexture(rotation.Key, rotation.FBO.ReadTex);
				Blit(rotation.FBO, material, 1);
			}
		}

	}
		
}

