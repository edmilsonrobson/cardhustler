using System.Collections.Generic;
using UnityEngine;

public static class SpritePool
{
    private static Sprite[] _pool;
    private static bool _loaded = false;

    private static void EnsureLoaded()
    {
        if (_loaded)
            return;
        _pool = Resources.LoadAll<Sprite>("PossibleCardImages");
        _loaded = true;
    }

    public static Sprite RandomSprite()
    {
        EnsureLoaded();
        if (_pool == null || _pool.Length == 0)
            return null;
        return _pool[Random.Range(0, _pool.Length)];
    }

    public static Sprite[] All
    {
        get
        {
            EnsureLoaded();
            return _pool;
        }
    }
}
