using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class InventoryManager : MonoBehaviour
{
    public static InventoryManager Instance { get; private set; }

    public int boosterPackCount = 0;

    [SerializeField]
    private InventoryPanel inventoryPanel;

    [SerializeField]
    private List<Item> items;

    [SerializeField]
    private List<ItemDefSO> itemDefs;

    [SerializeField]
    private IsoPlayerMovement isoPlayerMovement;

    [SerializeField]
    private BackpackImage backpackImage;

    public bool CanOpenInventoryPanel { get; set; } = true;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        items = new List<Item>();
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public void GiveItemWithId(ItemDefEnum itemDefEnum, int count = 1)
    {
        var itemDef = ItemIdToItemDef(itemDefEnum);
        items.Add(new Item(itemDef, count));
        backpackImage.GetComponent<EffectUtils2D>().Jiggle();
    }

    public void RemoveItem(string itemId, int count = 1)
    {
        Debug.Log($"Removing item with id '{itemId}' and count '{count}'");
        var item = items.Find(item => item.itemDef.Id == itemId);
        if (item == null)
        {
            Debug.Log($"Item with id '{itemId}' not found");
            throw new System.Exception($"Item with id '{itemId}' not found");
        }
        item.count -= count;
        if (item.count <= 0)
        {
            Debug.Log($"Removing item with id '{itemId}' completely");
            items.Remove(item);
        }
    }

    public void LogItems()
    {
        Debug.Log("Items: " + string.Join(", ", items));
    }

    public BackpackImage GetBackpackImage()
    {
        return backpackImage;
    }

    public ItemDefSO ItemIdToItemDef(ItemDefEnum itemDefEnum)
    {
        var itemId = ((int)itemDefEnum).ToString();
        var itemDef = itemDefs.Find(item => item.Id == itemId);
        if (itemDef == null)
        {
            throw new System.Exception($"ItemDef with id '{itemId}' not found");
        }
        return itemDef;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.I))
        {
            if (inventoryPanel.IsOpen)
            {
                _ = CloseInventoryPanel();
            }
            else
            {
                OpenInventoryPanel();
            }
        }
    }

    public void OpenInventoryPanel()
    {
        if (!CanOpenInventoryPanel)
            return;

        inventoryPanel.OpenInventoryPanel();
        inventoryPanel.UpdateWithItems(items);
        isoPlayerMovement.BlockPlayerActions();
    }

    public async Task CloseInventoryPanel()
    {
        isoPlayerMovement.UnblockPlayerActions();
        await inventoryPanel.CloseInventoryPanel();
    }
}
