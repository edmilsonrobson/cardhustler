using UnityEngine;

public class CursorManager : MonoBehaviour
{
    public static CursorManager Instance { get; private set; }

    [SerializeField]
    private Texture2D defaultCursor;

    [SerializeField]
    private Texture2D magnifyingCursor;

    [SerializeField]
    private Texture2D pointerCursor;

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

    public void ResetCursor() {
        Cursor.SetCursor(defaultCursor, Vector2.zero, CursorMode.Auto);
    }

    public void SetMagnifyingCursor() {
        Cursor.SetCursor(magnifyingCursor, Vector2.zero, CursorMode.Auto);
    }

    public void SetPointerCursor() {
        Cursor.SetCursor(pointerCursor, Vector2.zero, CursorMode.Auto);
    }
}
