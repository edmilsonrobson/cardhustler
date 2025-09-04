using DG.Tweening;
using TMPro;
using UnityEngine;

public class BoosterPackPanel : MonoBehaviour
{
    private CanvasGroup canvasGroup;

    [SerializeField]
    private TextMeshProUGUI boosterPackCountText;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        HideBoosterPackPanel(true);
    }

    public void ShowBoosterPackPanel()
    {
        canvasGroup.alpha = 0;
        canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad);
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;
    }

    public void SetBoosterPackCount(int count)
    {
        boosterPackCountText.text = count.ToString();
    }

    public void IncrementBoosterPackCount(int count)
    {
        boosterPackCountText.text = (int.Parse(boosterPackCountText.text) + count).ToString();
    }

    public void HideBoosterPackPanel(bool instant = false)
    {
        if (instant)
        {
            canvasGroup.alpha = 0;
        }
        else
        {
            canvasGroup.DOFade(0, 0.12f).SetEase(Ease.OutQuad);
        }
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;
    }
}
