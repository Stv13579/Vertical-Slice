using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireSlimeEnemy : BaseEnemyClass
{
    public GameObject enemyTrail;
    new private void Update()
    {
        Movement(player.transform.position);
    }

    public override void Attacking()
    {
        base.Attacking();
        // creates a plane which is the trail of the fire slime
        GameObject tempEnemyTrail = Instantiate(enemyTrail, transform.position + new Vector3(0.0f, 0.1f, 0.0f), Quaternion.identity);
        // sets the damage
        tempEnemyTrail.GetComponent<FireSlimeTrail>().SetVars(eData.damageAmount);
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
            Attacking();
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
