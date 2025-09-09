using System.Collections.Generic;

public static class CardHelpers
{
    public static List<CardInstanceStack> GroupCards(List<CardInstance> cardInstances)
    {
        if (cardInstances == null || cardInstances.Count == 0)
            return new List<CardInstanceStack>();
        var grouped = new Dictionary<string, List<CardInstance>>();
        foreach (var card in cardInstances)
        {
            if (card.cardDef == null || string.IsNullOrEmpty(card.cardDef.id))
                continue;
            if (!grouped.ContainsKey(card.cardDef.id))
            {
                grouped[card.cardDef.id] = new List<CardInstance>();
            }
            grouped[card.cardDef.id].Add(card);
        }

        var stacks = new List<CardInstanceStack>();
        foreach (var pair in grouped)
        {
            stacks.Add(new CardInstanceStack(pair.Value, pair.Value.Count));
        }
        return stacks;
    }

    public static List<CardDefinition> SortByRarity(List<CardDefinition> cardDefs)
    {
        if (cardDefs == null)
            return new List<CardDefinition>();
        var rarityOrder = new Dictionary<Rarity, int>
        {
            { Rarity.Legendary, 0 },
            { Rarity.Epic, 1 },
            { Rarity.Rare, 2 },
            { Rarity.Common, 3 },
        };
        cardDefs.Sort(
            (a, b) =>
            {
                int orderA = rarityOrder.ContainsKey(a.rarity)
                    ? rarityOrder[a.rarity]
                    : int.MaxValue;
                int orderB = rarityOrder.ContainsKey(b.rarity)
                    ? rarityOrder[b.rarity]
                    : int.MaxValue;
                return orderA.CompareTo(orderB);
            }
        );
        return cardDefs;
    }
}
