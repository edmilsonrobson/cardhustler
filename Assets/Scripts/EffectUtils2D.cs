using DG.Tweening;
using UnityEngine;
using UnityEngine.EventSystems;

public class EffectUtils2D : MonoBehaviour, IPointerClickHandler
{
    [SerializeField]
    private bool enableJiggleOnClick = true;

    [SerializeField]
    private float scaleDown = 0.85f; // how much to squash

    [SerializeField]
    private float scaleUp = 1.1f; // how much to stretch

    [SerializeField]
    private float duration = 0.3f; // total time

    private Vector3 originalScale;

    private void Awake()
    {
        originalScale = transform.localScale;
    }

    public void OnPointerClick(PointerEventData _eventData)
    {
        if (!enableJiggleOnClick)
            return;

        Jiggle();
    }

    public void Jiggle()
    {
        // Kill any existing tweens so it doesn't stack weirdly
        transform.DOKill();

        Sequence seq = DOTween.Sequence();

        seq.Append(
                transform
                    .DOScale(new Vector3(scaleDown, scaleUp, 1f), duration * 0.25f)
                    .SetEase(Ease.OutQuad)
            ) // squash
            .Append(
                transform
                    .DOScale(new Vector3(scaleUp, scaleDown, 1f), duration * 0.25f)
                    .SetEase(Ease.OutQuad)
            ) // stretch
            .Append(
                transform.DOScale(originalScale * 1.05f, duration * 0.25f).SetEase(Ease.OutQuad)
            ) // slight overshoot
            .Append(transform.DOScale(originalScale, duration * 0.25f).SetEase(Ease.OutBack)); // settle back

        seq.Play();
    }
}
