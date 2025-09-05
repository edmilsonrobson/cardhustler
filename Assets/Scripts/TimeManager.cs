using System;
using System.Collections.Generic;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    public static TimeManager Instance { get; private set; }

    [SerializeField]
    private TimeConfig config;

    public event Action<GameTime> OnTick; // every 10 in-game minutes
    public event Action<GameTime> OnHourChanged; // when hour rolls over
    public event Action<GameTime> OnDayEnded; // when sleepHour reached

    public TimeSpeed Speed { get; private set; } = TimeSpeed.x1;
    public GameTime Now { get; private set; }

    // Simple min-heap by time for scheduled actions
    private readonly List<(GameTime when, Action action)> schedule = new();

    Coroutine loop;

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

    void Start()
    {
        StartNewDay(1);
        AnnouncementManager.Instance.ShowAnnouncement("tutorial-hello");
    }

    public void StartNewDay(int dayNumber)
    {
        Now = new GameTime(dayNumber, config.wakeHour, 0);
        RestartLoop();
        FireAllDue();
    }

    void RestartLoop()
    {
        if (loop != null)
            StopCoroutine(loop);
        if (Speed == TimeSpeed.Paused)
            return;
        loop = StartCoroutine(TickLoop());
    }

    System.Collections.IEnumerator TickLoop()
    {
        while (true)
        {
            float seconds = config.secondsPerTickAt1x / (int)Speed;
            yield return new WaitForSecondsRealtime(seconds);
            AdvanceOneTick(visual: true);
        }
    }

    // Advance one discrete tick
    void AdvanceOneTick(bool visual)
    {
        int prevHour = Now.Hour;

        // increment minutes
        int m = Now.Minute + config.minutesPerTick;
        int h = Now.Hour;
        int d = Now.Day;

        if (m >= 60)
        {
            m -= 60;
            h += 1;
        }
        if (h >= 24)
        {
            h = 0;
            d += 1;
        }

        Now = new GameTime(d, h, m);

        // run scheduled
        FireAllDue();

        // events
        OnTick?.Invoke(Now);
        if (Now.Hour != prevHour)
            OnHourChanged?.Invoke(Now);

        // day end
        if (Now.Hour >= config.sleepHour && Now.Minute == 0)
        {
            OnDayEnded?.Invoke(Now);
            // Typically pause or start next day automatically
        }
    }

    void FireAllDue()
    {
        // naive list scan - fine for small counts
        schedule.Sort((a, b) => a.when.CompareTo(b.when));
        int i = 0;
        while (i < schedule.Count && schedule[i].when.CompareTo(Now) <= 0)
        {
            var act = schedule[i].action;
            i++;
            try
            {
                act?.Invoke();
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }
        if (i > 0)
            schedule.RemoveRange(0, i);
    }

    // Public API
    public void SetSpeed(TimeSpeed speed)
    {
        Speed = speed;
        RestartLoop();
    }

    public void Pause() => SetSpeed(TimeSpeed.Paused);

    public void Resume() => SetSpeed(TimeSpeed.x1);

    public void FastForward2x() => SetSpeed(TimeSpeed.x2);

    public void FastForward4x() => SetSpeed(TimeSpeed.x4);

    public void Schedule(GameTime when, Action action)
    {
        schedule.Add((when, action));
    }

    // Big skip for sleep or travel. No yielding, runs immediately.
    public void SkipTo(GameTime target)
    {
        // Ensure target >= Now
        if (target.CompareTo(Now) <= 0)
            return;

        int safety = 0;
        while (Now.CompareTo(target) < 0)
        {
            AdvanceOneTick(visual: false);
            safety++;
            if (safety > 1000000)
            {
                Debug.LogError("Time warp safety break.");
                break;
            }
        }
    }

    // Helpers
    public GameTime TodayAt(int hour, int minute = 0) => new GameTime(Now.Day, hour, minute);

    public GameTime AddMinutes(GameTime t, int minutes)
    {
        int total = t.Hour * 60 + t.Minute + minutes;
        int dayDelta = Mathf.FloorToInt(total / 1440f);
        total = (total % 1440 + 1440) % 1440;
        return new GameTime(t.Day + dayDelta, total / 60, total % 60);
    }
}
