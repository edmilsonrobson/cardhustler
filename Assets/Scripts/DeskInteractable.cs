using UnityEngine;

public class DeskInteractable : Interactable
{
    public override void Interact(Transform interactor)
    {
        UIManager.Instance.ToggleComputerMonitor();
    }

    public override void OnInteractStart()
    {
        base.OnInteractStart();
    }

    public override void OnInteractEnd()
    {
        base.OnInteractEnd();
    }
}
