using TMPro;
using UnityEngine;

public class AnimonCardBayHolder : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI priceText;

    [SerializeField]
    private TextMeshProUGUI ownedCountText;

    public void SetPriceText(string price)
    {
        priceText.text = price;
    }

    public void SetOwnedCountText(int count)
    {
        ownedCountText.text = $"x{count}";
    }
}
