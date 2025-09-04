using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class ShippingBoxInteractable : Interactable
{
    public int boosterPackCount = 3;

    [SerializeField]
    private IsoPlayerMovement isoPlayerMovement;

    [SerializeField]
    private ItemUIObject itemUIObject;

    public override void Interact(Transform interactor)
    {
        Debug.Log("Interacted with Shipping Box");
        //isoPlayerMovement.BlockPlayerActions();

        var boosterPackPanel = UIManager.Instance.boosterPackPanel;

        int times = boosterPackCount;
        var boosterPackObjects = new List<ItemUIObject>();
        InventoryManager.Instance.GiveItemWithId(ItemDefEnum.BoosterPack, 3);
        for (int i = 0; i < times; i++)
        {
            boosterPackObjects.Add(
                UIManager.Instance.SpawnItemUIObject(
                    ItemDefEnum.BoosterPack,
                    itemUIObject,
                    this.transform.position
                )
            );
        }

        var seq = DOTween.Sequence();

        for (int i = 0; i < boosterPackObjects.Count; i++)
        {
            var itemUIObjectInstance = boosterPackObjects[i];
            seq.AppendCallback(() =>
            {
                // move the ui element to be the topmost
                itemUIObjectInstance.transform.SetAsLastSibling();
                itemUIObjectInstance.PopAnimation();
            });
            seq.Append(this.transform.DOPunchScale(Vector3.one * 0.1f, 0.2f).SetEase(Ease.OutQuad));
            seq.AppendCallback(() =>
                itemUIObjectInstance.SendToPositionAndDie(
                    InventoryManager.Instance.GetBackpackImage().transform.position
                )
            );
            seq.AppendInterval(0.05f);
        }

        seq.AppendCallback(() =>
        {
            //isoPlayerMovement.UnblockPlayerActions();
            boosterPackCount -= times;
            HideShippingBox();
        });

        seq.Play();
    }

    public override void OnInteractStart()
    {
        if (!IsInteractable)
            return;

        Debug.Log("Interact started with Shipping Box");
        UIManager.Instance.ShowActionBubble(transform, "Open", "E");
    }

    public override void OnInteractEnd()
    {
        if (!IsInteractable)
            return;

        Debug.Log("Interact ended with Shipping Box");
        UIManager.Instance.HideActionBubble();
    }

    private void HideShippingBox()
    {
        // using dotween, do a small scale up followed by a scale down with fade out
        OnInteractEnd();
        IsInteractable = false;
        var seq = DOTween.Sequence();
        seq.Append(transform.DOScale(1.1f, 0.2f).SetEase(Ease.OutQuad));
        seq.Append(transform.DOScale(0f, 0.2f).SetEase(Ease.OutQuad));
        seq.Append(
            transform.GetComponent<MeshRenderer>().material.DOFade(0f, 0.2f).SetEase(Ease.OutQuad)
        );
    }
}
