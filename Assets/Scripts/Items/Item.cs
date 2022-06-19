using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

[Serializable]
public class Item : MonoBehaviour
{
    GameObject UIWidget;
    public float currencyCost;
    public Sprite[] sprites;
    public string itemName = "";
    public string description = "";


    //Any effects from obtaining an item go here e.g. if the item increases max health, add it here.
    public virtual void AddEffect(PlayerClass player)
    {
        //UIWidget = new GameObject("ItemWidget", typeof(RectTransform), typeof(Image));
        //UIWidget.GetComponent<Image>().sprite = sprite;
        //UIWidget.transform.SetParent(player.itemUI.transform);
        //UIWidget.GetComponent<RectTransform>().anchoredPosition = new Vector2(0,0);
        player.itemUI.transform.parent.gameObject.GetComponent<GameplayUI>().AddItem(sprites);
        player.heldItems.Add(this);

    }

    //Called by certain actions which might trigger an item effect e.g. a particular attack.
    public virtual void TriggeredEffect()
    {

    }

    public virtual void DeathTriggers()
    {

    }
}
