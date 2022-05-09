using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalProj : MonoBehaviour
{
    float speed;
    float damage;
    AnimationCurve damageCurve;
    float damageLifeTimer;
    float startLifeTimer;

    // Update is called once per frame
    void Update()
    {
        if(damageLifeTimer > 0)
        {
            damageLifeTimer -= Time.deltaTime;
        }
        Vector3 projMovement = transform.forward * speed * Time.deltaTime;
        damage -= damageCurve.Evaluate(startLifeTimer - damageLifeTimer) * Time.deltaTime;

        transform.position += projMovement;
    }

    public void SetVars(float spd, float dmg, AnimationCurve dmgCurve, float stLifeTimer)
    {
        speed = spd;
        damage = dmg;
        damageCurve = dmgCurve;
        startLifeTimer = stLifeTimer;
    }

    private void OnTriggerEnter(Collider other)
    {
        
    }
}
