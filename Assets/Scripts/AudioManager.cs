using UnityEngine;
using UnityEngine.Audio;

public class AudioManager : MonoBehaviour
{
    public static AudioManager instance { get; private set; }

    [SerializeField]
    private AudioMixer audioMixer;

    void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(this.gameObject);
            return;
        }
        instance = this;
        DontDestroyOnLoad(this.gameObject);
    }

    void Start()
    {
        audioMixer.SetFloat(
            "MasterVolume",
            AudioPlayerPrefToMixerFloat(GlobalSave.LoadValue<float>("MasterVolume", 50f))
        );
        audioMixer.SetFloat(
            "SFXVolume",
            AudioPlayerPrefToMixerFloat(GlobalSave.LoadValue<float>("SFXVolume", 50f))
        );
        audioMixer.SetFloat(
            "MusicVolume",
            AudioPlayerPrefToMixerFloat(GlobalSave.LoadValue<float>("MusicVolume", 50f))
        );
    }

    public static float AudioPlayerPrefToMixerFloat(float value)
    {
        if (value == 0f)
        {
            return -80f;
        }
        return Mathf.Log10(value / 100f) * 20;
    }

    public void PlaySound(AudioClip sound, float pitch = 1f)
    {
        // instantiate a new audio source and play it, then destroy
        var audioSource = new GameObject("AudioSource").AddComponent<AudioSource>();
        audioSource.outputAudioMixerGroup = audioMixer.FindMatchingGroups("SFX")[0];
        audioSource.clip = sound;
        audioSource.pitch = pitch;
        audioSource.Play();
        Destroy(audioSource.gameObject, audioSource.clip.length);
    }
}
