using UnityEngine;
using System.Collections;

namespace mattatz {

	public class ApplyVelocity : GPUParticleUpdater {

		public override void Render (GPUParticleSystem system) {
			var velocity = system.GetProp("_Velocity");
			var position = system.GetProp("_Position");
			if(velocity != null && position != null) {
				material.SetTexture(velocity.Key, velocity.FBO.ReadTex);
				material.SetTexture(position.Key, position.FBO.ReadTex);
				Blit(position.FBO, material);
			}
		}

	}
		
}

