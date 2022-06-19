using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireCollision : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 10)
        {
            transform.parent.GetComponent<BossSlimeEnemy>().currentChargeDuration = 0;
        }
    }

    
}
