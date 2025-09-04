using System.Collections.Generic;

public class CardGenerator
{
    public CardSet set;

    public CardGenerator(CardSet set)
    {
        if (set.cardsDefs.Count != 0)
        {
            throw new System.Exception("Set has cards already");
        }

        this.set = set;
    }

    public CardSet PopulateSet()
    {
        var cardPool = GenerateCardPool();
        set.cardsDefs = cardPool;
        return set;
    }

    private CardDefinition GenerateCard(Rarity rarity, CardTribe tribe, CardElement element)
    {
        CardDefinition card = new CardDefinition();
        card.name = GenerateCardName();
        card.set = set;
        card.rarity = rarity;
        card.tribe = tribe;
        card.element = element;
        System.Random random = new System.Random();
        int rarityBonus = rarity switch
        {
            Rarity.Common => 0,
            Rarity.Rare => 2,
            Rarity.Epic => 4,
            Rarity.Legendary => 6,
            Rarity.Mythic => 8,
            _ => 0,
        };
        card.cost = random.Next(0, 10) + random.Next(0, rarityBonus + 1);
        card.attack = random.Next(0, 10) + random.Next(0, rarityBonus + 1);
        card.health = random.Next(0, 10) + random.Next(0, rarityBonus + 1);

        return card;
    }

    public List<CardDefinition> GenerateCardPool(int count = 60)
    {
        var rarityProportion = new Dictionary<Rarity, int>();
        rarityProportion[Rarity.Common] = 50;
        rarityProportion[Rarity.Rare] = 35;
        rarityProportion[Rarity.Epic] = 10;
        rarityProportion[Rarity.Legendary] = 5;

        var cardPool = new List<CardDefinition>();

        var commonsToGenerate = (int)(count * 0.6);
        var raresToGenerate = (int)(count * 0.3);
        var epicsToGenerate = (int)(count * 0.1);
        var legendsToGenerate = (int)(count * 0.05);

        for (int i = 0; i < commonsToGenerate; i++)
        {
            var tribe = GenerateCardTribe();
            var element = GenerateCardElement();
            cardPool.Add(GenerateCard(Rarity.Common, tribe, element));
        }
        for (int i = 0; i < raresToGenerate; i++)
        {
            var tribe = GenerateCardTribe();
            var element = GenerateCardElement();
            cardPool.Add(GenerateCard(Rarity.Rare, tribe, element));
        }
        for (int i = 0; i < epicsToGenerate; i++)
        {
            var tribe = GenerateCardTribe();
            var element = GenerateCardElement();
            cardPool.Add(GenerateCard(Rarity.Epic, tribe, element));
        }

        for (int i = 0; i < legendsToGenerate; i++)
        {
            var tribe = GenerateCardTribe();
            var element = GenerateCardElement();
            cardPool.Add(GenerateCard(Rarity.Legendary, tribe, element));
        }

        return cardPool;
    }

    private CardTribe GenerateCardTribe()
    {
        var values = System.Enum.GetValues(typeof(CardTribe));
        return (CardTribe)values.GetValue(new System.Random().Next(values.Length));
    }

    private CardElement GenerateCardElement()
    {
        var values = System.Enum.GetValues(typeof(CardElement));
        return (CardElement)values.GetValue(new System.Random().Next(values.Length));
    }

    private string GenerateCardName()
    {
        return CardNameGenerator.GenerateCardName(CardElement.Fire);
    }
}
