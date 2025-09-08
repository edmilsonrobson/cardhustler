using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

public static class CardNameGenerator
{
    // CV-ish syllables per element to bias flavor
    private static readonly Dictionary<CardElement, string[]> ElementOnsets = new()
    {
        { CardElement.Fire, new[] { "f", "fl", "fi", "py", "br", "c", "sc", "ign", "kr" } },
        { CardElement.Water, new[] { "w", "wa", "sw", "a", "aq", "br", "dr", "gl" } },
        { CardElement.Grass, new[] { "gr", "g", "gl", "spr", "m", "v", "ver", "leaf" } },
        { CardElement.Electric, new[] { "z", "zap", "vol", "ele", "spark", "th", "tek" } },
    };

    private static readonly string[] Nuclei =
    {
        "a",
        "e",
        "i",
        "o",
        "u",
        "y",
        "ae",
        "ia",
        "ei",
        "ou",
        "uo",
    };

    private static readonly Dictionary<CardElement, string[]> ElementCodas = new()
    {
        { CardElement.Fire, new[] { "ar", "is", "ix", "or", "os", "ash", "flare" } },
        { CardElement.Water, new[] { "na", "ra", "is", "isle", "fin", "foam", "tid" } },
        { CardElement.Grass, new[] { "leaf", "bud", "root", "moss", "fern", "ling" } },
        { CardElement.Electric, new[] { "volt", "spark", "rix", "trik", "zap", "arc" } },
    };

    private static readonly string[] EpicEpithets =
    {
        "the Unbound",
        "of Wildfire",
        "the Oracle",
        "of the Zephyr",
        "of Starlight",
        "the Dread",
        "of Aegis",
        "the Riftwalker",
    };
    private static readonly string[] LegendEpithets =
    {
        "the Eternal",
        "Worldrender",
        "the Last Dragon",
        "Primeval",
        "the Moonlit",
        "Sunforged",
        "the Endless Gale",
    };

    // Disallowed ugly letter runs we will normalize
    private static readonly Regex DoubleVowel = new(
        "([aeiouy])\\1",
        RegexOptions.IgnoreCase | RegexOptions.Compiled
    );
    private static readonly Regex TripleConson = new(
        "([^aeiouy ]){3,}",
        RegexOptions.IgnoreCase | RegexOptions.Compiled
    );

    private static readonly HashSet<string> Reserved = new(StringComparer.OrdinalIgnoreCase)
    {
        // Add any reserved names you never want generated
        "Pikachu",
        "Charizard",
        "Mewtwo",
    };

    public static string GenerateCardName(
        CardElement element,
        string archetype = null,
        Rarity rarity = Rarity.Common,
        int maxLen = 14,
        int seed = 0
    )
    {
        // Deterministic RNG if seed provided, otherwise time based
        var rng = seed == 0 ? new Random(Guid.NewGuid().GetHashCode()) : new Random(seed);

        // Choose how many syllables based on rarity (higher rarity skews longer)
        int syllables = rarity switch
        {
            Rarity.Common => Weighted(rng, (1, 40), (2, 45), (3, 15)),
            Rarity.Rare => Weighted(rng, (2, 30), (3, 50), (4, 20)),
            Rarity.Epic => Weighted(rng, (3, 40), (4, 45), (5, 15)),
            Rarity.Legendary => Weighted(rng, (3, 25), (4, 45), (5, 30)),
            _ => 2,
        };

        // Build core name
        string core = BuildCore(element, syllables, rng);

        // Blend in archetype hint sometimes
        if (!string.IsNullOrWhiteSpace(archetype) && rng.NextDouble() < 0.35)
        {
            core = Fuse(core, ArchetypeShard(archetype), rng);
        }

        core = Clean(core);

        // Length clamp retry loop
        int guard = 0;
        while (core.Length > maxLen && guard++ < 6)
        {
            core = TrimSmart(core);
        }

        // Capitalize nicely
        core = Capitalize(core);

        // Avoid collisions and reserved names by injecting a short suffix if needed
        if (Reserved.Contains(core))
        {
            core = MakeNonReserved(core, element, rng, maxLen);
        }

        // Add epithet for higher rarity
        if (rarity >= Rarity.Rare)
        {
            string epithet = rarity switch
            {
                Rarity.Epic => Pick(rng, EpicEpithets),
                Rarity.Legendary => Pick(rng, LegendEpithets),
                _ => null,
            };
            if (
                !string.IsNullOrEmpty(epithet)
                && (core.Length + 1 + epithet.Length) <= Math.Max(maxLen + 10, 22)
            )
            {
                return $"{core}, {epithet}";
            }
        }

        return core;
    }

    // Helpers

