using UnityEngine;
using System.Collections;

namespace mattatz {

	public class Butterfly : GPUParticleUpdater {

		[SerializeField, Range(0f, 1f)] float t = 1f;

		public override void Render (GPUParticleSystem system) {
			var velocity = system.GetProp("_Velocity");
			material.SetTexture(velocity.Key, velocity.FBO.ReadTex);
			material.SetFloat("_T", t);
			Blit(velocity.FBO, material);
		}

	}
		
}

