using DG.Tweening;
using TMPro;
using UnityEngine;

public class CardMouseOverPopup : MonoBehaviour
{
    public static CardMouseOverPopup Instance { get; private set; }

    private CanvasGroup canvasGroup;

    [SerializeField]
    private TextMeshProUGUI nameText;

    [SerializeField]
    private TextMeshProUGUI priceText;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        canvasGroup = GetComponent<CanvasGroup>();
    }

    public void ShowPopUpOver(RectTransform target)
    {
        transform.position = target.position;
        transform.SetAsLastSibling();
        if (canvasGroup != null)
        {
            canvasGroup.alpha = 0f;
            canvasGroup.DOFade(1f, 0.1f);
        }
    }

    public void SetPopUpContent(CardDefinition cardDefinition)
    {
        if (cardDefinition == null)
            return;
        nameText.text = cardDefinition.name;
        priceText.text = cardDefinition.GetPrice();
    }

    public void ShowPopUpOver(RectTransform target, Vector2 offset)
    {
        if (target == null)
            return;
        transform.position = target.position + (Vector3)offset;
        transform.SetAsLastSibling();
        if (canvasGroup != null)
        {
            canvasGroup.alpha = 0f;
            canvasGroup.DOFade(1f, 0.1f);
        }
    }

    public void HidePopUp()
    {
        if (canvasGroup != null)
        {
            canvasGroup.DOFade(0f, 0.1f);
        }
    }
}
