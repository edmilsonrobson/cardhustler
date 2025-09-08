using ES3Types;

public class SlotSave
{
    private const string SlotSaveFileName = "slot_1.es3";

    public static void SaveValue<T>(string key, T value)
    {
        ES3.Save(key, value, SlotSaveFileName);
    }

    public static T LoadValue<T>(string key, T defaultValue)
    {
        return ES3.Load<T>(key, SlotSaveFileName, defaultValue);
    }

    public static void TriggerSave() { }
}
