using UnityEngine;

// CardInstance represents an instance of a CardDefinition that you own in the game.
// It's not stackable.
// e.g if I own two Goblins, I have two CardInstance objects, each pointing to the same CardDef.
public class CardInstance
{
    public CardDefinition cardDef;

    public CardInstance(CardDefinition cardDef)
    {
        this.cardDef = cardDef;
    }
}
