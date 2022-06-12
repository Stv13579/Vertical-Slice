using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;


public class GameplayUI : MonoBehaviour
{
    PlayerClass playerClass;
    Shooting player;

    //Serialize all UI elements
    [SerializeField]
    Image healthBar, manaBar, activePrimaryElement, activeCatalystElement, activeComboElement, crosshair;

    [SerializeField]
    List<Image> items;
    int itemIndex = 0;

    [SerializeField]
    TextMeshProUGUI moneyText;

    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Shooting>();
        playerClass = player.gameObject.GetComponent<PlayerClass>();
    }

    void Update()
    {
        //Getting the current values from the player and updating the UI with them
        healthBar.fillAmount = playerClass.currentHealth / playerClass.maxHealth;
        manaBar.fillAmount = playerClass.currentMana / playerClass.maxMana;
        moneyText.text = "Money: " + playerClass.money.ToString();
        activePrimaryElement.sprite = player.GetPrimaryElement();
        activeCatalystElement.sprite = player.GetCatalystElement();
        activeComboElement.sprite = player.GetComboElement();
        crosshair.sprite = player.GetCrosshair();
        if (Input.GetKeyDown(KeyCode.F))
        {
            activePrimaryElement.transform.parent.parent.gameObject.SetActive(!activePrimaryElement.transform.parent.parent.gameObject.activeSelf);
            activeCatalystElement.transform.parent.parent.gameObject.SetActive(!activeCatalystElement.transform.parent.parent.gameObject.activeSelf);
            activeComboElement.transform.parent.parent.gameObject.SetActive(!activeComboElement.transform.parent.parent.gameObject.activeSelf);

        }
    }

    public void AddItem(Sprite sprite)
    {
        if(itemIndex < items.Count)
        {
            items[itemIndex].sprite = sprite;
            items[itemIndex].enabled = true;
            itemIndex++;
        }
    }
}
