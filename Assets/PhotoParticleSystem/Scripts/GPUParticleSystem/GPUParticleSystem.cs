using UnityEngine;
using Random = UnityEngine.Random;

using System;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class GPUParticleSystem : MonoBehaviour {

		public int Count { get { return count; } }
		public float Size { get { return material.GetFloat("_Size"); } }

		[SerializeField, Range(100, 60000)] int count = 30000;
		[SerializeField] Material material;

		Mesh mesh;

		[SerializeField] bool debug = false;
		[SerializeField] List<GPUParticleProp> props;
		[SerializeField] List<GPUParticleUpdater> initializers;
		[SerializeField] List<GPUParticleUpdater> updaters;

		bool initialized;

		void Start () {
			int sqrt = Mathf.CeilToInt(Mathf.Sqrt(count * 1.0f));
			count = sqrt * sqrt;

			mesh = Build(sqrt);
			props.ForEach(prop => prop.Setup(sqrt, sqrt));
			initializers.ForEach(updater => {
				if(updater != null && updater.isActiveAndEnabled) {
					updater.Init(this);
				}
			});
		}
		
		void Update () {
			// if(Input.GetKeyDown(KeyCode.D)) debug = !debug;

			updaters.ForEach(updater => {
				if(updater != null && updater.isActiveAndEnabled) {
					updater.Render(this);
				}
			});
			props.ForEach(prop => {
				material.SetTexture(prop.Key, prop.FBO.ReadTex);
			});
			Graphics.DrawMesh(mesh, transform.localToWorldMatrix, material, 0);
		}

		public GPUParticleProp GetProp (string key) {
			var found = props.Find(prop => prop.Key == key);
			if(found == null) {
				Debug.LogWarning("A property named " + key + " is not found");
			}
			return found;
		}

		Mesh Build (int count = 10000) {
			var mesh = new Mesh();

			int dcount = count * count;
			var vertices = new Vector3[dcount];
			var uv = new Vector2[dcount];
			var indices = new int[dcount];

			for(int i = 0; i < dcount; i++) {
				int k = i;

				float tx = (1f * (k % count)) / count;
				float ty = (1f * (k / count)) / count;

				vertices[i] = Random.insideUnitSphere;
				uv[i] = new Vector2(tx, ty);
				indices[i] = i;
			}

			mesh.vertices = vertices;
			mesh.uv = uv;
			mesh.SetIndices(indices, MeshTopology.Points, 0);
			return mesh;
		}

		void OnGUI () {
			if(!debug) return;

			const float size = 250f;
			for(int i = 0, n = props.Count; i < n; i++) {
				var fbo = props[i].FBO;
				GUI.Label(new Rect(0f, size * i, size, size), props[i].Key);
				GUI.DrawTexture(new Rect(0f, size * i, size, size), fbo.ReadTex);
				GUI.DrawTexture(new Rect(size, size * i, size, size), fbo.WriteTex);
			}

		}

		void OnDestroy () {
			props.ForEach(prop => {
				prop.Dispose();
			});
		}

	}
		
}

