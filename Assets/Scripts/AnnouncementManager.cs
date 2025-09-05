using System.Collections.Generic;
using UnityEngine;

public class AnnouncementManager : MonoBehaviour
{
    public static AnnouncementManager Instance { get; private set; }

    public List<AnnouncementSO> announcements;

    [SerializeField]
    private AnnouncementPanel announcementPanel;

    [SerializeField]
    private bool disableAnnouncements = false;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public AnnouncementSO GetAnnouncementById(string id)
    {
        return announcements.Find(announcement => announcement.id == id);
    }

    public void ShowAnnouncement(string id)
    {
        if (disableAnnouncements)
            return;
        Debug.Log("ShowAnnouncement");
        IsoPlayerMovement.Instance.BlockPlayerActions();
        var announcement = GetAnnouncementById(id);
        Debug.Log(announcement);
        announcementPanel.SetH1(announcement.h1);
        announcementPanel.SetH2(announcement.h2);
        announcementPanel.SetBodyText(announcement.bodyText);
        announcementPanel.SetSideImage(announcement.sideImage);
        announcementPanel.SetCtaText(announcement.ctaText);

        announcementPanel.GetComponent<EffectUtils2D>().MenuIn();
    }

    public void HideAnnouncement()
    {
        announcementPanel.GetComponent<EffectUtils2D>().MenuOut();
        IsoPlayerMovement.Instance.UnblockPlayerActions();
    }
}
