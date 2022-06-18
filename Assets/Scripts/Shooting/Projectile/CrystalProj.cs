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

    List<BaseEnemyClass.Types> attackTypes;
    AudioManager audioManager;
    bool ismoving;
    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
        ismoving = true;
    }
    // Update is called once per frame
    void Update()
    {
        // the max drop off the damage can do is 2
        if(damage > 2)
        {
            damageLifeTimer -= Time.deltaTime;
        }
        if(startLifeTimer > 0)
        {
            startLifeTimer -= Time.deltaTime;
        }
        damage -= damageCurve.Evaluate(startLifeTimer - damageLifeTimer) * Time.deltaTime;
        if (ismoving == true)
        {
            MoveCrystalProjectile();
        }
        KillProjectile();
    }
    // move crystal projectile forwards
    private void MoveCrystalProjectile()
    {
        Vector3 projMovement = transform.forward * speed * Time.deltaTime;
        transform.position += projMovement;
    }
    //setter to set the varibles
    public void SetVars(float spd, float dmg, AnimationCurve dmgCurve, float stLifeTimer, List<BaseEnemyClass.Types> types)
    {
        speed = spd;
        damage = dmg;
        damageCurve = dmgCurve;
        startLifeTimer = stLifeTimer;
        attackTypes = types;

    }
    // if the life timer for the projectiles is 0
    // destroy the projectiles
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
        // destroy projectile after
        if (other.tag == "Environment")
        {
            ismoving = false;
        }
        Collider taggedEnemy = null;
        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);
            taggedEnemy = other;
            audioManager.Stop("Slime Damage");
            audioManager.Play("Slime Damage");
            Destroy(gameObject);
        }
    }
}
