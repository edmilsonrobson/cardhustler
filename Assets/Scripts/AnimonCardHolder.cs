using UnityEngine;
using UnityEngine.EventSystems;

public class AnimonCardHolder : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    private CanvasGroup canvasGroup;

    void Awake()
    {
        canvasGroup = GetComponentInChildren<CanvasGroup>();
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (canvasGroup.alpha == 0)
            return;

        var rectTransform = GetComponent<RectTransform>();
        if (CardMouseOverPopup.Instance != null && rectTransform != null)
        {
            var animonCardUI = GetComponentInChildren<AnimonCardUI>();
            if (animonCardUI != null)
            {
                CardMouseOverPopup.Instance.SetPopUpContent(animonCardUI.GetCardDefinition());
            }
            CardMouseOverPopup.Instance.ShowPopUpOver(rectTransform);
        }
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        if (CardMouseOverPopup.Instance != null)
        {
            CardMouseOverPopup.Instance.HidePopUp();
        }
    }
}
