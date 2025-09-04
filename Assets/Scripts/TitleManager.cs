using UnityEngine;
using UnityEngine.SceneManagement;

public class TitleManager : MonoBehaviour
{
    public void OnNewGame()
    {
        SceneManager.LoadScene("Room");
    }

    public void Exit()
    {
        Application.Quit();
    }
}
