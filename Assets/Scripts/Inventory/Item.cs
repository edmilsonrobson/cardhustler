using System.Threading.Tasks;
using UnityEngine;

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
        Debug.Log("OnInventoryUse: " + itemDef.displayName);
        await InventoryManager.Instance.CloseInventoryPanel();

        if (itemDef.kind == ItemKind.BoosterPack)
        {
            Debug.Log("OnInventoryUse: BoosterPack");
            PackOpeningManager.Instance.SetBoosterPackToOpen(count);
            PackOpeningManager.Instance.OnBoosterPackUse();
            InventoryManager.Instance.RemoveItem(this.itemDef.Id, this.count);
            Debug.Log("OnInventoryUse: BoosterPack removed");
        }
    }

    public override string ToString()
    {
        return $"x{count} {itemDef.displayName} (ID:{itemDef.Id})";
    }
}
