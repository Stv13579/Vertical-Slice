using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerClass : MonoBehaviour
{
    public PlayerData pData;
    public float currentHealth;
    public float currentMana;
    public float money;

    //A list of items which are collectible objects which add extra effects to the player
    public List<Item> heldItems = new List<Item>();

    [HideInInspector]
    public GameObject itemUI;

    //public GameObject testItemUIWidget;

    void Start()
    {
        currentHealth = pData.maxHealth;
        currentMana = pData.maxMana;
        money = 0.0f;
        itemUI = GameObject.Find("ItemArray");

        //TEST IMPLEMENTATION

        //Item newItem = new Item(Instantiate(testItemUIWidget));

        //AddItem(newItem);
    }

    void Update()
    {
        if (transform.position.y <= -30)
        {
            Death();
        }
    }

    public void AddItem(Item newItem)
    {
        //Other functionality.
        newItem.AddEffect(this); 
    }

    void Death()
    {
        for (int i = 0; i < heldItems.Count; i++)
        {
            heldItems[i].DeathTriggers();
        }
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
       
    }

    public void ChangeHealth(float healthAmount)
    {
        currentHealth = Mathf.Min(currentHealth + healthAmount, pData.maxHealth);
        if(currentHealth <= 0)
        {
            Death();
        }
    }
}
