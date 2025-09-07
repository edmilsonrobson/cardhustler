using UnityEngine;

public class ParticleManager : MonoBehaviour
{
    public static ParticleManager instance { get; private set; }

    [Header("Particles")]
    public ParticleSystem magicAuraParticle;

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

    public void PlayMagicAuraParticle(Vector3 position, GameObject parent)
    {
        var particleInstance = Instantiate(
            magicAuraParticle,
            position,
            Quaternion.identity,
            parent.transform
        );
        particleInstance.transform.localPosition = new Vector3(0, 0, -238);
        particleInstance.Play();
    }
}
