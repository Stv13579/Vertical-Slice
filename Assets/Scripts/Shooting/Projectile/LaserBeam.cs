using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeam : MonoBehaviour
{
    float damage;
    List<string> attackTypes;

    // Update is called once per frame
    void Update()
    {
        // might need later to add some juice
    }
    // setter
    public void SetVars(float dmg, List<string> types)
    {
        damage = dmg;
        attackTypes = types;

    }

    private void OnTriggerStay(Collider other)
    {
        //if enemy, hit them for the damage
        Collider taggedEnemy = null;

        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);

            taggedEnemy = other;
        }
    }
}
