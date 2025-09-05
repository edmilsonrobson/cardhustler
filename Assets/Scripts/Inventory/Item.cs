public class Item
{
    public ItemDefSO itemDef;
    public int count;

    public Item(ItemDefSO itemDef, int count = 1)
    {
        this.itemDef = itemDef;
        this.count = count;
    }

    public void OnInventoryUse() {

    }
}
