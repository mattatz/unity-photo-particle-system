using UnityEngine;

using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class Coloring : GPUParticleUpdater {

		[SerializeField] Color color = Color.white;

		public override void Render (GPUParticleSystem system) {
			var buffer = system.GetProp("_Color");
			material.SetTexture(buffer.Key, buffer.FBO.ReadTex);
			material.SetColor("_Color", color);
			Blit(buffer.FBO, material, 0);
		}

	}
		
}

