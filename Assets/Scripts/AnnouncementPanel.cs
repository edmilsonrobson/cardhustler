using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class AnnouncementPanel : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI h1Text;

    [SerializeField]
    private TextMeshProUGUI h2Text;

    [SerializeField]
    private TextMeshProUGUI bodyText;

    [SerializeField]
    private Image sideImage;

    [SerializeField]
    private TextMeshProUGUI ctaText;

    void Awake()
    {
        var canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;
    }

    public void SetH1(string h1)
    {
        h1Text.text = h1;
    }

    public void SetH2(string h2)
    {
        h2Text.text = h2;
    }

    public void SetBodyText(string bodyText)
    {
        this.bodyText.text = bodyText;
    }

    public void SetSideImage(Sprite sideImage)
    {
        this.sideImage.sprite = sideImage;
    }

    public void SetCtaText(string ctaText)
    {
        this.ctaText.text = ctaText;
    }

    public void OnCTAClick()
    {
        AnnouncementManager.Instance.HideAnnouncement();
    }
}
