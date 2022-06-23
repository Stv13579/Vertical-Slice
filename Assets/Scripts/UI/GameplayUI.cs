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


    [SerializeField]
    float maxComboTimer = 1.0f;

    float comboTimer = 1.0f;



    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Shooting>();
        playerClass = player.gameObject.GetComponent<PlayerClass>();
        comboTimer = maxComboTimer;
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
        }
        if (combo)
        {
            comboTimer -= Time.deltaTime;
        }
        else
        {
            comboTimer += Time.deltaTime;
        }
        comboTimer = Mathf.Clamp(comboTimer, 0, maxComboTimer);

        ChangeCombo(activePrimaryElement.transform.parent, true);
        ChangeCombo(activeCatalystElement.transform.parent, true);
        ChangeCombo(activeComboElement.transform.parent, false);
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
            float alpha = Mathf.Lerp(0.15f, 1.0f, comboTimer / maxComboTimer);
            uiObject.GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, alpha);

        }
        else
        {
            Color colour = uiObject.GetComponent<Image>().color;
            float alpha = Mathf.Lerp(1.0f, 0.15f, comboTimer / maxComboTimer);
            uiObject.GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, alpha);
        }
        for (int i = 0; i < uiObject.childCount; i++)
        {
            if (doCombo)
            {
                float alpha = Mathf.Lerp(0.15f, 1.0f, comboTimer / maxComboTimer);
                if (uiObject.GetChild(i).GetComponent<Image>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<Image>().color;
                    uiObject.GetChild(i).GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, alpha);
                }
                else if (uiObject.GetChild(i).GetComponent<TextMeshProUGUI>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color;
                    uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color = new Color(colour.r, colour.g, colour.b, alpha);
                }

            }
            else
            {
                float alpha = Mathf.Lerp(1.0f, 0.15f, comboTimer / maxComboTimer);

                if (uiObject.GetChild(i).GetComponent<Image>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<Image>().color;
                    uiObject.GetChild(i).GetComponent<Image>().color = new Color(colour.r, colour.g, colour.b, alpha);
                }
                else if (uiObject.GetChild(i).GetComponent<TextMeshProUGUI>())
                {
                    Color colour = uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color;
                    uiObject.GetChild(i).GetComponent<TextMeshProUGUI>().color = new Color(colour.r, colour.g, colour.b, alpha);
                }
            }
        }
    }
}
