using System.Threading.Tasks;

public class Item
{
    public ItemDefSO itemDef;
    public int count;

    public Item(ItemDefSO itemDef, int count = 1)
    {
        this.itemDef = itemDef;
        this.count = count;
    }

    public async Task OnInventoryUse()
    {
        await InventoryManager.Instance.CloseInventoryPanel();

        if (itemDef.kind == ItemKind.BoosterPack)
        {
            PackOpeningManager.Instance.OnBoosterPackUse(count);
            InventoryManager.Instance.RemoveItem(this.itemDef.Id, this.count);
        }
    }

    public override string ToString()
    {
        return $"x{count} {itemDef.displayName} (ID:{itemDef.Id})";
    }
}
