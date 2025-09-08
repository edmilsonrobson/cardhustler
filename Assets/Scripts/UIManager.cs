using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }

    [SerializeField]
    private ComputerMonitor computerMonitor;

    [SerializeField]
    private ActionBubblePanel actionBubblePanel;

    [SerializeField]
    public BoosterPackPanel boosterPackPanel;

    [SerializeField]
    private Canvas canvas;

    [SerializeField]
    private EscMenu escMenu;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            ToggleEscMenu();
        }
    }

    private void ToggleEscMenu()
    {
        if (escMenu.IsOpen)
        {
            escMenu.Close();
        }
        else
        {
            escMenu.Open();
        }
    }

    public void ToggleComputerMonitor()
    {
        var canvasGroup = computerMonitor.GetComponent<CanvasGroup>();
        if (canvasGroup.alpha > 0)
        {
            computerMonitor.CloseDesktopScreen();            
        }
        else
        {
            computerMonitor.OpenDesktopScreen();
        }
    }

    public void ShowActionBubble(Transform position, string text, string shortcut)
    {
        actionBubblePanel.ShowActionBubble(position, text, shortcut);
    }

    public void HideActionBubble()
    {
        actionBubblePanel.HideActionBubble();
    }

    public void ShowBoosterPackPanel(int count)
    {
        boosterPackPanel.ShowBoosterPackPanel();
        boosterPackPanel.SetBoosterPackCount(count);
    }

    public void SetBoosterPackCount(int count)
    {
        boosterPackPanel.ShowBoosterPackPanel();
        boosterPackPanel.SetBoosterPackCount(count);
    }

    public void HideBoosterPackPanel()
    {
        boosterPackPanel.HideBoosterPackPanel();
    }

    public ItemUIObject SpawnItemUIObject(
        ItemDefEnum itemDefEnum,
        ItemUIObject itemUIObject,
        Vector3 worldPosition
    )
    {
        Vector2 screenPoint = Camera.main.WorldToScreenPoint(worldPosition);
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            canvas.transform as RectTransform,
            screenPoint,
            canvas.worldCamera,
            out Vector2 localPoint
        );
        var item = InventoryManager.Instance.ItemIdToItemDef(itemDefEnum);
        itemUIObject.GetComponent<Image>().sprite = item.icon;
        var itemUIObjectInstance = Instantiate(itemUIObject, canvas.transform);
        (itemUIObjectInstance.transform as RectTransform).anchoredPosition = localPoint;
        return itemUIObjectInstance;
    }
}
