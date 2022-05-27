using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{

    bool alive = true;

    public int cost = 1;
    public int bestCost = int.MaxValue;

    public Vector2Int gridIndex;

    public void SetAlive(bool set)
    {
        alive = set;
    }

    public bool GetAlive()
    {
        return alive;
    }
}
