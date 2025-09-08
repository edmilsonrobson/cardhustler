using UnityEngine;

public class UISoundManager : MonoBehaviour
{
    public static UISoundManager instance { get; private set; }

    [SerializeField]
    private AudioClip uiClickSound;

    void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(gameObject);
            return;
        }
        instance = this;
    }

    public void PlayClickSound()
    {
        AudioManager.instance.PlaySound(uiClickSound, Random.Range(0.9f, 1.1f));
    }

    public void PlayComputerBoot() {
        
    }
}
