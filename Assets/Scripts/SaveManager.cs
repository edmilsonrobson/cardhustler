using UnityEngine;

public class SaveManager : MonoBehaviour
{
    public static SaveManager Instance { get; private set; }

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

    void Start()
    {
        LoadAll();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Y))
        {
            Debug.Log("Saving all");
            SaveAll();
        }
    }

    public void SaveAll()
    {
        CardInventoryManager.Instance.Save();
    }

    public void LoadAll()
    {
        CardInventoryManager.Instance.Load();
    }
}
