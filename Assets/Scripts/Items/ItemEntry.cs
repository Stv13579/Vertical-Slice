using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
//Data structure class for the item list, containing an Item item, a bool of whether that item has been added to the player already, a bool of whether multiple of that item can be added to the player, and the sprite to be used by that item

public class ItemEntry
{
    public string item;
    public string itemName;
    public string description;
    public int price;
    //[HideInInspector]
    public bool alreadyAdded;
    public bool mulipleAllowed;
    public Sprite[] sprites;
}
