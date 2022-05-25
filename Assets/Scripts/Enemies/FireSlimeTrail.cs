using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireSlimeTrail : MonoBehaviour
{
    float trailDamage;
    float trailDuration = 5.0f;
    float trailDamageTicker = 1.0f;

    // Update is called once per frame
    void Update()
    {
        trailDuration -= Time.deltaTime;
        trailDamageTicker -= Time.deltaTime;
        // deletes the trail after 3 seconds
        if(trailDuration <= 0)
        {
            Destroy(gameObject);
        }
    }

    public void SetVars(float damage)
    {
        trailDamage = damage;
    }

    // player takes damage when entering the trail
    private void OnTriggerEnter(Collider other)
    {
        if(other.GetComponent<PlayerClass>())
        {
            other.GetComponent<PlayerClass>().ChangeHealth(-trailDamage);
        }
    }

    // player takes damage over time when they are still in the trail
    private void OnTriggerStay(Collider other)
    {
        if (other.GetComponent<PlayerClass>())
        {
            if(trailDamageTicker <= 0)
            {
                other.GetComponent<PlayerClass>().ChangeHealth(-trailDamage);
                trailDamageTicker = 1.0f;
            }
        }
    }
}
