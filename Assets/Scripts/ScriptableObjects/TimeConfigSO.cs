using UnityEngine;

[CreateAssetMenu(menuName = "Config/TimeConfig")]
public class TimeConfig : ScriptableObject
{
    [Tooltip("In-game minutes per tick")]
    public int minutesPerTick = 10;

    [Tooltip("Real seconds per tick at 1x speed")]
    public float secondsPerTickAt1x = 6.25f;

    [Tooltip("Default wake time")]
    public int wakeHour = 8;

    [Tooltip("Default sleep time")]
    public int sleepHour = 24; // midnight

    [Tooltip("Max time warp ticks per frame when doing catch-up")]
    public int maxWarpTicksPerFrame = 200;
}
