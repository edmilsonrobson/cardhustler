using TMPro;
using UnityEngine;

public class MoneyManager : MonoBehaviour
{
    public static MoneyManager Instance { get; private set; }

    public int money = 0;

    [SerializeField]
    private TextMeshProUGUI moneyText;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public void AddMoney(int amount)
    {
        money += amount;
        moneyText.text = money.ToString();
    }

    public void RemoveMoney(int amount)
    {
        money -= amount;
        if (money < 0)
        {
            money = 0;
        }
        moneyText.text = money.ToString();
    }

    public void SetMoney(int amount)
    {
        money = amount;
        moneyText.text = money.ToString();
    }

    public int GetMoney()
    {
        return money;
    }

    public void Save()
    {
        SlotSave.SaveValue("money", money);
    }

    public void Load()
    {
        money = SlotSave.LoadValue("money", 0);
        moneyText.text = money.ToString();
    }
}
