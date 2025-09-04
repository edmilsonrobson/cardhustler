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
}
