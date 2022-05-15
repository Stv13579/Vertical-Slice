using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcidCloud : MonoBehaviour
{
    float damage;

    float cloudSize;

    float cloudDuration;

    void Update()
    {
        if(transform.localScale.x < cloudSize)
        {
            transform.localScale += new Vector3(Time.deltaTime, Time.deltaTime, Time.deltaTime);
        }

        cloudDuration -= Time.deltaTime;
        if(cloudDuration <= 0)
        {
            Destroy(this.gameObject);
        }
    }

    public void SetVars(float dmg, float size, float duration)
    {
        damage = dmg;
        cloudSize = size;
        cloudDuration = duration;
    }

    private void OnTriggerStay(Collider other)
    {
        if(other.GetComponent<BaseEnemyClass>())
        {
            other.GetComponent<BaseEnemyClass>().TakeDamage(damage);
        }
    }
}
