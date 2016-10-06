using UnityEngine;

using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class Model : GPUParticleUpdater {

		class Triangle {
			public int a, b, c;
			public Triangle(int a, int b, int c) {
				this.a = a;
				this.b = b;
				this.c = c;
			}
		}

		[SerializeField] Texture2D texture;
		[SerializeField] Texture2D uv;
		[SerializeField] Mesh mesh;

		void CreateModelTexture (int width, int height) {
			var vertices = mesh.vertices;
			var indices = mesh.triangles;
			var uvs = mesh.uv;
			int vertexCount = mesh.vertexCount;

			Vector3 min = Vector3.one * float.MaxValue;
			Vector3 max = Vector3.one * float.MinValue;

			List<Vector3> normalizedVertices = new List<Vector3>();
			List<Triangle> triangles = new List<Triangle>();

			for(int i = 0, n = indices.Length; i < n; i += 3) {
				int a = indices[i], b = indices[i + 1], c = indices[i + 2];
				triangles.Add(new Triangle(a, b, c));
			}

			for(int i = 0; i < vertexCount; i++) {
				var v = vertices[i];
				min = Vector3.Min(min, v);
				max = Vector3.Max(max, v);
			}

			Vector3 range = max - min;
			float maxLength = Mathf.Max(range.x, Mathf.Max(range.y, range.z));
			Vector3 offset = (range - Vector3.one * maxLength) * 0.5f / maxLength;

			for(int i = 0; i < vertexCount; i++) {
				var v = (vertices[i] - min) / maxLength;
				normalizedVertices.Add(v - offset);
			}

			texture = new Texture2D(width, height);
			uv = new Texture2D(width, height);

			var count = 1f / (width * height);
			var total = triangles.Count;

			for(int y = 0; y < height; y++) {
				for(int x = 0; x < width; x++) {
					var ratio = (y * width + x) * count;
					var triangle = triangles[Mathf.FloorToInt(ratio * total)];
					Vector3 v0 = normalizedVertices[triangle.a], v1 = normalizedVertices[triangle.b], v2 = normalizedVertices[triangle.c];

					// sample inside a triangle

					float w0 = Random.value;
					float w1 = Random.value;

					var v = Vector3.Lerp(v0, Vector3.Lerp(v1, v2, w0), w1);
					texture.SetPixel(y, x, new Color(v.x, v.y, v.z));

					var nuv = Vector2.Lerp(uvs[triangle.a], Vector2.Lerp(uvs[triangle.b], uvs[triangle.c], w0), w1);
					uv.SetPixel(y, x, new Color(nuv.x, nuv.y, 0f));
				}
			}

			texture.Apply();
			uv.Apply();
		}

		protected override void Update () {
			base.Update();
		}

		public override void Render (GPUParticleSystem system) {
			int side = Mathf.FloorToInt(Mathf.Sqrt(system.Count));
			CheckInit(side, side);

			var position = system.GetProp("_Position");
			var velocity = system.GetProp("_Velocity");
			var color = system.GetProp("_Color");
			material.SetTexture(position.Key, position.FBO.ReadTex);
			material.SetTexture(velocity.Key, velocity.FBO.ReadTex);
			material.SetTexture(color.Key, color.FBO.ReadTex);

			var matrix = transform.localToWorldMatrix;
			material.SetMatrix("_Matrix", matrix);

			Blit(velocity.FBO, material, 0);
			Blit(color.FBO, material, 1);
		}

		void CheckInit (int width, int height) {
			if(texture == null) {
				CreateModelTexture(width, height);
				material.SetTexture("_Model", texture);
				material.SetTexture("_UV", uv);
			}
		}

	}
		
}

