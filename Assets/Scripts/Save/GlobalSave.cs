using ES3Types;
using UnityEngine;

public class GlobalSave
{
    private const string GlobalSaveFileName = "global.es3";

    public static void SaveValue<T>(string key, T value)
    {
        ES3.Save(key, value, GlobalSaveFileName);
    }

    public static T LoadValue<T>(string key, T defaultValue)
    {
        var value = ES3.Load<T>(key, GlobalSaveFileName, defaultValue);
        return value;
    }

    public static T LoadValue<T>(string key)
    {
        if (ES3.KeyExists(key, GlobalSaveFileName))
        {
            return ES3.Load<T>(key, GlobalSaveFileName);
        }
        return default(T);
    }
}
