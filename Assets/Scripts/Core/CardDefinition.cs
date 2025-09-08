using System.Collections.Generic;
using UnityEngine;

public class CardDefinition
{
    public string id; // e.g BASE-001
    public string name;
    public Sprite image;
    public Rarity rarity;
    public CardSet set;

    public CardTribe tribe;
    public CardElement element;

    public int cost;
    public int attack;
    public int health;

    public List<MarketForceType> marketForces = new List<MarketForceType>();
    public float basePrice;

    public string ToShortString()
    {
        var rarityToChar = new Dictionary<Rarity, string>
        {
            { Rarity.Common, "C" },
            { Rarity.Rare, "R" },
            { Rarity.Epic, "E" },
            { Rarity.Legendary, "L" },
        };
        return $"[{set.code} [{rarityToChar[rarity]}] {cost} {name} - {tribe} {element} - {attack}/{health}";
    }

    public List<string> GetMarketForceDescriptions()
    {
        var descriptions = new List<string>();
        foreach (var marketForce in marketForces)
        {
            descriptions.Add(MarketForceHelper.Descriptions[marketForce]);
        }
        return descriptions;
    }

    public string GetPrice()
    {
        float marketForceMultiplier = 1f;
        foreach (var marketForce in marketForces)
        {
            marketForceMultiplier += 1 + MarketForceHelper.Values[marketForce] / 100f;
        }

        float finalPrice = basePrice * marketForceMultiplier;
        return "$" + finalPrice.ToString("F2");
    }
}
