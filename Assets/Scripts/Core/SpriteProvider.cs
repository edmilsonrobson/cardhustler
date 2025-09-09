using UnityEngine;

public static class SpriteProvider
{
    public static Sprite GetSprite(string key)
    {
        return string.IsNullOrEmpty(key)
            ? null
            : Resources.Load<Sprite>("PossibleCardImages/" + key);
    }
}
