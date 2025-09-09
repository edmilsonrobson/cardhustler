using UnityEngine;

public class CardInspectorManager : MonoBehaviour
{
    public static CardInspectorManager Instance { get; private set; }

    [SerializeField]
    private CardInspectorPanel cardInspectorPanel;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
    }

    public void OpenCardInspector(CardInstance card)
    {
        cardInspectorPanel.OpenCardInspectorPanel(card);
    }
}
