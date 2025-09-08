using UnityEngine;

public class CardBayScreen : MonoBehaviour
{
    public void GoBack()
    {
        GetComponentInParent<ComputerMonitor>().CloseCardBay();
    }
}
