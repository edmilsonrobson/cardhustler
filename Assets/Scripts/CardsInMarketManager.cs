using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CardsInMarketManager : MonoBehaviour
{
    public static CardsInMarketManager Instance { get; private set; }

    public List<CardSet> AllCardSets { get; private set; } = new List<CardSet>();

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        LoadOrCreateNewBaseSet();
    }

    private void LoadOrCreateNewBaseSet()
    {
        var baseSet = SlotSave.LoadValue<CardSet>("baseSet", null);
        if (baseSet == null)
        {
            Debug.Log("### No baseSet found in save, creating new base set");
            baseSet = new CardSet("Base Set", "BASE", CardSetType.Core);
            baseSet.cardsDefs = new CardGenerator(baseSet).GenerateCardPool();
            SlotSave.SaveValue("baseSet", baseSet);
        }

        AllCardSets.Add(baseSet);

        Debug.Log("### Base set loaded: " + baseSet.code);
        Debug.Log("### Base set cards: " + baseSet.cardsDefs.Count);
    }

    public List<string> GetAllSetCodes()
    {
        return AllCardSets.Select(set => set.code).ToList();
    }

    public CardSet GetSetByCode(string code)
    {
        return AllCardSets.FirstOrDefault(set => set.code == code);
    }
}
