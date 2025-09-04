using UnityEngine;

public class PlayerVisual : MonoBehaviour
{
    [SerializeField]
    private Animator animator;
    private bool isWalking = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start() { }

    // Update is called once per frame
    void Update() { }

    public void SetIsWalking(bool isWalking)
    {
        if (this.isWalking == isWalking)
            return;

        this.isWalking = isWalking;
        if (isWalking)
        {
            GetComponent<Animator>().SetBool("IsWalking", true);
        }
        else
        {
            GetComponent<Animator>().SetBool("IsWalking", false);
        }
    }
}
