using System.Collections.Generic;
using System.Globalization;
using UnityEngine;

public class CardDefinition
{
    public string id; // e.g BASE-001
    public string name;
    public string imageKey;
    public Rarity rarity;
    public string setCode;

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
        return $"[{setCode} [{rarityToChar[rarity]}] {cost} {name} - {tribe} {element} - {attack}/{health}";
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

    public string GetPriceString()
    {
        var finalPrice = GetPrice();
        return "$" + finalPrice.ToString("F2", CultureInfo.InvariantCulture);
    }

    public float GetPrice()
    {
        float marketForceMultiplier = 1f;
        foreach (var marketForce in marketForces)
        {
            marketForceMultiplier += 1 + MarketForceHelper.Values[marketForce] / 100f;
        }
        return basePrice * marketForceMultiplier;
    }
}
