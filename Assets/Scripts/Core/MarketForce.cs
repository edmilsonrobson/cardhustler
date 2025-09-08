using System.Collections.Generic;

public enum MarketForceType
{
    NewSetHype,
    Foil,
    ChaseCard,

    LowCompetitivePlay,
    Banned,
    ReprintIncoming,
    SlightlyPlayed,
    ModeratelyPlayed,
    HeavilyPlayed,
}

public static class MarketForceHelper
{
    public static readonly Dictionary<MarketForceType, int> Values = new Dictionary<
        MarketForceType,
        int
    >
    {
        { MarketForceType.NewSetHype, 10 },
        { MarketForceType.ChaseCard, 20 },
        { MarketForceType.Foil, 50 },
        { MarketForceType.LowCompetitivePlay, -10 },
        { MarketForceType.Banned, -100 },
        { MarketForceType.ReprintIncoming, -20 },
        { MarketForceType.SlightlyPlayed, -10 },
        { MarketForceType.ModeratelyPlayed, -30 },
        { MarketForceType.HeavilyPlayed, -60 },
    };

    public static readonly Dictionary<MarketForceType, string> Descriptions = new Dictionary<
        MarketForceType,
        string
    >
    {
        { MarketForceType.NewSetHype, "New set hype" },
        { MarketForceType.ChaseCard, "Chase card" },
        { MarketForceType.LowCompetitivePlay, "Low competitive play" },
        { MarketForceType.Banned, "Banned" },
        { MarketForceType.ReprintIncoming, "Reprint incoming" },
        { MarketForceType.Foil, "Foil" },
        { MarketForceType.SlightlyPlayed, "Slightly played" },
        { MarketForceType.ModeratelyPlayed, "Moderately played" },
        { MarketForceType.HeavilyPlayed, "Heavily played" },
    };
}
