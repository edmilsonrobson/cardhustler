using UnityEngine;

[CreateAssetMenu(fileName = "AnnouncementSO", menuName = "Scriptable Objects/AnnouncementSO")]
public class AnnouncementSO : ScriptableObject
{
    public string id; // e.g 'tutorial-cardbay'
    public string h1;
    public string h2;

    [TextArea(3, 10)]
    public string bodyText;
    public Sprite sideImage;
    public string ctaText;
}
