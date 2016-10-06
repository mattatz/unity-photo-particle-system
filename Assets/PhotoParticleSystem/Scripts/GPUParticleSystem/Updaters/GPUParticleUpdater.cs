using UnityEngine;
using System.Collections;

namespace mattatz {

	public class GPUParticleUpdater : MonoBehaviour {

		[SerializeField] protected Material material;

		protected virtual void Awake () {}
		protected virtual void Start () {}
		protected virtual void Update () {}
		protected virtual void Render () {}

		public virtual void Init (GPUParticleSystem system) {
		}

		public virtual void Render (GPUParticleSystem system) {
		}

		protected void Blit (FboPingpong fbo, Material mat, int pass = -1) {
			Graphics.Blit(null, fbo.WriteTex, mat, pass);
			fbo.Swap();
		}

	}
		
}

