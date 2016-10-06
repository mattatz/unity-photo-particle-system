using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

	public class Space : GPUParticleUpdater {

		[SerializeField] Vector2 intervalRange = new Vector2(1.5f, 2.2f);
        [SerializeField] float speed = 3f;
		[SerializeField, Range(0f, 1f)] float depth = 0.9f;
        [SerializeField] Vector3 offset;

        float side = -1f;
        bool[,,] flags;

		protected override void Start () {
			base.Start();
		}

		void OnEnable () {
            side = -1f; // initialize
			StartCoroutine(Repeater());
		}

		IEnumerator Repeater () {
			yield return 0;
			while(true) {
				yield return new WaitForSeconds(Random.Range(intervalRange.x, intervalRange.y));
				Zoom();
			}
		}

		void Zoom () {
            var directions = GetDirections(offset);
            if(directions.Count > 0) {
                var dir = directions[Random.Range(0, directions.Count)];
                offset += dir;
                SetFlag(offset, true);
            }
		}

		protected override void Update () {
			base.Update();
            offset.x = Mathf.FloorToInt(offset.x);
            offset.y = Mathf.FloorToInt(offset.y);
            offset.z = Mathf.FloorToInt(offset.z);
		}

		public override void Render (GPUParticleSystem system) {
			material.SetFloat("_Speed", speed);
			material.SetFloat("_Count", system.Count);

            if(side < 0f) {
                side = Mathf.Pow(system.Count, 1f / 3f);
			    material.SetVector("_Side", new Vector2(side, 1f / side));
                // offset = Vector3.one * (side * 0.5f);
                offset = Vector3.one * (side * 0.5f) + new Vector3(Random.Range(-0.25f, 0.25f) * side, Random.Range(-0.25f, 0.25f) * side, Random.Range(-0.25f, 0.25f) * side);

                int len = Mathf.FloorToInt(side);
                flags = new bool[len, len, len];
                SetFlag(offset, true);
            }

			material.SetFloat("_Size", system.Size);
			material.SetVector("_Offset", -(offset + new Vector3(0f, 0f, depth + side * 0.25f)));

			var position = system.GetProp("_Position");
			var rotation = system.GetProp("_Rotation");

			material.SetTexture(position.Key, position.FBO.ReadTex);
			material.SetTexture(rotation.Key, rotation.FBO.ReadTex);
			Blit(position.FBO, material, 0);
			Blit(rotation.FBO, material, 1);
		}

        void SetFlag (Vector3 p, bool flag) {
            int 
                z = Mathf.FloorToInt(p.z),
                y = Mathf.FloorToInt(p.y),
                x = Mathf.FloorToInt(p.x);
            flags[z, y, x] = flag;
        }

        List<Vector3> GetDirections (Vector3 p) {
            int 
                z = Mathf.FloorToInt(p.z),
                y = Mathf.FloorToInt(p.y),
                x = Mathf.FloorToInt(p.x);

            var directions = new List<Vector3>();

            int limit = Mathf.FloorToInt(side);

            for(int dz = -1; dz <= 1; dz++) {
                if (z + dz < 0 || z + dz >= limit) continue;
                for(int dy = -1; dy <= 1; dy++) {
                    if (y + dy < 0 || y + dy >= limit) continue;
                    for(int dx = -1; dx <= 1; dx++) {
                        if (x + dx < 0 || x + dx >= limit) continue;
                        if(!flags[z+dz, y+dy, x+dx]) {
                            directions.Add(new Vector3(dz, dy, dx));
                        }
                    }
                }
            }
            return directions;
        }

	}
		
}

