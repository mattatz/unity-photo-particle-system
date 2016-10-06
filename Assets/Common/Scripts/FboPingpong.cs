using UnityEngine;
using System.Collections;

namespace mattatz {

	[System.Serializable]
	public class FboPingpong : System.IDisposable {

		public RenderTexture ReadTex { get { return RTs[readIndex]; } }
		public RenderTexture WriteTex { get { return RTs[writeIndex]; } }

		protected int readIndex = 0;
		protected int writeIndex = 1;

		[SerializeField] RenderTexture[] RTs;

		public FboPingpong(int width, int height) {
			RTs = new RenderTexture[2];
			RTs[0] = CreateRenderTex(width, height);
			RTs[1] = CreateRenderTex(width, height);
			Clear();
		}

		RenderTexture CreateRenderTex (int width, int height, RenderTextureFormat format = RenderTextureFormat.ARGBFloat, FilterMode filterMode = FilterMode.Point) {
			var rt = new RenderTexture(width, height, 0);
			rt.format = format;
			rt.filterMode = filterMode;
			rt.wrapMode = TextureWrapMode.Clamp;
			rt.generateMips = false;
			rt.hideFlags = HideFlags.DontSave;
			rt.Create();
			return rt;
		}

		public void Swap () {
			var tmp = readIndex; readIndex = writeIndex; writeIndex = tmp;
		}

		public void Clear () {
			Graphics.SetRenderTarget(RTs[0]);
			GL.Clear(false, true, Color.black);
			Graphics.SetRenderTarget(null);

			Graphics.SetRenderTarget(RTs[1]);
			GL.Clear(false, true, Color.black);
			Graphics.SetRenderTarget (null);
		}

		public void Dispose () {
			RTs[0].DiscardContents();
			RTs[0].Release();

			RTs[1].DiscardContents();
			RTs[1].Release();
		}

	}
		
}

