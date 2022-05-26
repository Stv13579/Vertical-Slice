﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSimeEnemy : NormalSlimeEnemy
{
    float shootTimer = 0.0f;
    public GameObject enemyProjectile;
    // Update is called once per frame
    new private void Update()
    {
        base.Update();
        CrystalSlimeAttack();
        shootTimer -= Time.deltaTime;
    }

    public override void Attacking()
    {
        base.Attacking();
    }
    public void CrystalSlimeAttack()
    {
        if (shootTimer <= 0)
        {
            // instanciates 5 projectiles above itself
            for (int i = 0; i < 5; i++)
            {
                GameObject tempEnemyProjectile = Instantiate(enemyProjectile, transform.position + new Vector3(0.0f, 3.0f, 0.0f), Quaternion.identity);
                Physics.IgnoreCollision(this.gameObject.GetComponent<Collider>(), tempEnemyProjectile.GetComponent<Collider>());
                tempEnemyProjectile.GetComponent<CrystalSlimeProjectile>().SetVars(eData.damageAmount);
                tempEnemyProjectile.transform.eulerAngles = new Vector3(tempEnemyProjectile.transform.eulerAngles.x, tempEnemyProjectile.transform.eulerAngles.y + (360.0f / 5.0f * i), tempEnemyProjectile.transform.eulerAngles.z);
            }
            shootTimer = 2.0f;
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
}
