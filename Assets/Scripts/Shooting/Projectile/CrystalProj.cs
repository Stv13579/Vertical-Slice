using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalProj : MonoBehaviour
{
    private float speed;
    private float damage;

    private AnimationCurve damageCurve;

    private float startLifeTimer;

    List<BaseEnemyClass.Types> attackTypes;
    private AudioManager audioManager;

    private bool ismoving;

    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
        ismoving = true;
    }
    // Update is called once per frame
    void Update()
    {
        // the max drop off the damage can do is 2
        if(damage < 1)
        {
            damage = 1;
        }
        // decrease the life of the crystal once its been shot out
        if(startLifeTimer > 0)
        {
            startLifeTimer -= Time.deltaTime;
        }
        // decrease the damage of the crystals every frame
        damage -= damageCurve.Evaluate(startLifeTimer) * Time.deltaTime;
        // moves the projectiles
        MoveCrystalProjectile();
        KillProjectile();
        Debug.Log(damage);
    }
    // move crystal projectile forwards
    private void MoveCrystalProjectile()
    {
        Vector3 projMovement = transform.forward * speed * Time.deltaTime;
        if (ismoving == true)
        { 
            transform.position += projMovement;
        }
        if(ismoving == false)
        {
            projMovement = Vector3.zero;
        }
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
        // if bullet hits the environment
        // stops it from moving
        // gets embedded in the environment
        if (other.gameObject.layer == 10)
        {
            ismoving = false;
        }
        Collider taggedEnemy = null;
        //if enemy, hit them for the damage
        // destroy projectile after
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
