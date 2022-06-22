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

    bool combo = false;

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
        moneyText.text = playerClass.money.ToString();
        activePrimaryElement.sprite = player.GetPrimaryElement();
        activeCatalystElement.sprite = player.GetCatalystElement();
        activeComboElement.sprite = player.GetComboElement();
        crosshair.sprite = player.GetCrosshair();
        if (Input.GetKeyDown(KeyCode.F))
        {
            combo = !combo;
            Transform uiObject = activePrimaryElement.transform.parent;
            ChangeCombo(activePrimaryElement.transform.parent, combo);
            ChangeCombo(activeCatalystElement.transform.parent, combo);
            ChangeCombo(activeComboElement.transform.parent, !combo);


        }
    }

    public void AddItem(Sprite[] sprites)
    {
        if(itemIndex < items.Count)
        {
            items[itemIndex].sprite = sprites[0];
            items[itemIndex].transform.GetChild(0).GetComponent<Image>().sprite = sprites[1];
            items[itemIndex].enabled = true;
            items[itemIndex].transform.GetChild(0).GetComponent<Image>().enabled = true;
            itemIndex++;
        }
    }

    void ChangeCombo(Transform uiObject, bool doCombo)
    {
        if(doCombo)
        {
            Color colour = uiObject.GetComponent<Image>().color;
            uiObject.GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, 0.25f);

        }
        else
        {
            Color colour = uiObject.GetComponent<Image>().color;
            uiObject.GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, 1.0f);
        }
        for (int i = 0; i < uiObject.childCount; i++)
        {
            if (doCombo)
            {
                if (uiObject.GetChild(i).GetComponent<Image>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<Image>().color;
                    uiObject.GetChild(i).GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, 0.25f);
                }
                else if (uiObject.GetChild(i).GetComponent<TextMeshProUGUI>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color;
                    uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color = new Color(colour.r, colour.g, colour.b, 0.25f);
                }

            }
            else
            {
                if (uiObject.GetChild(i).GetComponent<Image>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<Image>().color;
                    uiObject.GetChild(i).GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, 1.0f);
                }
                else if (uiObject.GetChild(i).GetComponent<TextMeshProUGUI>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color;
                    uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color = new Color(colour.r, colour.g, colour.b, 0.5f);
                }
            }
        }
    }
}
