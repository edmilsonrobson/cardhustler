using System.Collections.Generic;
using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PackOpeningManager : MonoBehaviour
{
    public static PackOpeningManager Instance { get; private set; }
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

    [SerializeField]
    private Camera UICamera;

    [SerializeField]
    private Button nextPackOrCloseButton;

    [SerializeField]
    private TextMeshProUGUI cardPriceText;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        cardGenerator = new CardGenerator(new CardSet("Base Set", "BASE", CardSetType.Core));
        cardGenerator.PopulateSet();
    }

    void Update() { }

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
        seq.Join(cardPriceText.GetComponent<CanvasGroup>().DOFade(0, 0.1f).SetEase(Ease.OutSine));
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
            nextPackOrCloseButton.GetComponentInChildren<TextMeshProUGUI>().text = "Close";
        }
        else
        {
            nextPackOrCloseButton.GetComponentInChildren<TextMeshProUGUI>().text =
                $"Next Pack ({boosterPackToOpen} left)";
        }
        nextPackOrCloseButton.GetComponent<CanvasGroup>().DOFade(1, 0.3f);
        InventoryManager.Instance.CanOpenInventoryPanel = true;
    }

    public void OnNextPackOrCloseButtonClick()
    {
        if (boosterPackToOpen == 0)
        {
            nextPackOrCloseButton
                .GetComponent<CanvasGroup>()
                .DOFade(0, 0.3f)
                .OnComplete(() => packOpeningPanel.gameObject.SetActive(false));
            IsoPlayerMovement.Instance.UnblockPlayerActions();
        }
        else
        {
            OnBoosterPackUse();
            nextPackOrCloseButton.GetComponent<CanvasGroup>().DOFade(0, 0.3f);
        }
    }

    public void RevealNextCard()
    {
        var topmostCard = cardUIs[cardUIs.Count - 1];
        bool isRareOrBetter = false;
        if (topmostCard.GetCardDefinition() != null)
        {
            var rarity = topmostCard.GetCardDefinition().rarity;
            if (rarity == Rarity.Rare || rarity == Rarity.Epic || rarity == Rarity.Legendary)
            {
                isRareOrBetter = true;
            }
        }

        topmostCard.ShowNonBackgroundContent();

        cardPriceText.text = topmostCard.GetCardDefinition().getRandomPrice();
        if (isRareOrBetter)
        {
            ParticleManager.instance.PlayMagicAuraParticle(
                topmostCard.transform.position,
                packOpeningPanel
            );
            // CameraShakeManager.instance.MediumShake();
            var zoomEffect = 60f;
            var camTransform = UICamera.transform;
            var originalPos = camTransform.position;
            var zoomedPos = new Vector3(originalPos.x, originalPos.y, originalPos.z + zoomEffect);

            camTransform.position = zoomedPos;
            topmostCard
                .transform.DORotate(new Vector3(0, 0, 0), 0.3f)
                .SetEase(Ease.OutQuad)
                .OnComplete(() =>
                {
                    camTransform
                        .DOMoveZ(originalPos.z, 0.5f)
                        .SetEase(Ease.OutCubic)
                        .OnComplete(() =>
                        {
                            canClickToReveal = true;
                            cardPriceText.GetComponent<CanvasGroup>().DOFade(1, 0.1f);
                        });
                });
        }
        else
        {
            topmostCard
                .transform.DORotate(new Vector3(0, 0, 0), 0.3f)
                .SetEase(Ease.OutQuad)
                .OnComplete(() =>
                {
                    canClickToReveal = true;
                    cardPriceText.GetComponent<CanvasGroup>().DOFade(1, 0.1f);
                });
        }
    }

    public void OnBoosterPackUse(int quantity = 1)
    {
        InventoryManager.Instance.CanOpenInventoryPanel = false;
        this.boosterPackToOpen = quantity;
        packOpeningPanel.gameObject.SetActive(true);
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
            cardUI.SetCardDefinition(card);
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
