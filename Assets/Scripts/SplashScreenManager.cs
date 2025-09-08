using UnityEngine;
using UnityEngine.SceneManagement;

public class SplashScreenManager : MonoBehaviour
{
    [SerializeField]
    private RectTransform edLogo;

    [SerializeField]
    private AudioClip edLogoSound;

    [SerializeField]
    private AudioSource audioSource;

    void Awake()
    {
        audioSource = GetComponent<AudioSource>();
    }

    void Start()
    {
        // after 1s, we make edLogo active and play a sound. then after 2s, we move to another scene
        Invoke("ShowEdLogo", 0.25f);
        Invoke("MoveToNextScene", 2.25f);
    }

    private void ShowEdLogo()
    {
        audioSource.Play();
        edLogo.gameObject.SetActive(true);
    }

    private void MoveToNextScene()
    {
        SceneManager.LoadScene("TitleScreen");
    }
}
