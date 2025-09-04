using UnityEngine;

public enum InteractKind
{
    Use,
    Sit,
    Talk,
    Inspect,
    Custom,
}

public class Interactable : MonoBehaviour
{
    public bool IsInteractable { get; set; } = true;

    [Header("What shows in the prompt")]
    public InteractKind kind = InteractKind.Use;
    public string customLabel; // used when kind == Custom

    [Header("Optional - where the player should look at")]
    public Transform focusPoint; // if null, uses this.transform

    public string GetPrompt()
    {
        if (kind == InteractKind.Custom && !string.IsNullOrWhiteSpace(customLabel))
            return customLabel;

        return kind.ToString(); // "Use", "Sit", etc.
    }

    // You will override this per prefab by adding a derived script if needed,
    // or use UnityEvents if you prefer. For now, just log.
    public virtual void Interact(Transform interactor)
    {
        Debug.Log($"Interacted with {name} - action: {GetPrompt()}");
    }

    public Vector3 GetFocusPosition()
    {
        return (focusPoint ? focusPoint : transform).position;
    }

    public virtual void OnInteractStart()
    {
        Debug.Log($"Interact started with {name}");
        var outline = gameObject.AddComponent<Outline>();
        outline.OutlineMode = Outline.Mode.OutlineAll;
        outline.OutlineColor = Color.white;
        outline.OutlineWidth = 40f;

        UIManager.Instance.ShowActionBubble(transform, GetPrompt(), "E");
    }

    public virtual void OnInteractEnd()
    {
        Debug.Log($"Interact ended with {name}");
        Destroy(gameObject.GetComponent<Outline>());

        UIManager.Instance.HideActionBubble();
    }
}
