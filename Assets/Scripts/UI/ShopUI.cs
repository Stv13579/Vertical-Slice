using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ShopUI : MonoBehaviour
{
    List<Item> shopItems = new List<Item>();
    public List<GameObject> buttons;
    public ItemList items;
    PlayerClass player;
    GameObject inventory;
    List<int> ids = new List<int>();

    public TextMeshProUGUI moneyText;

    [HideInInspector]
    public ShopkeeperScript shopkeeper;

    private AudioManager audioManager;
    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
        player = GameObject.Find("Player").GetComponent<PlayerClass>();
        inventory = GameObject.Find("Player").transform.GetChild(2).gameObject;

        //For vertical slice purposes, remove for full game
        foreach(ItemEntry item in items.itemList)
        {
            item.alreadyAdded = false;
        }

        int itemsAdded = 0;
        int exitCounter = 0;
        while(itemsAdded < 3)
        {
            //Get a random item from the global item list, check if the item is valid to give to the player, and if so add it, otherwise try again
            int i = Random.Range(0, items.itemList.Count);
            Item item = (Item)this.gameObject.AddComponent(System.Type.GetType(items.itemList[i].item));
            if(!items.itemList[i].alreadyAdded || (items.itemList[i].alreadyAdded && items.itemList[i].mulipleAllowed))
            {
                item.sprites = items.itemList[i].sprites;
                item.itemName = items.itemList[i].itemName;
                item.currencyCost = items.itemList[i].price;
                item.description = items.itemList[i].description;
                shopItems.Add(item);
                ids.Add(i);
                items.itemList[i].alreadyAdded = true;
                itemsAdded += 1;
            }
            else
            {
                Destroy(item);
            }
            exitCounter++;
            if(exitCounter > 50)
            {
                //If the loop goes on too long, place default items

                //to do, have default items get added (npc items most likely)
                Debug.Log("Exited");
                itemsAdded = 3;
            }
        }
        for(int i = 0; i < 3; i++)
        {
            //Give the UI buttons the necessary information for each item they contain
            buttons[i].transform.GetChild(0).GetChild(0).GetComponent<TextMeshProUGUI>().text = shopItems[i].itemName;
            buttons[i].transform.GetChild(0).GetChild(1).GetComponent<Image>().sprite = shopItems[i].sprites[0];
            buttons[i].transform.GetChild(0).GetChild(1).GetChild(0).GetComponent<Image>().sprite = shopItems[i].sprites[1];
            buttons[i].transform.GetChild(0).GetChild(2).GetComponent<TextMeshProUGUI>().text = shopItems[i].currencyCost.ToString();
            buttons[i].transform.GetChild(0).GetChild(3).GetComponent<TextMeshProUGUI>().text = shopItems[i].description;
        }
    }

    private void Update()
    {
        moneyText.text = "Money: " + player.money.ToString();
    }
    public void Button(int button)
    {
        if(player.money >= shopItems[button].currencyCost)
        {
            //If he player has enough money, give the player the item, take away their money, and remove he option from the shop
            Item item = (Item)inventory.AddComponent(shopItems[button].GetType());
            item.sprites = shopItems[button].sprites;
            Destroy(shopItems[button]);
            player.AddItem(item);
            buttons[button].SetActive(false);
            player.ChangeMoney(-shopItems[button].currencyCost);
            audioManager.Stop("Shop Buy");
            audioManager.Play("Shop Buy");
        }
    }

    public void CloseShop()
    {
        for (int i = 0; i < 3; i++)
        {
            if(buttons[i].activeInHierarchy)
            {
                //If an item isn't bought when leaving the shop, mark it available to be obtained again
                items.itemList[ids[i]].alreadyAdded = false;
            }
        }
        shopkeeper.LeaveShop();
    }

}
