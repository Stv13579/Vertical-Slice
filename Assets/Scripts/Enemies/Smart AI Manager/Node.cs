using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Node : MonoBehaviour
{

    bool alive = true;

    public int cost = 1;
    public int bestCost = int.MaxValue;

    public Vector2Int gridIndex;

    public Vector3 bestNextNodePos = Vector3.zero;

    public void SetDestination()
    {
        cost = 0;
        bestCost = 0;
    }

    public void ResetNode()
    {
        cost = 1;
        bestCost = int.MaxValue;
    }

    public void SetAlive(bool set)
    {
        alive = set;
    }

    public bool GetAlive()
    {
        return alive;
    }

    private void Update()
    {
        if(bestNextNodePos != Vector3.zero)
        {
            Debug.DrawRay(transform.position, bestNextNodePos - transform.position, Color.green);
        }
        
        //GetComponentInChildren<TextMeshPro>().text = bestCost.ToString();
    }
}
