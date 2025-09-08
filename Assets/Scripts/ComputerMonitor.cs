using DG.Tweening;
using UnityEngine;

public class ComputerMonitor : MonoBehaviour
{
    [SerializeField]
    private GameObject SamuraiGameScreen;

    [SerializeField]
    private RectTransform cardBayScreen;

    [SerializeField]
    private RectTransform desktopScreen;

    private CanvasGroup canvasGroup;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
    }

    void Start() { }

    // Update is called once per frame
    void Update() { }

    public void OpenCardBay()
    {
        UISoundManager.instance.PlayClickSound();
        var canvas = cardBayScreen.GetComponent<CanvasGroup>();
        canvas.alpha = 1;
        canvas.blocksRaycasts = true;
        canvas.interactable = true;
    }

    public void CloseCardBay()
    {
        UISoundManager.instance.PlayClickSound();
        var canvas = cardBayScreen.GetComponent<CanvasGroup>();
        canvas.blocksRaycasts = false;
        canvas.interactable = false;
        canvas.alpha = 0;
    }

    public void OpenDesktopScreen()
    {
        canvasGroup.DOFade(1, 0.15f);
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;
    }

    public void CloseDesktopScreen()
    {
        UISoundManager.instance.PlayClickSound();
        canvasGroup.DOFade(0, 0.15f);
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;

        // Close all other screens
        CloseCardBay();
    }
}
