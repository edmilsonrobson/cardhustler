using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class DevTools
{
    [MenuItem("DevTools/Run My Function")]
    public static void RunMyFunction()
    {
        Debug.Log("Function ran!");

        var cardGenerator = new CardGenerator(new CardSet("Base Set", "BASE", CardSetType.Core));
        var cardSet = cardGenerator.PopulateSet();

        var imaginaryCollection = new List<CardInstance>();

        var card1 = new CardInstance(cardSet.cardsDefs[0]);
        var card2 = new CardInstance(cardSet.cardsDefs[1]);
        var card3 = new CardInstance(cardSet.cardsDefs[0]);
        var card4 = new CardInstance(cardSet.cardsDefs[0]);
        var card5 = new CardInstance(cardSet.cardsDefs[1]);
        var card6 = new CardInstance(cardSet.cardsDefs[2]);

        imaginaryCollection.Add(card1);
        imaginaryCollection.Add(card2);
        imaginaryCollection.Add(card3);
        imaginaryCollection.Add(card4);
        imaginaryCollection.Add(card5);
        imaginaryCollection.Add(card6);

        var groupedCards = CardHelpers.GroupCards(imaginaryCollection);
        Debug.Log("Grouped cards: " + groupedCards.Count);
        foreach (var stack in groupedCards)
        {
            Debug.Log("Stack: " + stack.cards.Count + " " + stack.cards[0].cardDef.name);
        }
    }
}
