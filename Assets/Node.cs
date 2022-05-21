using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{

    bool alive = true;

    public void SetAlive(bool set)
    {
        alive = set;
    }

    public bool GetAlive()
    {
        return alive;
    }
}
