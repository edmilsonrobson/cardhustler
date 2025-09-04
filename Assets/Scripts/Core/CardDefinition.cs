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
}
