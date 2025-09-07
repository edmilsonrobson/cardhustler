// using DG.Tweening;
// using UnityEngine;

// public class SkyboxRotator : MonoBehaviour
// {
//     [SerializeField]
//     private float secondsPerFullTurn = 30f;

//     [SerializeField]
//     private bool instantiateMaterial = true; // avoids editing the asset in Project

//     void Start()
//     {
//         if (RenderSettings.skybox == null)
//         {
//             Debug.LogWarning("No skybox material assigned in Lighting > Environment.");
//             return;
//         }

//         // Optional: clone so you don't mutate the project asset
//         if (instantiateMaterial)
//             RenderSettings.skybox = new Material(RenderSettings.skybox);

//         var mat = RenderSettings.skybox;

//         // Ensure we start from a sane 0..360 range
//         float start = Mathf.Repeat(mat.GetFloat("_Rotation"), 360f);

//         DOTween
//             .To(
//                 () => start,
//                 v =>
//                 {
//                     // keep it bounded and set
//                     float rot = Mathf.Repeat(v, 360f);
//                     mat.SetFloat("_Rotation", rot);
//                 },
//                 start + 360f,
//                 secondsPerFullTurn
//             )
//             .SetEase(Ease.Linear)
//             .SetLoops(-1, LoopType.Incremental); // never resets, keeps spinning smoothly
//     }
// }
