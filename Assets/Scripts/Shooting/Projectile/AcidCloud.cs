using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcidCloud : MonoBehaviour
{
    float damage;

    float cloudSize;

    float cloudDuration;

    List<string> attackTypes;
    void Update()
    {
        if(transform.localScale.x < cloudSize)
        {
            //Makes the acid cloud grow over time, up to the preset maximum size
            transform.localScale += new Vector3(Time.deltaTime, Time.deltaTime, Time.deltaTime);
        }

        cloudDuration -= Time.deltaTime;
        if(cloudDuration <= 0)
        {
            Destroy(this.gameObject);
        }
    }

    public void SetVars(float dmg, float size, float duration, List<string> types)
    {
        //Set up the variables according to the element script
        damage = dmg;
        cloudSize = size;
        cloudDuration = duration;
        attackTypes = types;
    }

    private void OnTriggerStay(Collider other)
    {
        if(other.GetComponent<BaseEnemyClass>())
        {
            //If an enemy is inside the cloud, deal damage to it
            other.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);
        }
    }
}
