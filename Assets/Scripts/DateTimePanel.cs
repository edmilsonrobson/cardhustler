using TMPro;
using UnityEngine;

public class DateTimePanel : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI dateText;

    [SerializeField]
    private TextMeshProUGUI timeText;

    private bool colonVisible = true;

    private void Start()
    {
        TimeManager.Instance.OnTick += UpdateDateTime;
        UpdateDateTime(TimeManager.Instance.Now);
    }

    private void OnDestroy()
    {
        TimeManager.Instance.OnTick -= UpdateDateTime;
    }

    private void UpdateDateTime(GameTime time)
    {
        dateText.text = "Day " + time.Day.ToString();
        timeText.text = $"{time.Hour:D2}:{time.Minute:D2}";
    }
}
