using System.Collections.Generic;
using UnityEngine;

public class CardDefinition
{
    public string name;
    public Sprite image;
    public Rarity rarity;
    public CardSet set;

    public CardTribe tribe;
    public CardElement element;

    public int cost;
    public int attack;
    public int health;

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

    public string getRandomPrice()
    {
        float basePrice = 0f;
        switch (rarity)
        {
            case Rarity.Common:
                basePrice = 1f;
                break;
            case Rarity.Rare:
                basePrice = 3f;
                break;
            case Rarity.Epic:
                basePrice = 20f;
                break;
            case Rarity.Legendary:
                basePrice = 100f;
                break;
        }
        float variance = Random.Range(-0.1f, 0.1f);
        float finalPrice = basePrice + basePrice * variance;
        return "$" + finalPrice.ToString("F2");
    }
}
