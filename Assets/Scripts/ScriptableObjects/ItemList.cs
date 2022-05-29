using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;
using UnityEditor;

[CreateAssetMenu(fileName = "Item List")]
//Scriptable Object to store all items in for access elsewhere

//Struct containing an Item item, a bool of whether that item has been added to the player already, and a bool of whether multiple of hat item can be added to the player

[Serializable]
public class ItemEntry
{
    public string item;
    //[HideInInspector]
    public bool alreadyAdded;
    public bool mulipleAllowed;
    public Sprite sprite;
}


public class ItemList : ScriptableObject
{
    public List<ItemEntry> itemList;
}
