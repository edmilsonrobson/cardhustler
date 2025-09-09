using System.Collections.Generic;
using UnityEngine;

public class CardBayScreen : MonoBehaviour
{
    [Header("Sub-screens")]
    [SerializeField]
    private GameObject HomeSubscreen;

    [SerializeField]
    private GameObject CardsFromSetSubscreen;

    [SerializeField]
    private GameObject CardDetailsSubscreen;

    [Header("Prefabs")]
    [SerializeField]
    private GameObject AnimonCardbayHolderPrefab;

    [Header("Content Panels")]
    [SerializeField]
    private RectTransform allCardsFromSetContentPanel;

    public void GoBack()
    {
        GetComponentInParent<ComputerMonitor>().CloseCardBay();
    }

    public void GoToHomeSubscreen()
    {
        UISoundManager.instance.PlayClickSound();
        HomeSubscreen.SetActive(true);
        CardsFromSetSubscreen.SetActive(false);
        CardDetailsSubscreen.SetActive(false);
    }

    public void GoToCardsFromSetSubscreen()
    {
        CursorManager.Instance.ResetCursor();
        UISoundManager.instance.PlayClickSound();
        HomeSubscreen.SetActive(false);
        CardsFromSetSubscreen.SetActive(true);
        CardDetailsSubscreen.SetActive(false);

        var cardDefs = CardsInMarketManager.Instance.GetSetByCode("BASE").cardsDefs;
        cardDefs = CardHelpers.SortByRarity(cardDefs);
        AddCardsToAllCardsFromSetContentPanel(cardDefs);
    }

    public void GoToCardDetailsSubscreen()
    {
        CursorManager.Instance.ResetCursor();
        UISoundManager.instance.PlayClickSound();
        HomeSubscreen.SetActive(false);
        CardsFromSetSubscreen.SetActive(false);
        CardDetailsSubscreen.SetActive(true);
    }

    public void RemoveCardsFromAllCardsFromSetContentPanel()
    {
        foreach (Transform child in allCardsFromSetContentPanel)
        {
            Destroy(child.gameObject);
        }
    }

    public void AddCardsToAllCardsFromSetContentPanel(List<CardDefinition> cards)
    {
        foreach (var card in cards)
        {
            var cardHolder = Instantiate(AnimonCardbayHolderPrefab, allCardsFromSetContentPanel);
            cardHolder.GetComponent<AnimonCardBayHolder>().SetPriceText(card.GetPriceString());
            cardHolder
                .GetComponent<AnimonCardBayHolder>()
                .SetOwnedCountText(CardInventoryManager.Instance.GetCardCount(card));
            cardHolder
                .GetComponentInChildren<AnimonCardUI>()
                .SetCardInformation(new CardInstance(card));
        }
    }

    public void OnOwnedOnlyToggle(bool isOn)
    {
        if (isOn)
        {
            foreach (Transform child in allCardsFromSetContentPanel)
            {
                var cardUI = child.GetComponentInChildren<AnimonCardUI>();
                if (cardUI != null)
                {
                    var cardInstance = cardUI.GetCardInstance();
                    int count = CardInventoryManager.Instance.GetCardCount(cardInstance.cardDef);
                    child.gameObject.SetActive(count > 0);
                }
            }
        }
        else
        {
            foreach (Transform child in allCardsFromSetContentPanel)
            {
                child.gameObject.SetActive(true);
            }
        }
    }
}
