using System.Collections.Generic;
using UnityEngine;

public class InventoryManager : MonoBehaviour
{
    public static InventoryManager Instance { get; private set; }

    public int boosterPackCount = 0;

    [SerializeField]
    private InventoryPanel inventoryPanel;

    private List<Item> items;

    [SerializeField]
    private List<ItemDefSO> itemDefs;

    [SerializeField]
    private IsoPlayerMovement isoPlayerMovement;

    [SerializeField]
    private BackpackImage backpackImage;

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

    public BackpackImage GetBackpackImage()
    {
        Debug.Log(backpackImage);
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
                CloseInventoryPanel();
            }
            else
            {
                OpenInventoryPanel();
            }
        }
    }

    public void OpenInventoryPanel()
    {
        inventoryPanel.OpenInventoryPanel();
        inventoryPanel.UpdateWithItems(items);
        isoPlayerMovement.BlockPlayerActions();
    }

    public void CloseInventoryPanel()
    {
        inventoryPanel.CloseInventoryPanel();
        isoPlayerMovement.UnblockPlayerActions();
    }

    public void AddBoosterPack(int count)
    {
        boosterPackCount += count;
        UIManager.Instance.ShowBoosterPackPanel(boosterPackCount);
    }

    public void RemoveBoosterPack(int count)
    {
        boosterPackCount -= count;
        UIManager.Instance.SetBoosterPackCount(boosterPackCount);
    }
}
