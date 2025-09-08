using System.Collections.Generic;

// This is just a "stacked" version of the same card instance.
// if I have 2 Goblin cards, I have 2 CardInstance objects, each pointing to the same CardInstance, right?
// but they become one single CardInstanceStack object with 2 stacks.
public class CardInstanceStack
{
    public List<CardInstance> cards;
    public int stackSize;

    public CardInstanceStack(List<CardInstance> cards, int stackSize)
    {
        this.cards = cards;
        this.stackSize = stackSize;
    }
}
