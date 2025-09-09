using DG.Tweening;
using UnityEngine;
using UnityEngine.EventSystems;

[RequireComponent(typeof(CanvasGroup))]
public class EffectUtils2D : MonoBehaviour, IPointerClickHandler
{
    [SerializeField]
    private bool enableJiggleOnClick = false;

    [SerializeField]
    private float scaleDown = 0.85f; // how much to squash

    [SerializeField]
    private float scaleUp = 1.1f; // how much to stretch

    [SerializeField]
    private float duration = 0.3f; // total time

    private Vector3 originalScale;

    [SerializeField]
    private CanvasGroup canvasGroup;

    private void Awake()
    {
        originalScale = transform.localScale;
        canvasGroup = GetComponent<CanvasGroup>();
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

    public void MenuIn()
    {
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;

        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOScale(1.05f, 0.15f).SetEase(Ease.OutQuad));
        seq.Append(transform.DOScale(1f, 0.1f).SetEase(Ease.OutBack));

        seq.Play();
    }

    public void MenuOut()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOScale(0.95f, 0.12f).SetEase(Ease.InQuad)); // shrink slightly
        seq.Join(canvasGroup.DOFade(0, 0.12f).SetEase(Ease.InQuad));

        seq.OnComplete(() =>
        {
            canvasGroup.blocksRaycasts = false;
            canvasGroup.interactable = false;
        });
    }

    public void FadeIn()
    {
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;

        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad));
        seq.Play();
    }

    public void FadeOut()
    {
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;

        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(0, 0.12f).SetEase(Ease.InQuad));
        seq.Play();
    }
}
