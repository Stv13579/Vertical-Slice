using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UITestScript : MonoBehaviour
{
    public PlayerData pData;
    Shooting player;

    [SerializeField]
    Text manaText, healthText, leftSpellText, rightSpellText, comboSpellText;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Shooting>();
    }

    // Update is called once per frame
    void Update()
    {
        manaText.text = "Mana: " + pData.mana + "/" + pData.maxMana;
        healthText.text = "Health: " + pData.health + "/" + pData.maxHealth;
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
