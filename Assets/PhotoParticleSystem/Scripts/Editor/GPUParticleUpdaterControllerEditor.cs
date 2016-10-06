using UnityEngine;
using UnityEditor;

using System.Collections;

namespace mattatz {

	[CustomEditor (typeof(GPUParticleUpdaterController))]
	public class GPUParticleUpdaterControllerEditor : Editor {

		public override void OnInspectorGUI () {
			base.OnInspectorGUI();

			if(GUILayout.Button("Next")) {
				var controller = target as GPUParticleUpdaterController;
				controller.Next();
			}

		}

	}

}
