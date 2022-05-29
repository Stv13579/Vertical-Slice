using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UITestScript : MonoBehaviour
{

    PlayerClass playerClass;
    Shooting player;

    [SerializeField]
    Text manaText, healthText, leftSpellText, rightSpellText, comboSpellText, moneyText;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Shooting>();
        playerClass = player.gameObject.GetComponent<PlayerClass>();
    }

    // Update is called once per frame
    void Update()
    {
        manaText.text = "Mana: " + playerClass.currentMana.ToString("F0") + "/" + playerClass.maxMana;
        healthText.text = "Health: " + playerClass.currentHealth + "/" + playerClass.maxHealth;
        leftSpellText.text = "Left Spell: " +  player.GetPrimaryElement();
        rightSpellText.text = "Right Spell: " + player.GetCatalystElement();
        comboSpellText.text = "Combo Spell: " + player.GetComboElement();
        if(Input.GetKeyDown(KeyCode.F))
        {
            leftSpellText.enabled = !leftSpellText.enabled;
            rightSpellText.enabled = !rightSpellText.enabled;
            comboSpellText.enabled = !comboSpellText.enabled;

        }
    }
}
