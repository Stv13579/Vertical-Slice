using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fireball : MonoBehaviour
{
    
    float speed;

    float damage;

    float gravity;

    AnimationCurve gravCurve;

    float gravityLifetime; 
    float startLifetime; 

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

    public void SetVars(float spd, float dmg, float grav, AnimationCurve grCurve, float lifeTime)
    {
        speed = spd;
        damage = dmg;
        gravity = grav;
        gravCurve = grCurve;
        gravityLifetime = lifeTime;
    }



    private void OnTriggerEnter(Collider other)
    {
        //if enemey, hit them for the damage

        //Destroy(gameObject);
    }

}
