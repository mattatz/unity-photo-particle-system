using UnityEngine;
using System.Collections;

namespace mattatz {

	[System.Serializable]
	public class GPUParticleProp : System.IDisposable {

		public string Key { get { return key; } }
		public FboPingpong FBO { get { return fbo; } }

		[SerializeField] string key = "_Position";
		[SerializeField] FboPingpong fbo;

		public void Setup (int width, int height) {
			fbo = new FboPingpong(width, height);
		}

		public void Dispose () {
			fbo.Dispose();
		}

	}
	
}

