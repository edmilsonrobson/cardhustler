using UnityEngine;

public class DeskInteractable : Interactable
{
    public override void Interact(Transform interactor)
    {
        UIManager.Instance.ToggleComputerMonitor();
    }
}
