using UnityEditor;
using UnityEngine;

public class DevTools
{
    [MenuItem("DevTools/Run My Function")]
    public static void RunMyFunction()
    {
        Debug.Log("Function ran!");

        var cardGenerator = new CardGenerator(new CardSet("Base Set", "BASE", CardSetType.Core));
        var cardSet = cardGenerator.PopulateSet();
        Debug.Log(cardSet.ToFullSetString());
    }
}
