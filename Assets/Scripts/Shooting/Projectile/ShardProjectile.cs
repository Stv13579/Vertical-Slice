using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShardProjectile : MonoBehaviour
{
    float speed;

    float damage;

    int pierceAmount;



    void Start()
    {

    }

    void Update()
    {
        

        Vector3 movement = transform.up * speed * Time.deltaTime;

        transform.position += movement;



    }

    public void SetVars(float spd, float dmg)
    {
        speed = spd;
        damage = dmg;
    }


    private void OnTriggerEnter(Collider other)
    {


        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage);


        }

        if (other.gameObject.tag != "Player")
        {
            if(pierceAmount > 0)
            {
                pierceAmount--;
            }
            else
            {
                Destroy(gameObject);
            }            
        }


    }
}
