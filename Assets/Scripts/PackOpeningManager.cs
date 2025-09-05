using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class PackOpeningManager : MonoBehaviour
{
    public AnimonCardUI animonCardUI;

    private CardGenerator cardGenerator;

    [SerializeField]
    private List<AnimonCardUI> cardUIs;

    [SerializeField]
    private Canvas cardOpeningCanvas;

    [SerializeField]
    private GameObject packOpeningPanel;

    void Awake()
    {
        cardGenerator = new CardGenerator(new CardSet("Base Set", "BASE", CardSetType.Core));
        cardGenerator.PopulateSet();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            OnBoosterPackUse();
        }
    }

    public void OnCardPackOpeningPanelClick()
    {
        Debug.Log("Clicked!");
        FlipTopmostCard();
    }

    public void FlipTopmostCard()
    {
        // use dotween for a nice flip animation
        var topmostCard = cardUIs[cardUIs.Count - 1];
        topmostCard.ShowNonBackgroundContent();
        topmostCard.transform.DORotate(new Vector3(0, 0, 0), 0.5f).SetEase(Ease.OutQuad);
    }

    public void OnBoosterPackUse()
    {
        cardUIs = new List<AnimonCardUI>();
        var boosterPack = new BoosterPack(cardGenerator.set);
        var cards = boosterPack.CrackOpen();
        foreach (var card in cards)
        {
            var cardUI = Instantiate(animonCardUI, cardOpeningCanvas.transform);
            cardUI.GetCanvasGroup().alpha = 0;

            var rect = cardUI.GetComponent<RectTransform>();
            rect.localPosition = Vector3.zero;
            rect.localScale = new Vector3(0.25f, 0.25f, 0.25f);
            rect.eulerAngles = new Vector3(0, 180, 0);
            rect.anchoredPosition = Vector2.zero;

            cardUI.SetMainSprite(card.image);
            cardUI.SetNameText(card.name);
            cardUI.SetAtkText(card.attack.ToString());
            cardUI.SetDefText(card.health.ToString());
            cardUI.HideNonBackgroundContent();
            cardUIs.Add(cardUI);
        }

        SetBoosterPackOpenFocus();
    }

    private void SetBoosterPackOpenFocus()
    {
        float yOffsetStep = -5f;
        float fadeDuration = 0.25f;
        float stagger = 0.15f;

        for (int i = 0; i < cardUIs.Count; i++)
        {
            var cardUI = cardUIs[i];
            var rect = cardUI.GetComponent<RectTransform>();
            float targetY = i == 0 ? 0f : yOffsetStep * i;
            float delay = stagger * i;

            rect.SetAsLastSibling();

            rect.DOAnchorPos(new Vector2(0, targetY), fadeDuration)
                .SetDelay(delay)
                .SetEase(Ease.OutQuad);
            cardUI.GetCanvasGroup().DOFade(1f, fadeDuration).SetDelay(delay);
        }
    }
}
