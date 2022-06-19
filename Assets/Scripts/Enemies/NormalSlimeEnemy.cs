using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalSlimeEnemy : BaseEnemyClass
{
    float damageTicker = 0.0f;

    [SerializeField]
    float jumpForce;

    [SerializeField]
    protected float pushForce;

    public LayerMask viewToPlayer;

    public override void Start()
    {
        base.Start();
        
    }

    // damages the player
    // takes alway the players health
    public override void Attacking()
    {
        base.Attacking();
        playerClass.ChangeHealth(-damageAmount, transform.position, pushForce);
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(moveDirection);

        RaycastHit hit;

        Debug.DrawRay(transform.position + (Vector3.up * 10), Vector3.up /*player.transform.position - transform.position*/, Color.blue);
        if (Physics.Raycast(transform.position, player.transform.position - transform.position, out hit, Mathf.Infinity, viewToPlayer))
        {
            if (hit.collider.gameObject.tag == "Player")
            {
                Vector3 moveVec = (player.transform.position - transform.position).normalized * moveSpeed * Time.deltaTime;
                moveVec.y = 0;
                moveVec.y -= 1 * Time.deltaTime;
                transform.position += moveVec;
            }
            else
            {
                Vector3 moveVec = (moveDirection - transform.position).normalized * moveSpeed * Time.deltaTime;
                moveVec.y = 0;
                moveVec.y -= 1 * Time.deltaTime;
                transform.position += moveVec;
            }


        }
        else
        {
            Vector3 moveVec = (moveDirection - transform.position).normalized * moveSpeed * Time.deltaTime;
            moveVec.y = 0;
            moveVec.y -= 1 * Time.deltaTime;
            transform.position += moveVec;
        }



        transform.LookAt(player.transform.position);
        Quaternion rot = transform.rotation;
        rot.eulerAngles = new Vector3(0, rot.eulerAngles.y + 135, 0);
        transform.rotation = rot;
        
    }

    public override void Movement(Vector3 positionToMoveTo, float speed)
    {
        base.Movement(moveDirection);

        RaycastHit hit;

        //If they can see the player, go for it, otherwise pathfind
        Debug.DrawRay(transform.position + (Vector3.up * 10), Vector3.up /*player.transform.position - transform.position*/, Color.blue);
        if (Physics.Raycast(transform.position, player.transform.position - transform.position, out hit, Mathf.Infinity, viewToPlayer))
        {
            if(hit.collider.gameObject.tag == "Player")
            {
                Vector3 moveVec = (player.transform.position - transform.position).normalized * speed * Time.deltaTime;
                moveVec.y = 0;
                moveVec.y -= 1 * Time.deltaTime;
                transform.position += moveVec;
            }
            else
            {
                Vector3 moveVec = (moveDirection - transform.position).normalized * speed * Time.deltaTime;
                moveVec.y = 0;
                moveVec.y -= 1 * Time.deltaTime;
                transform.position += moveVec;
            }


        }
        else
        {
            Vector3 moveVec = (moveDirection - transform.position).normalized * speed * Time.deltaTime;
            moveVec.y = 0;
            moveVec.y -= 1 * Time.deltaTime;
            transform.position += moveVec;
        }




        // slime is always looking at the player
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
    
    // when the slime collides with the ground player audio for slime bounce
    // and add force to the slime so that it jumps
    public virtual void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10 && collision.gameObject.layer == 10)
        {
            audioManager.Stop("Slime Bounce");
            audioManager.Play("Slime Bounce", player.transform, this.transform);
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
            audioManager.Play("Slime Bounce", player.transform, this.transform);
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
    

    
    public virtual void OnTriggerEnter(Collider other)
    {
        // if colliding with player attack enemy reset damage ticker
        // we reset it so that the player doesn't take double damage
        if (other.gameObject.tag == "Player")
        {
            Attacking();
            damageTicker = 1.0f;
        }
    }

    public virtual void OnTriggerStay(Collider other)
    {
        // checks if colliding with player and damage ticker is less then 0
        // player should take damage every one second after if they are still colliding with enemy normal slime
        if (other.gameObject.tag == "Player" && damageTicker <= 0.0f)
        {
            Attacking();
            damageTicker = 1.0f;
        }
    }

}
