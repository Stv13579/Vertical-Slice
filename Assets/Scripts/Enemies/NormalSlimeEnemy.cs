using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalSlimeEnemy : BaseEnemyClass
{
    float damageTicker = 0.0f;
    // need to work on
    public override void Attacking()
    {
        base.Attacking();
        playerClass.ChangeHealth(-eData.damageAmount);
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(moveDirection);

        //Come back to hopping
        Vector3 moveVec = (moveDirection - transform.position).normalized * eData.moveSpeed * Time.deltaTime;
        moveVec.y = 0;
        moveVec.y -= 1 * Time.deltaTime;
        transform.position += moveVec;



        transform.LookAt(player.transform.position);
        Quaternion rot = transform.rotation;
        rot.eulerAngles = new Vector3(0, rot.eulerAngles.y + 135, 0);
        transform.rotation = rot;
        
    }

    protected virtual void Update()
    {
        base.Update();
        Movement(player.transform.position);
        damageTicker -= Time.deltaTime;
    }

    public virtual void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10 && collision.gameObject.layer == 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 50, 0);
        }

        if (collision.gameObject.tag == "Player")
        {
            Attacking();
            damageTicker = 1.0f;
        }
    }
    public virtual void OnCollisionStay(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10 && collision.gameObject.layer == 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 50, 0);
        }

        if (collision.gameObject.tag == "Player" && damageTicker <= 0.0f)
        {
            Attacking();
            damageTicker = 1.0f;
        }
    }

}
