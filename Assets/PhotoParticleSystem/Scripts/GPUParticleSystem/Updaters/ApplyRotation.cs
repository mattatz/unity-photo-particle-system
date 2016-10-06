using UnityEngine;
using System.Collections;

namespace mattatz {

	public class ApplyRotation : GPUParticleUpdater {

		public override void Render (GPUParticleSystem system) {
			var velocity = system.GetProp("_Velocity");
			var rotation = system.GetProp("_Rotation");
			if(velocity != null && rotation != null) {
				material.SetTexture(velocity.Key, velocity.FBO.ReadTex);
				material.SetTexture(rotation.Key, rotation.FBO.ReadTex);
				Blit(rotation.FBO, material);
			}
		}

	}
		
}

