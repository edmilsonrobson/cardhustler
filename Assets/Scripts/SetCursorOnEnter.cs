using UnityEngine;
using UnityEngine.EventSystems;

public class SetCursorOnEnter : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    public enum CursorType
    {
        Magnifying,
        Pointer,
    }

    public CursorType cursorType = CursorType.Magnifying;

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (CursorManager.Instance == null)
            return;

        switch (cursorType)
        {
            case CursorType.Magnifying:
                CursorManager.Instance.SetMagnifyingCursor();
                break;
            case CursorType.Pointer:
                CursorManager.Instance.SetPointerCursor();
                break;
        }
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        if (CursorManager.Instance == null)
            return;

        CursorManager.Instance.ResetCursor();
    }
}
