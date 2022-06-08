using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalSlimeEnemy : BaseEnemyClass
{
    float damageTicker = 0.0f;

    [SerializeField]
    float jumpForce;
    public override void Start()
    {
        base.Start();
        
    }

    // need to work on
    public override void Attacking()
    {
        base.Attacking();
        playerClass.ChangeHealth(-damageAmount);
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(moveDirection);

        //Come back to hopping
        Vector3 moveVec = (moveDirection - transform.position).normalized * moveSpeed * Time.deltaTime;
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
            audioManager.Stop("Slime Bounce");
            audioManager.Play("Slime Bounce");
            GetComponent<Rigidbody>().AddForce(0, jumpForce, 0);
        }
        // if colliding with player attack enemy reset damage ticker
        // we reset it so that the player doesn't take double damage
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
            audioManager.Stop("Slime Bounce");
            audioManager.Play("Slime Bounce");
            GetComponent<Rigidbody>().AddForce(0, jumpForce, 0);
        }

        // checks if colliding with player and damage ticker is less then 0
        // player should take damage every one second after if they are still colliding with enemy normal slime
        if (collision.gameObject.tag == "Player" && damageTicker <= 0.0f)
        {
            Attacking();
            damageTicker = 1.0f;
        }
    }
}
