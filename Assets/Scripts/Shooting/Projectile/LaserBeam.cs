using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeam : MonoBehaviour
{
    float damage;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetVars(float dmg)
    {
        damage = dmg;
    }

    private void OnTriggerStay(Collider other)
    {
        //if enemy, hit them for the damage
        Collider taggedEnemy = null;


        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage);

            taggedEnemy = other;
        }
    }
}
