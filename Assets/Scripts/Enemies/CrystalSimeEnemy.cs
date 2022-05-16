using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSimeEnemy : BaseEnemyClass
{
    bool isAttack = false;
    float attackRange = 10.0f;
    float shootTimer = 0.0f;
    public GameObject enemyProjectile;
    // Update is called once per frame
    new private void Update()
    {
        Movement(player.transform.position);
        Attacking();
        shootTimer -= Time.deltaTime;
    }

    public override void Attacking()
    {
        base.Attacking();
        if (shootTimer <= 0)
        {
            for (int i = 0; i < 5; i++)
            {
                GameObject tempEnemyProjectile = Instantiate(enemyProjectile, transform.position + new Vector3(0.0f,3.0f,0.0f), Quaternion.identity);
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
        Vector3 moveVec = (positionToMoveTo - transform.position).normalized * eData.moveSpeed * Time.deltaTime;
        moveVec.y = 0;
        moveVec.y -= 1 * Time.deltaTime;
        transform.position += moveVec;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 100, 0);
        }
    }

    private void OnCollisionStay(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 100, 0);
        }
    }
}
