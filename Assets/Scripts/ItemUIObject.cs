using DG.Tweening;
using UnityEngine;

public class ItemUIObject : MonoBehaviour
{
    [SerializeField]
    private CanvasGroup canvasGroup;

    // Start is called once before the first execution of Update after the MonoBehaviour is created

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
    }

    void Start() { }

    // Update is called once per frame
    void Update() { }

    public void PopAnimation()
    {
        var rectTransform = this.GetComponent<RectTransform>();
        rectTransform.DOPunchScale(Vector3.one * 1f, 0.1f).SetEase(Ease.OutQuad);
    }

    public void SendToPositionAndDie(Vector3 position)
    {
        // just do DOPunchScale yoyo

        var duration = Vector3.Distance(transform.position, position) / 300f;

        var seq = DOTween.Sequence();
        seq.Append(transform.DOMove(position, duration).SetEase(Ease.OutQuad));

        float fadeDuration = Mathf.Min(0.08f, duration * 0.5f);
        seq.Insert(
            duration - fadeDuration,
            canvasGroup.DOFade(0, fadeDuration).SetEase(Ease.OutQuad)
        );
        seq.AppendCallback(() =>
        {
            Destroy(gameObject);
        });
    }
}
