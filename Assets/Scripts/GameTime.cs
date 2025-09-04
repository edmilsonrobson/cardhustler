public enum TimeSpeed
{
    Paused = 0,
    x1 = 1,
    x2 = 2,
    x4 = 4,
}

[System.Serializable]
public struct GameTime : System.IComparable<GameTime>
{
    public int Day; // Day 1, 2, 3...
    public int Hour; // 0..23
    public int Minute; // 0..59

    public GameTime(int day, int hour, int minute)
    {
        Day = day;
        Hour = hour;
        Minute = minute;
    }

    public static GameTime StartOfDay(int day) => new GameTime(day, 8, 0); // wake at 08:00 by default

    public int CompareTo(GameTime other)
    {
        if (Day != other.Day)
            return Day.CompareTo(other.Day);
        if (Hour != other.Hour)
            return Hour.CompareTo(other.Hour);
        return Minute.CompareTo(other.Minute);
    }

    public override string ToString() => $"{Hour:D2}:{Minute:D2} (Day {Day})";
}
