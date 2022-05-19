using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

[Serializable]
public class Item 
{
    GameObject UIWidget;
    float currencyCost;

    public Item(GameObject uiWidge)
    {
        UIWidget = uiWidge;
    }

    //Any effects from obtaining an item go here e.g. if the item increases max health, add it here.
    public virtual void AddEffect(PlayerClass player)
    {
        UIWidget.transform.SetParent(player.itemUI.transform);
        UIWidget.GetComponent<RectTransform>().anchoredPosition = new Vector2(0,0);
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
