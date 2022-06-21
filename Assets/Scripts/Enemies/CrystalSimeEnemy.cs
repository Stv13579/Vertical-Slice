using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSimeEnemy : NormalSlimeEnemy
{
    [SerializeField]
    private float shootTimer = 0.0f;
    [SerializeField]
    private float shootTimerLength = 2.0f;
    [SerializeField]
    private GameObject enemyProjectile;
    [SerializeField]
    private Vector3 enemyProjectileScale;
    // Update is called once per frame
    new private void Update()
    {
        base.Update();
        CrystalSlimeAttack();
        shootTimer += Time.deltaTime;
    }

    public override void Attacking()
    {
        base.Attacking();
    }
    // seperate function as they have their own unique attack
    public void CrystalSlimeAttack()
    {
        if (shootTimer >= shootTimerLength)
        {
            // instanciates 5 projectiles above itself
            for (int i = 0; i < 5; i++)
            {
                GameObject tempEnemyProjectile = Instantiate(enemyProjectile, transform.position + new Vector3(0.0f, 3.0f, 0.0f), Quaternion.identity);
                // ignores physics for the with the crystal slime and the enemy crystal slime projectiles 
                Physics.IgnoreCollision(this.gameObject.GetComponent<Collider>(), tempEnemyProjectile.GetComponent<Collider>());
                // setting scale of enemy projectile based on enemy size
                tempEnemyProjectile.transform.localScale = enemyProjectileScale;
                // setter to set variables from CrystalSlimeProject
                tempEnemyProjectile.GetComponent<CrystalSlimeProjectile>().SetVars(damageAmount);
                //setting the rotations of the projectiles so that it spawns in like a circle
                tempEnemyProjectile.transform.eulerAngles = new Vector3(tempEnemyProjectile.transform.eulerAngles.x, tempEnemyProjectile.transform.eulerAngles.y + (360.0f / 5.0f * i), tempEnemyProjectile.transform.eulerAngles.z);
                audioManager.Stop("Crystal Slime Projectile");
                // play SFX
                audioManager.Play("Crystal Slime Projectile", player.transform, this.transform);
                //Play animation
                enemyAnims.SetTrigger("Shoot");
            }
            shootTimer = 0.0f;
        }
    }
    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(positionToMoveTo);

    }
    public override void OnCollisionEnter(Collision collision)
    {
        base.OnCollisionEnter(collision);
    }
    public override void OnCollisionStay(Collision collision)
    {
        base.OnCollisionStay(collision);
    }

    public override void OnTriggerEnter(Collider other)
    {
        base.OnTriggerEnter(other);
    }

    public override void OnTriggerStay(Collider other)
    {
        base.OnTriggerStay(other);
    }
}
