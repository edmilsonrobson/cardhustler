using DG.Tweening;
using UnityEngine;

public class WiggleBackAndForth : MonoBehaviour
{
    [SerializeField]
    private float strength = 30f;

    [SerializeField]
    private float duration = 0.5f;

    void Start()
    {
        var startRotation = transform.rotation;
        transform
            .DORotate(new Vector3(0, 0, -strength), 0)
            .OnComplete(() =>
            {
                transform
                    .DORotate(new Vector3(0, 0, strength), duration)
                    .SetEase(Ease.InOutSine)
                    .SetLoops(-1, LoopType.Yoyo);
            });
    }
}
