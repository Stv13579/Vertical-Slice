using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class GameplayUI : MonoBehaviour
{
    PlayerClass playerClass;
    Shooting player;

    //Serialize all UI elements
    [SerializeField]
    Image healthBar, manaBar, activePrimaryElement, activeCatalystElement, activeComboElement;

    [SerializeField]
    Text moneyText;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Shooting>();
        playerClass = player.gameObject.GetComponent<PlayerClass>();
    }

    // Update is called once per frame
    void Update()
    {
        healthBar.fillAmount = playerClass.currentHealth / playerClass.maxHealth;
        manaBar.fillAmount = playerClass.currentMana / playerClass.maxMana;
        moneyText.text = playerClass.money.ToString();
        activePrimaryElement.sprite = player.GetPrimaryElement();
        activeCatalystElement.sprite = player.GetCatalystElement();
        activeComboElement.sprite = player.GetComboElement();
        if (Input.GetKeyDown(KeyCode.F))
        {
            activePrimaryElement.transform.parent.parent.gameObject.SetActive(!activePrimaryElement.transform.parent.parent.gameObject.activeSelf);
            activeCatalystElement.transform.parent.parent.gameObject.SetActive(!activeCatalystElement.transform.parent.parent.gameObject.activeSelf);
            activeComboElement.transform.parent.parent.gameObject.SetActive(!activeComboElement.transform.parent.parent.gameObject.activeSelf);

        }
    }
}
