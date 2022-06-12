using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            transform.parent.GetComponent<BossSpawn>().StartFight();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        
    }
}
