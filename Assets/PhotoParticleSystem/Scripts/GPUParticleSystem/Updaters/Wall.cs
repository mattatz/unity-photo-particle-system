using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public enum WallMode {
		Simple
	};

	public class Wall : GPUParticleUpdater {

		[SerializeField] float distanceNear = 1f;
		[SerializeField] float distanceFar = 8.5f;
		[SerializeField] float interval = 10f;

		int current = 0;
		float distance = -1f;
        Vector2 offset;

		protected override void Start () {
			base.Start();
		}

		void OnEnable () {
			distance = distanceNear;
			StartCoroutine(Repeater());
		}

		IEnumerator Repeater () {
			yield return 0;
			while(true) {
				yield return new WaitForSeconds(interval);
				StartCoroutine(Pan());
			}
		}

		IEnumerator Pan () {
			yield return 0;

            offset = new Vector2(Random.Range(-0.3f, 0.3f), Random.Range(-0.25f, 0.25f));

			distance = distanceFar;
			yield return new WaitForSeconds(1f);
			distance = distanceNear;
		}

		protected override void Update () {
			base.Update();
		}

		public override void Render (GPUParticleSystem system) {
			material.SetFloat("_Count", system.Count);
			material.SetFloat("_Side", Mathf.Sqrt(system.Count));
			material.SetFloat("_Size", system.Size);

			material.SetVector("_Offset", offset);
			material.SetFloat("_Depth", Camera.main.transform.position.z + distance);

			var position = system.GetProp("_Position");
			var rotation = system.GetProp("_Rotation");
			material.SetTexture(position.Key, position.FBO.ReadTex);
			material.SetTexture(rotation.Key, rotation.FBO.ReadTex);
			Blit(position.FBO, material, 0);
			Blit(rotation.FBO, material, 1);
		}

	}
		
}