    private static string BuildCore(CardElement e, int syllables, Random rng)
    {
        var sb = new StringBuilder();

        // Start with an element flavored onset
        var onsetPool = ElementOnsets.TryGetValue(e, out var ons)
            ? ons
            : ElementOnsets[CardElement.Fire];
        var codaPool = ElementCodas.TryGetValue(e, out var cod)
            ? cod
            : ElementCodas[CardElement.Fire];

        // First chunk is onset + nucleus
        sb.Append(Pick(rng, onsetPool));
        sb.Append(Pick(rng, Nuclei));

        // Middle chunks are usually nucleus + soft consonant
        for (int i = 1; i < syllables - 1; i++)
        {
            if (rng.NextDouble() < 0.7)
                sb.Append(Pick(rng, Nuclei));
            sb.Append(Pick(rng, new[] { "l", "r", "n", "m", "s", "th", "v" }));
        }

        // End with an element flavored coda
        if (syllables > 1 && rng.NextDouble() < 0.8)
        {
            sb.Append(Pick(rng, codaPool));
        }
        else
        {
            // Short tail
            if (rng.NextDouble() < 0.5)
                sb.Append(Pick(rng, Nuclei));
            sb.Append(Pick(rng, new[] { "n", "r", "l", "x", "s" }));
        }

        return sb.ToString();
    }

    private static string Clean(string raw)
    {
        string s = raw.ToLowerInvariant();

        // Fix awkward clusters
        s = s.Replace("kk", "k").Replace("xx", "x").Replace("yy", "y");
        s = DoubleVowel.Replace(s, m => m.Groups[1].Value); // aa -> a
        s = TripleConson.Replace(s, ""); // strip very hard clusters

        // Human friendly replacements
        s = s.Replace("psi", "psa"); // less harsh start
        s = s.Replace("gn", "n"); // gn -> n

        // Collapse repeats left over
        s = Regex.Replace(s, "(.)\\1{2,}", "$1$1");

        return s;
    }

    private static string TrimSmart(string s)
    {
        // Try removing a trailing coda-like piece
        var cut = Regex.Replace(
            s,
            "(leaf|wing|stone|frost|volt|gear|drake|shade|ling|mist|core|mire|gale)$",
            ""
        );
        if (cut.Length >= 5)
            return cut;

        // Otherwise shave last 2 chars
        return s.Length > 6 ? s[..^2] : s[..^1];
    }

    private static string Capitalize(string s)
    {
        if (string.IsNullOrEmpty(s))
            return s;
        // TitleCase while keeping fused parts readable
        return Regex
            .Replace(s, "^(.)", m => m.Value.ToUpper())
            .Replace(" of ", " of ") // no-op, clarity
            .Replace(" the ", " the "); // no-op, clarity
    }

    private static string MakeNonReserved(string core, CardElement e, Random rng, int maxLen)
    {
        var add = Pick(rng, ElementCodas[e]);
        string fused = Fuse(core, add, rng);
        if (fused.Length > maxLen)
            fused = TrimSmart(fused);
        return Capitalize(Clean(fused));
    }

    private static string ArchetypeShard(string archetype)
    {
        // Map some common archetype hints to flavorful shards
        string a = archetype.ToLowerInvariant();
        if (a.Contains("tank") || a.Contains("armor"))
            return "aeg";
        if (a.Contains("assassin") || a.Contains("rogue"))
            return "shade";
        if (a.Contains("healer") || a.Contains("support"))
            return "mend";
        if (a.Contains("mage") || a.Contains("wizard"))
            return "magi";
        if (a.Contains("beast") || a.Contains("brute"))
            return "fang";
        if (a.Contains("wind") || a.Contains("speed"))
            return "zeph";
        if (a.Contains("trap") || a.Contains("control"))
            return "snare";
        return a.Length <= 5 ? a : a[..5];
    }

    private static string Fuse(string a, string b, Random rng)
    {
        if (string.IsNullOrEmpty(b))
            return a;
        // Simple phonetic fuse: if a ends with vowel and b starts with vowel, add connector
        bool aVowel = "aeiouy".Contains(a[^1]);
        bool bVowel = "aeiouy".Contains(b[0]);
        string connector = (!aVowel || !bVowel) ? "" : (rng.NextDouble() < 0.5 ? "r" : "l");
        return a + connector + b;
    }

    private static T Pick<T>(Random rng, IReadOnlyList<T> arr) => arr[rng.Next(arr.Count)];

    private static int Weighted(Random rng, params (int value, int weight)[] items)
    {
        int total = items.Sum(i => i.weight);
        int roll = rng.Next(1, total + 1);
        int acc = 0;
        foreach (var (val, w) in items)
        {
            acc += w;
            if (roll <= acc)
                return val;
        }
        return items[0].value;
    }
}
