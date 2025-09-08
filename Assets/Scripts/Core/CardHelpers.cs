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
}
