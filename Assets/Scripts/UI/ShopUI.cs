using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShopUI : MonoBehaviour
{
    List<Item> shopItems = new List<Item>();
    public List<GameObject> buttons;
    public ItemList items;
    PlayerClass player;
    GameObject inventory;
    List<int> ids = new List<int>();
    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<PlayerClass>();
        inventory = GameObject.Find("Player").transform.GetChild(2).gameObject;

        int itemsAdded = 0;
        int exitCounter = 0;
        while(itemsAdded < 3)
        {
            
            int i = Random.Range(0, items.itemList.Count);
            Item item = (Item)this.gameObject.AddComponent(System.Type.GetType(items.itemList[i].item));
            if(!items.itemList[i].alreadyAdded || (items.itemList[i].alreadyAdded && items.itemList[i].mulipleAllowed))
            {

                item.sprite = items.itemList[i].sprite;
                shopItems.Add(item);
                ids.Add(i);
                items.itemList[i].SetAdded();
                itemsAdded += 1;
            }
            exitCounter++;
            if(exitCounter > 50)
            {
                //to do, have default items get added (npc items most likely)
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

    public void Button(int button)
    {
        if(player.money >= shopItems[button].currencyCost)
        {
            Item item = (Item)inventory.AddComponent(shopItems[button].GetType());
            item.sprite = shopItems[button].sprite;
            Destroy(shopItems[button]);
            items.itemList[ids[button]].SetAdded();

            player.AddItem(item);
            buttons[button].SetActive(false);
            player.ChangeMoney(-item.currencyCost);
        }
    }
}
