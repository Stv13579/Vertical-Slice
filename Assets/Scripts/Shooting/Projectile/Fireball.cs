using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fireball : MonoBehaviour
{
    
    float speed;

    float damage;
    float explosionDamage;

    float gravity;

    AnimationCurve gravCurve;

    float gravityLifetime; 
    float startLifetime;

    float explosionRadii;
    void Start()
    {
        
    }

    void Update()
    {
        if(gravityLifetime > 0)
        {
            gravityLifetime -= Time.deltaTime;
        }

        Vector3 movement = transform.forward * speed * Time.deltaTime;
        gravity *= 1.01f;
        movement.y -= gravity /** gravCurve.Evaluate(startLifetime - gravityLifetime)*/ * Time.deltaTime;

        transform.position += movement;
        
    }

    public void SetVars(float spd, float dmg, float grav, AnimationCurve grCurve, float lifeTime, float explosionRadius, float expDamage)
    {
        speed = spd;
        damage = dmg;
        gravity = grav;
        gravCurve = grCurve;
        gravityLifetime = lifeTime;
        explosionRadii = explosionRadius;
        explosionDamage = expDamage;
    }



    private void OnTriggerEnter(Collider other)
    {
        //if enemy, hit them for the damage
        Collider taggedEnemy = null;
        

        if(other.tag  == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage);

            taggedEnemy = other;
        }

        if(other.gameObject.tag != "Player")
        {
            Collider[] objectsHit = Physics.OverlapSphere(transform.position, explosionRadii);

            for (int i = 0; i < objectsHit.Length; i++)
            {
                if(objectsHit[i].tag == "Enemy" && objectsHit[i] != taggedEnemy)
                {
                    objectsHit[i].GetComponent<BaseEnemyClass>().TakeDamage(explosionDamage);
                }
            }

            Destroy(gameObject);
        }


    }

}
