using DG.Tweening;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

public class EscMenu : MonoBehaviour
{
    public bool IsOpen { get; private set; } = false;

    private CanvasGroup canvasGroup;

    [SerializeField]
    private Slider masterVolumeSlider;

    [SerializeField]
    private Slider sfxVolumeSlider;

    [SerializeField]
    private Slider musicVolumeSlider;

    [SerializeField]
    private AudioMixer audioMixer;

    [SerializeField]
    private AudioClip escMenuOpenSound;

    [SerializeField]
    private AudioClip testSound;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = false;
        canvasGroup.interactable = false;

        IsOpen = false;

        masterVolumeSlider.value = GlobalSave.LoadValue<float>("MasterVolume", 50f);
        sfxVolumeSlider.value = GlobalSave.LoadValue<float>("SFXVolume", 50f);
        musicVolumeSlider.value = GlobalSave.LoadValue<float>("MusicVolume", 50f);

        masterVolumeSlider.onValueChanged.AddListener(OnMasterVolumeChanged);
        sfxVolumeSlider.onValueChanged.AddListener(OnSFXVolumeChanged);
        musicVolumeSlider.onValueChanged.AddListener(OnMusicVolumeChanged);
    }

    public void OnMasterVolumeChanged(float value)
    {
        GlobalSave.SaveValue<float>("MasterVolume", value);
        audioMixer.SetFloat("MasterVolume", AudioManager.AudioPlayerPrefToMixerFloat(value));
    }

    public void OnSFXVolumeChanged(float value)
    {
        GlobalSave.SaveValue<float>("SFXVolume", value);
        audioMixer.SetFloat("SFXVolume", AudioManager.AudioPlayerPrefToMixerFloat(value));

        AudioManager.instance.PlaySound(testSound);
    }

    public void OnMusicVolumeChanged(float value)
    {
        GlobalSave.SaveValue<float>("MusicVolume", value);
        audioMixer.SetFloat("MusicVolume", AudioManager.AudioPlayerPrefToMixerFloat(value));
    }

    public void Open()
    {
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = true;
        canvasGroup.interactable = true;

        Sequence seq = DOTween.Sequence();
        seq.Append(canvasGroup.DOFade(1, 0.12f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOScale(1.05f, 0.15f).SetEase(Ease.OutQuad)); // subtle overshoot
        seq.Append(transform.DOScale(1f, 0.1f).SetEase(Ease.OutBack)); // settle

        IsOpen = true;
        IsoPlayerMovement.Instance.BlockPlayerActions();

        AudioManager.instance.PlaySound(escMenuOpenSound);
    }

    public void Close()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOScale(0.95f, 0.12f).SetEase(Ease.InQuad)); // shrink slightly
        seq.Join(canvasGroup.DOFade(0, 0.12f).SetEase(Ease.InQuad));

        seq.OnComplete(() =>
        {
            canvasGroup.blocksRaycasts = false;
            canvasGroup.interactable = false;
            IsOpen = false;
            IsoPlayerMovement.Instance.UnblockPlayerActions();
        });
    }

    public void OnExit()
    {
        Application.Quit();
    }
}
