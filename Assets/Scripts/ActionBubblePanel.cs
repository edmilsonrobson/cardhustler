using DG.Tweening;
using TMPro;
using UnityEngine;

public class ActionBubblePanel : MonoBehaviour
{
    private Canvas canvas;
    private RectTransform rect;
    private CanvasGroup canvasGroup;

    [SerializeField]
    private TextMeshProUGUI actionText;

    [SerializeField]
    private Vector3 worldOffset = new Vector3(0, 1.5f, 0); // lift above target

    [SerializeField]
    private Vector2 screenOffsetPx = new Vector2(0, 20f); // nudge in pixels

    [SerializeField]
    private Camera cam; // assign or will use Camera.main

    void Awake()
    {
        canvas = GetComponentInParent<Canvas>();
        rect = transform as RectTransform;
        canvasGroup = GetComponent<CanvasGroup>();
        if (cam == null)
            cam = Camera.main;
    }

    public void ShowActionBubble(Transform target, string action, string shortcut)
    {
        if (target == null || canvas == null || rect == null || cam == null)
            return;

        actionText.text = action;
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;

        Vector3 worldPos = target.position + worldOffset;
        Vector3 screenPos = RectTransformUtility.WorldToScreenPoint(cam, worldPos);

        if (screenPos.z < 0f)
        {
            HideActionBubble();
            return;
        }

        screenPos += (Vector3)screenOffsetPx;

        rect.position = screenPos + new Vector3(0, 10f, 0);

        canvasGroup.alpha = 0f;
        canvasGroup.DOKill();
        rect.DOKill();

        rect.DOMove(screenPos, 0.12f).From(rect.position).SetEase(Ease.OutQuad);
        canvasGroup.DOFade(1f, 0.12f).From(0f).SetEase(Ease.OutQuad);
    }

    public void HideActionBubble()
    {
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;
        canvasGroup.DOKill();
        rect.DOKill();
        Vector3 targetPos = rect.position + new Vector3(0, 10f, 0);
        rect.DOMove(targetPos, 0.12f).SetEase(Ease.OutQuad);
        canvasGroup.DOFade(0f, 0.12f).SetEase(Ease.OutQuad);
    }
}
