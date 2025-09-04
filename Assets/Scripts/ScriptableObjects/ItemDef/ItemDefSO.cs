// ItemDef: ScriptableObject definition
using UnityEngine;

[CreateAssetMenu(menuName = "Items/Item Definition")]
public class ItemDefSO : ScriptableObject
{
    [SerializeField]
    private string id; // stable, unique
    public string Id => id;

    public string displayName;
    public Sprite icon;
    public int maxStack = 99;
    public ItemKind kind;
}

public enum ItemKind
{
    BoosterPack,
}
