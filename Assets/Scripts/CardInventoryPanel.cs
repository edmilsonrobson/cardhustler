using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CardInventoryPanel : MonoBehaviour
{
    private List<CardInstanceStack> cards;

    [SerializeField]
    private List<RectTransform> cardHolders;

    private int page = 1;

    public bool IsOpen { get; private set; } = false;

    private EffectUtils2D effectUtils2D;

    [SerializeField]
    private Button previousButton;

    [SerializeField]
    private Button nextButton;

    void Awake()
    {
        cards = new List<CardInstanceStack>();
        effectUtils2D = GetComponent<EffectUtils2D>();

        previousButton.onClick.AddListener(PreviousPage);
        nextButton.onClick.AddListener(NextPage);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.B))
        {
            if (IsOpen)
            {
                CloseCardInventoryPanel();
            }
            else
            {
                OpenCardInventoryPanel();
            }
        }
}

    public void OpenCardInventoryPanel()
    {
        IsOpen = true;
        SetCards(CardInventoryManager.Instance.GetCards());
        ValidatePaginationButtons();
        effectUtils2D.MenuIn();

        Debug.Log("Collection size: " + CardInventoryManager.Instance.GetCards().Count);
        Debug.Log("Cards: " + string.Join(", ", CardInventoryManager.Instance.GetCards()));
    }

    public void CloseCardInventoryPanel()
    {
        IsOpen = false;
        effectUtils2D.MenuOut();
    }

    public void SetCards(List<CardInstance> cards)
    {
        this.cards = CardHelpers.GroupCards(cards);

        InitializeBinder();
    }

    private void InitializeBinder()
    {
        this.page = 1;
        SetCardsByPage(page);
    }

    private void SetCardsByPage(int page)
    {
        Debug.Log("Setting cards by page: " + page);
        int startIndex = (page - 1) * cardHolders.Count;
        for (int i = 0; i < cardHolders.Count; i++)
        {
            int cardIndex = startIndex + i;
            var animonCardUI = cardHolders[i].GetComponentInChildren<AnimonCardUI>();
            if (cardIndex < cards.Count)
            {
                animonCardUI.SetCardInformation(cards[cardIndex].cards[0]);
                animonCardUI.GetComponent<CanvasGroup>().alpha = 1;
            }
            else
            {
                Debug.Log("Setting card holder to false: " + i);
                animonCardUI.GetComponent<CanvasGroup>().alpha = 0;
            }
        }
    }

    public void ValidatePaginationButtons()
    {
        var hasPrev = page > 1;
        var totalPages = Mathf.CeilToInt((float)cards.Count / cardHolders.Count);
        var hasNext = page < totalPages;

        if (previousButton != null)
            previousButton.interactable = hasPrev;
        if (nextButton != null)
            nextButton.interactable = hasNext;
    }

    public void NextPage()
    {
        var totalPages = Mathf.CeilToInt((float)cards.Count / cardHolders.Count);
        if (page < totalPages)
        {
            page++;
            SetCardsByPage(page);
            ValidatePaginationButtons();
        }
    }

    public void PreviousPage()
    {
        if (page > 1)
        {
            page--;
            SetCardsByPage(page);
            ValidatePaginationButtons();
        }
    }
}
