using System.Collections.Generic;

public class BoosterPack
{
    public CardSet set;

    public BoosterPack(CardSet set)
    {
        this.set = set;
    }

    // funny name for a "generate cards from booster pack" method
    public List<CardDefinition> CrackOpen()
    {
        var cards = new List<CardDefinition>(5);
        for (int i = 0; i < 4; i++)
        {
            cards.Add(set.GetRandomCardByRarity(Rarity.Common));
        }

        int roll = UnityEngine.Random.Range(0, 100);
        if (roll < 5)
        {
            cards.Add(set.GetRandomCardByRarity(Rarity.Legendary));
        }
        else if (roll < 25)
        {
            cards.Add(set.GetRandomCardByRarity(Rarity.Epic));
        }
        else
        {
            cards.Add(set.GetRandomCardByRarity(Rarity.Rare));
        }

        return cards;
    }
}
