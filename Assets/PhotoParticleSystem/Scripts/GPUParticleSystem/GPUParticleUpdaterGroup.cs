using UnityEngine;

using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	[System.Serializable]
	public class GPUParticleUpdaterGroup {

		public float Duration { get { return duration; } } 

		[SerializeField] string name = "Default";
		[SerializeField] List<GPUParticleUpdater> updaters;
		[SerializeField] float duration = 50f;

		public void Activate () {
			updaters.ForEach(updater => {
				if(updater != null) {
					updater.gameObject.SetActive(true);
				}
			});
		}

		public void Deactivate () {
			updaters.ForEach(updater => {
				if(updater != null) {
					updater.gameObject.SetActive(false);
				}
			});
		}

	}
		
}

