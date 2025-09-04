using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class InventoryPanel : MonoBehaviour
{
    private CanvasGroup canvasGroup;

    public bool IsOpen { get; private set; } = false;

    [SerializeField]
    private RectTransform inventorySlotsPanel;
    private List<UIInventorySlot> inventorySlots;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 0;

        // grab all children of slots panel
        inventorySlots = new List<UIInventorySlot>(
            inventorySlotsPanel.GetComponentsInChildren<UIInventorySlot>()
        );
    }

    public void UpdateWithItems(List<Item> items)
    {
        if (items.Count > inventorySlots.Count)
        {
            Debug.LogError("Not enough inventory slots");
            return;
        }

        for (int i = 0; i < items.Count; i++)
        {
            inventorySlots[i].SetItem(items[i]);
        }
    }

    public void OpenInventoryPanel()
    {
        // reset state
        transform.localScale = Vector3.one * 0.95f; // start slightly smaller
        canvasGroup.alpha = 0;

        // fade + scale sequence
        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOScale(1.05f, 0.15f).SetEase(Ease.OutQuad)); // subtle overshoot
        seq.Append(transform.DOScale(1f, 0.1f).SetEase(Ease.OutBack)); // settle

        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;
        IsOpen = true;
    }

    public void CloseInventoryPanel()
    {
        // fade + shrink
        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOScale(0.95f, 0.12f).SetEase(Ease.InQuad)); // shrink slightly
        seq.Join(canvasGroup.DOFade(0, 0.12f).SetEase(Ease.InQuad));

        seq.OnComplete(() =>
        {
            canvasGroup.blocksRaycasts = false;
            canvasGroup.interactable = false;
            IsOpen = false;
        });
    }
}
