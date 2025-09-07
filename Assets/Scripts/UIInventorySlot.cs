using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIInventorySlot : MonoBehaviour
{
    private Item item;

    [SerializeField]
    private Image itemImage;

    [SerializeField]
    private TextMeshProUGUI itemCountText;

    [SerializeField]
    private GameObject tooltipObject;

    [SerializeField]
    private RectTransform TooltipPosition;

    private void Awake()
    {
        itemImage.enabled = false;
    }

    public void SetItem(Item item)
    {
        this.item = item;
        itemImage.sprite = item.itemDef.icon;
        itemImage.enabled = true;
        itemCountText.text = item.count.ToString();
    }

    public void RemoveItem()
    {
        itemImage.enabled = false;
        itemImage.sprite = null;
        item = null;
        itemCountText.text = "";
    }

    public void OnPointerClick()
    {
        Debug.Log($"Clicked on item: {item.itemDef.displayName}");
        _ = item.OnInventoryUse();
    }

    public void OnPointerEnter()
    {
        ShowTooltip();
    }

    public void OnPoiterLeave()
    {
        HideTooltip();
    }

    public void ShowTooltip()
    {
        if (item == null)
            return;

        var canvasGroup = tooltipObject.GetComponent<CanvasGroup>();
        canvasGroup.DOFade(1, 0.12f);
        tooltipObject.GetComponent<RectTransform>().position = TooltipPosition.position;
    }

    public void HideTooltip()
    {
        tooltipObject.GetComponent<CanvasGroup>().DOFade(0, 0.12f);
    }
}
