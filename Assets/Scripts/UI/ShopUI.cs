using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShopUI : MonoBehaviour
{
    List<Item> shopItems;
    public List<GameObject> buttons;
    ItemList items;
    PlayerClass player;
    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<PlayerClass>();
        int itemsAdded = 0;
        int exitCounter = 0;
        while(itemsAdded < 3)
        {
            int i = Random.Range(0, items.itemList.Count);
            if(!items.itemList[i].alreadyAdded || (items.itemList[i].alreadyAdded && items.itemList[i].mulipleAllowed))
            {
                items.itemList[i].item.sprite = items.itemList[i].sprite;
                shopItems[itemsAdded] = items.itemList[i].item;
                items.itemList[i].SetAdded();
                itemsAdded += 1;
            }
            exitCounter++;
            if(exitCounter > 50)
            {
                //to do, have default items get added (npc items mot likely)
                Debug.Log("Exited");
                itemsAdded = 3;
            }
        }
        for(int i = 0; i < 3; i++)
        {
            buttons[i].transform.GetChild(0).GetComponent<Text>().text = shopItems[i].itemName;
            buttons[i].transform.GetChild(1).GetComponent<Image>().sprite = shopItems[i].sprite;
        }
    }

    public void Button1()
    {
        if(player.money > shopItems[0].currencyCost)
        {
            player.AddItem(shopItems[0]);
            buttons[0].SetActive(false);
            player.ChangeMoney(-shopItems[0].currencyCost);
        }
    }

    public void Button2()
    {
        if (player.money > shopItems[1].currencyCost)
        {
            player.AddItem(shopItems[1]);
            buttons[1].SetActive(false);
            player.ChangeMoney(-shopItems[1].currencyCost);
        }
    }

    public void Button3()
    {
        if (player.money > shopItems[2].currencyCost)
        {
            player.AddItem(shopItems[2]);
            buttons[2].SetActive(false);
            player.ChangeMoney(-shopItems[2].currencyCost);
        }
    }
}
