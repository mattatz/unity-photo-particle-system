using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class Mosaic : GPUParticleUpdater {

        [System.Serializable] class Data {
            public Texture2D texture;
            public float scale = 1f;
        }

		[SerializeField] List<Data> data;
		[SerializeField] float distance = 1f;
		[SerializeField] int index = 0;
        [SerializeField] float interval = 10f;

		Texture2D texture;

		protected override void Update () {
			base.Update();
		}

		void OnEnable () {
            StartCoroutine(Repeater());
		}

        IEnumerator Repeater () {
            yield return 0;
            while(true) {
                yield return new WaitForSeconds(interval);
			    index++;
            }
        }

		public override void Render (GPUParticleSystem system) {
            var d = data[index % data.Count];
            texture = d.texture;
			material.SetTexture("_MainTex", texture);

            var ratio = 1f * texture.width / texture.height;
            var scale = 1f / d.scale;
			material.SetFloat("_Ratio", ratio);
			material.SetFloat("_Scale", scale);
			material.SetVector("_Offset", new Vector2((1f - scale) * 0.5f, (1f - scale * ratio) * 0.5f));

			material.SetFloat("_Count", system.Count);
			material.SetFloat("_Side", Mathf.Sqrt(system.Count));
			material.SetFloat("_Size", system.Size);
			material.SetFloat("_Depth", Camera.main.transform.position.z + distance);

			var position = system.GetProp("_Position");
			var rotation = system.GetProp("_Rotation");
			var color = system.GetProp("_Color");

            material.SetTexture(position.Key, position.FBO.ReadTex);
            Blit(position.FBO, material, 0);

            material.SetTexture(rotation.Key, rotation.FBO.ReadTex);
            Blit(rotation.FBO, material, 1);

            material.SetTexture(color.Key, color.FBO.ReadTex);
            Blit(color.FBO, material, 2);
		}

	}
		
}

