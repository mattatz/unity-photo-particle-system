using UnityEngine;

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class TextureArray : MonoBehaviour {

		[SerializeField] int width = 256;
		[SerializeField] int height = 256;

		[SerializeField] Texture2DArray array;
		[SerializeField] List<Texture2D> textures;
		[SerializeField] Material material;
		[SerializeField] int count = 500;

		int current = 0;
        int acc = 0;

		void Start () {
			array = new Texture2DArray(width, height, count, TextureFormat.RGB24, false);
			array.Apply();
			material.SetTexture("_TextureArray", array);
			material.SetFloat("_Depth", count);
			Load(textures);
		}

		void Load (List<Texture2D> textures) {
			var candidates = textures.FindAll(tex => tex.format == TextureFormat.RGB24).ToList();
			int cn = candidates.Count;

            for(int i = 0; i < count; i++) {
                Graphics.CopyTexture(textures[i % cn], 0, 0, array, current, 0);
                current = (current + 1) % count;
            }

			array.Apply();
			material.SetTexture("_TextureArray", array);
		}

	}
		
}

