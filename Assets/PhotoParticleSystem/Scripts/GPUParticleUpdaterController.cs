using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class GPUParticleUpdaterController : MonoBehaviour {

		[SerializeField] List<GPUParticleUpdaterGroup> groups;
		[SerializeField] int index = 0;

		Coroutine co;

		GPUParticleUpdaterGroup current;

		void Update () {
			if(Input.GetKeyDown(KeyCode.N)) Next();
		}	

		IEnumerator Repeater () {
			yield return 0;
			while(true) {
				Step ();
				yield return new WaitForSeconds(current.Duration);
			}
		}

		void Step () {
			if(current != null) current.Deactivate();
			current = groups[index % groups.Count];
			current.Activate();
			index++;
		}

		public void Next () {
			StopCoroutine(co);
			co = StartCoroutine(Repeater());
		}

		void OnEnable () {
			co = StartCoroutine(Repeater());
		}

	}
		
}

