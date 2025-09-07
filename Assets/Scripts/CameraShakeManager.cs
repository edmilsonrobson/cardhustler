using MoreMountains.Feedbacks;
using UnityEngine;

public class CameraShakeManager : MonoBehaviour
{
    public static CameraShakeManager instance { get; private set; }

    [SerializeField]
    private MMF_Player mmfPlayer;

    private void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(this.gameObject);
            return;
        }
        instance = this;
        DontDestroyOnLoad(this.gameObject);

        mmfPlayer = Camera.main.GetComponent<MMF_Player>();
    }

    public void MediumShake()
    {
        mmfPlayer.PlayFeedbacks();
    }
}
