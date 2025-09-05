using DG.Tweening;
using UnityEngine;

public class EscMenu : MonoBehaviour
{
    public bool IsOpen { get; private set; } = false;

    private CanvasGroup canvasGroup;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;

        IsOpen = false;
    }

    public void Open()
    {
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;

        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOScale(1.05f, 0.15f).SetEase(Ease.OutQuad)); // subtle overshoot
        seq.Append(transform.DOScale(1f, 0.1f).SetEase(Ease.OutBack)); // settle

        IsOpen = true;
        IsoPlayerMovement.Instance.BlockPlayerActions();
    }

    public void Close()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOScale(0.95f, 0.12f).SetEase(Ease.InQuad)); // shrink slightly
        seq.Join(canvasGroup.DOFade(0, 0.12f).SetEase(Ease.InQuad));

        seq.OnComplete(() =>
        {
            canvasGroup.blocksRaycasts = false;
            canvasGroup.interactable = false;
            IsOpen = false;
            IsoPlayerMovement.Instance.UnblockPlayerActions();
        });
    }

    public void OnExit()
    {
        Application.Quit();
    }
}
