using System.Collections.Generic;
using System.Text;
using Unity.VisualScripting;
using UnityEngine;

public class CardSet
{
    public string name;
    public string code;
    public Sprite image;
    public CardSetType type;
    public List<CardDefinition> cardsDefs;

    public CardSet() { }

    public CardSet(string name, string code, CardSetType type)
    {
        this.name = name;
        this.code = code;
        this.type = type;
        this.cardsDefs = new List<CardDefinition>();
    }

    public string ToFullSetString()
    {
        var sb = new StringBuilder();
        sb.AppendLine("CARDS FOR SET " + name);
        foreach (var card in cardsDefs)
        {
            sb.AppendLine(card.ToShortString());
        }
        return sb.ToString();
    }

    public CardDefinition GetRandomCard()
    {
        if (cardsDefs == null || cardsDefs.Count == 0)
            return null;
        return cardsDefs[Random.Range(0, cardsDefs.Count)];
    }

    public CardDefinition GetRandomCardByRarity(Rarity rarity)
    {
        if (cardsDefs == null || cardsDefs.Count == 0)
            return null;
        var pool = new List<CardDefinition>();
        foreach (var card in cardsDefs)
        {
            if (card.rarity == rarity)
                pool.Add(card);
        }
        if (pool.Count == 0)
            return GetRandomCard();
        return pool[Random.Range(0, pool.Count)];
    }
}
