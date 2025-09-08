using System;
using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class AnimonCardUI : MonoBehaviour, IPointerDownHandler
{
    public Image mainImage;
    public Image backgroundImage;
    public TextMeshProUGUI nameText;
    public TextMeshProUGUI atkText;
    public TextMeshProUGUI defText;

    public TextMeshProUGUI rarityText;
    public TextMeshProUGUI creatureTypeAndElementText;

    private CardDefinition cardDefinition;

    private CanvasGroup canvasGroup;

    [SerializeField]
    private Image backImage;

    public event Action<AnimonCardUI> OnCardPointerDown;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
    }

    void Update()
    {
        float yRot = transform.localEulerAngles.y;

        if (yRot > 90f && yRot < 270f)
        {
            backImage.gameObject.SetActive(true);
        }
        else
        {
            backImage.gameObject.SetActive(false);
        }
    }

    public void SetCardInformation(CardInstance cardInstance)
    {
        SetCardDefinition(cardInstance.cardDef);
        SetMainSprite(cardInstance.cardDef.image);
        SetNameText(cardInstance.cardDef.name);
        SetAtkText(cardInstance.cardDef.attack.ToString());
        SetDefText(cardInstance.cardDef.health.ToString());
        SetRarityText(cardInstance.cardDef.rarity.ToString());
        SetCreatureTypeAndElementTypeText(
            cardInstance.cardDef.tribe.ToString() + " " + cardInstance.cardDef.element.ToString()
        );
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        OnCardPointerDown?.Invoke(this);
    }

    public void SetMainSprite(Sprite sprite)
    {
        mainImage.sprite = sprite;
    }

    public CanvasGroup GetCanvasGroup()
    {
        return canvasGroup;
    }

    public void SetCardDefinition(CardDefinition cardDefinition)
    {
        this.cardDefinition = cardDefinition;
    }

    public CardDefinition GetCardDefinition()
    {
        return cardDefinition;
    }

    public void SetBackgroundSprite(Sprite sprite)
    {
        backgroundImage.sprite = sprite;
    }

    public void SetNameText(string text)
    {
        nameText.text = text;
    }

    public void SetAtkText(string text)
    {
        atkText.text = text;
    }

    public void SetDefText(string text)
    {
        defText.text = text;
    }

    public void SetRarityText(string text)
    {
        rarityText.text = text;
    }

    public void SetCreatureTypeAndElementTypeText(string text)
    {
        creatureTypeAndElementText.text = text;
    }

    public void HideNonBackgroundContent()
    {
        foreach (Transform child in transform)
        {
            if (child.name != "Back")
            {
                child.gameObject.SetActive(false);
            }
        }
    }

    public void ShowNonBackgroundContent()
    {
        foreach (Transform child in transform)
        {
            if (child.name != "Back")
            {
                child.gameObject.SetActive(true);
            }
        }
    }
}
