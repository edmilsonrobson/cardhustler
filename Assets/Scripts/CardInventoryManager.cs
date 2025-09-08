using System.Collections.Generic;
using UnityEngine;

public class CardInventoryManager : MonoBehaviour
{
    public static CardInventoryManager Instance { get; private set; }

    [SerializeField]
    private List<CardInstance> cards;

    [SerializeField]
    private CardInventoryPanel cardInventoryPanel;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
        DontDestroyOnLoad(gameObject);
        cards = new List<CardInstance>();
    }

    public void AddCardToCollection(CardInstance card)
    {
        cards.Add(card);
    }

    public void AddCardsToCollection(List<CardInstance> cards)
    {
        this.cards.AddRange(cards);
    }

    public void RemoveCardFromCollection(CardInstance card)
    {
        cards.Remove(card);
    }

    public List<CardInstance> GetCards()
    {
        return cards;
    }
}
