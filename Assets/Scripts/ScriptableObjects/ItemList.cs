using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;
using UnityEditor;

[CreateAssetMenu(fileName = "Item List")]
//Scriptable Object to store all items in for access elsewhere
public class ItemList : ScriptableObject
{
    public List<ItemEntry> itemList;
}
