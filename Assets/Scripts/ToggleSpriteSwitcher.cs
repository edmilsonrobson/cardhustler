using UnityEngine;
using UnityEngine.UI;

public class ToggleSpriteSwitcher : MonoBehaviour
{
    public Toggle toggle;
    public Image backgroundImage;
    public Sprite onSprite;
    public Sprite offSprite;

    void Start()
    {
        toggle.onValueChanged.AddListener(OnToggleChanged);
        // Set initial state
        OnToggleChanged(toggle.isOn);
    }

    void OnToggleChanged(bool isOn)
    {
        backgroundImage.sprite = isOn ? onSprite : offSprite;
    }
}
