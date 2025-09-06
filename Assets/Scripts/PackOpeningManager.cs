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

    private bool canClickToReveal = false;
    private bool revealedFirstCard = false;

    private int boosterPackToOpen = 0;

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
        Debug.Log("Clickity click!");
        Debug.Log("Can click to reveal: " + canClickToReveal);
        Debug.Log("Revealed first card: " + revealedFirstCard);
        if (!canClickToReveal)
            return;

        if (!revealedFirstCard)
        {
            RevealNextCard();
            revealedFirstCard = true;
            canClickToReveal = false;
            return;
        }

        // flip the current card away before revealing the next card
        var currentCard = cardUIs[cardUIs.Count - 1];
        var seq = DOTween.Sequence();
        seq.Append(
            currentCard
                .transform.DOLocalMoveX(currentCard.transform.localPosition.x + 150f, 0.25f)
                .SetEase(Ease.OutSine)
        );
        seq.Join(
            currentCard.transform.DORotate(new Vector3(0, 0, -25f), 0.25f).SetEase(Ease.OutSine)
        );
        seq.Join(currentCard.GetCanvasGroup().DOFade(0, 0.25f).SetEase(Ease.OutSine));
        seq.OnComplete(() =>
        {
            cardUIs.Remove(currentCard);
            if (cardUIs.Count != 0)
            {
                RevealNextCard();
            }
            else
            {
                EndBoosterPackOpening();
            }
        });
        seq.Play();
    }

    public void EndBoosterPackOpening()
    {
        boosterPackToOpen--;

        if (boosterPackToOpen == 0)
        {
            IsoPlayerMovement.Instance.UnblockPlayerActions();
        }
    }

    public void RevealNextCard()
    {
        // use dotween for a nice flip animation
        var topmostCard = cardUIs[cardUIs.Count - 1];
        topmostCard.ShowNonBackgroundContent();
        topmostCard
            .transform.DORotate(new Vector3(0, 0, 0), 0.3f)
            .SetEase(Ease.OutQuad)
            .OnComplete(() =>
            {
                canClickToReveal = true;
            });
    }

    public void OnBoosterPackUse()
    {
        boosterPackToOpen = 1;
        IsoPlayerMovement.Instance.BlockPlayerActions();
        revealedFirstCard = false;
        canClickToReveal = false;
        cardUIs = new List<AnimonCardUI>();
        var boosterPack = new BoosterPack(cardGenerator.set);
        var cards = boosterPack.CrackOpen();
        foreach (var card in cards)
        {
            var cardUI = Instantiate(animonCardUI, packOpeningPanel.transform);
            cardUI.GetCanvasGroup().alpha = 0;

            var rect = cardUI.GetComponent<RectTransform>();
            rect.localPosition = Vector3.zero;
            rect.localScale = new Vector3(0.25f, 0.25f, 0.25f);
            rect.eulerAngles = new Vector3(0, 180, 0);
            rect.anchoredPosition = Vector2.zero;

            cardUI.SetMainSprite(card.image);
            cardUI.SetNameText(card.name.ToUpper());
            cardUI.SetAtkText(card.attack.ToString());
            cardUI.SetDefText(card.health.ToString());
            cardUI.SetRarityText(card.rarity.ToString().ToUpper());
            cardUI.SetCreatureTypeAndElementTypeText(
                card.tribe.ToString() + " " + card.element.ToString()
            );
            cardUI.HideNonBackgroundContent();
            cardUIs.Insert(0, cardUI);
        }

        SetBoosterPackOpenFocus();
    }

    private void SetBoosterPackOpenFocus()
    {
        float startYOffset = 200f;
        float fadeDuration = 0.10f;
        float stagger = 0.10f;
        float stackYOffset = -5f;

        int lastIndex = cardUIs.Count - 1;

        int completed = 0;
        for (int i = 0; i < cardUIs.Count; i++)
        {
            var cardUI = cardUIs[i];
            var rect = cardUI.GetComponent<RectTransform>();
            float delay = stagger * i;

            rect.SetAsLastSibling();
            rect.anchoredPosition = new Vector2(0, startYOffset + i * stackYOffset);
            cardUI.GetCanvasGroup().alpha = 0f;

            rect.DOAnchorPos(new Vector2(0, i * stackYOffset), fadeDuration)
                .SetDelay(delay)
                .SetEase(Ease.OutQuad);
            var fadeTween = cardUI
                .GetCanvasGroup()
                .DOFade(1f, fadeDuration)
                .SetDelay(delay)
                .SetEase(Ease.OutQuad);

            fadeTween.OnComplete(() =>
            {
                completed++;
                if (completed == cardUIs.Count)
                {
                    float gatherDuration = 0.4f;
                    int gatherCompleted = 0;
                    for (int j = 0; j < cardUIs.Count; j++)
                    {
                        var gatherRect = cardUIs[j].GetComponent<RectTransform>();
                        gatherRect
                            .DOAnchorPos(Vector2.zero, gatherDuration)
                            .SetEase(Ease.InOutQuad)
                            .OnComplete(() =>
                            {
                                gatherCompleted++;
                                if (gatherCompleted == cardUIs.Count)
                                {
                                    canClickToReveal = true;
                                }
                            });
                    }
                }
            });
        }
    }
}
