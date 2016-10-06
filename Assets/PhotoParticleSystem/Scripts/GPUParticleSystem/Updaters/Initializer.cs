using UnityEngine;
using System.Collections;

namespace mattatz {

	public class Initializer : GPUParticleUpdater {

		public override void Init (GPUParticleSystem system) {
			var position = system.GetProp("_Position");
			if(position != null) {
				Blit(position.FBO, material, 0);
			}

			var velocity = system.GetProp("_Velocity");
			if(velocity != null) {
				Blit(velocity.FBO, material, 1);
			}

			var color = system.GetProp("_Color");
			if(color != null) {
				Blit(color.FBO, material, 2);
			}
		}

	}
		
}

