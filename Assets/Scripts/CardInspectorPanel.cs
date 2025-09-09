using TMPro;
using UnityEngine;

[RequireComponent(typeof(EffectUtils2D))]
public class CardInspectorPanel : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI cardPriceText;

    private EffectUtils2D effectUtils2D;

    private bool isOpen = false;

    void Awake()
    {
        effectUtils2D = GetComponent<EffectUtils2D>();
    }

    void Update() {
        if (isOpen && Input.GetKeyDown(KeyCode.Escape)) {
            CloseCardInspectorPanel();
        }
    }

    public void OpenCardInspectorPanel(CardInstance cardInstance)
    {
        isOpen = true;
        cardPriceText.text = cardInstance.cardDef.GetPriceString();
        effectUtils2D.FadeIn();

        GetComponentInChildren<AnimonCardUI>().SetCardInformation(cardInstance);
    }

    public void CloseCardInspectorPanel()
    {
        isOpen = false;
        effectUtils2D.FadeOut();
    }
}
