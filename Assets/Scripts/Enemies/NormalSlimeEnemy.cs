using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalSlimeEnemy : BaseEnemyClass
{
    // need to work on
    public override void Attacking()
    {
        base.Attacking();
        playerClass.ChangeHealth(-eData.damageAmount);
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(positionToMoveTo);

        //Come back to hopping
        Vector3 moveVec = (positionToMoveTo - transform.position).normalized * eData.moveSpeed * Time.deltaTime;
        moveVec.y = 0;
        moveVec.y -= 1 * Time.deltaTime;
        transform.position += moveVec;
    }

    new private void Update()
    {
        Movement(player.transform.position);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 100, 0);
        }

        if (collision.gameObject.tag == "Player")
        {
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
