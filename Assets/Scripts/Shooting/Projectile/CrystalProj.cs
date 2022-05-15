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
        if(damageLifeTimer > 2)
        {
            damageLifeTimer -= Time.deltaTime;
        }
        if(startLifeTimer > 0)
        {
            startLifeTimer -= Time.deltaTime;
        }
        damage -= damageCurve.Evaluate(startLifeTimer - damageLifeTimer) * Time.deltaTime;
        MoveCrystalProjectile();
        KillProjectile();
    }
    private void MoveCrystalProjectile()
    {
        Vector3 projMovement = transform.forward * speed * Time.deltaTime;
        transform.position += projMovement;
    }
    //setter to set the varibles
    public void SetVars(float spd, float dmg, AnimationCurve dmgCurve, float stLifeTimer)
    {
        speed = spd;
        damage = dmg;
        damageCurve = dmgCurve;
        startLifeTimer = stLifeTimer;
    }
    private void KillProjectile()
    {
        if (startLifeTimer <= 0)
        {
            Destroy(gameObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        //if enemy, hit them for the damage
        Collider taggedEnemy = null;


        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage);

            taggedEnemy = other;

            Destroy(gameObject);
        }

    }
}
