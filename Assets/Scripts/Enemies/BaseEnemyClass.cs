using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseEnemyClass : MonoBehaviour
{
    //base class that all enemies derive from.

    [SerializeField]
    EnemyData eData;

    GameObject player;

    float startY;

    private void Start()
    {
        startY = transform.position.y;
        player = GameObject.Find("Player");
    }

    public void Update()
    {
        Movement(player.transform.position);
        Attacking();
    }

    //Movement
    public void Movement(Vector3 positionToMoveTo)
    {
        //if((positionToMoveTo - transform.position).magnitude > eData.maxHopDistance & (eData.currentHopDistance == eData.maxHopDistance))
        //{
        //    //Move instead
        //}
        //else
        //{   
            

        //}

        //Come back to hopping
        Vector3 moveVec = (positionToMoveTo - transform.position).normalized * eData.moveSpeed * Time.deltaTime;
        moveVec.y = 0;
        moveVec.y -= 1 * Time.deltaTime;
        transform.position += moveVec;
    }


    //Attacking
    public virtual void Attacking()
    {

    }


    //Taking damage
    public void TakeDamage(float damageToTake)
    {
        eData.currentHealth -= damageToTake * eData.damageResistance - eData.damageThreshold;
        Death();
    }

    //Death
    public void Death()
    {
        if(eData.currentHealth <= 0)
        {
            eData.dead = true;
            //Normally do death animation/vfx, might even fade alpha w/e before deleting.
            //Destroy for now
            Destroy(gameObject);
        }
    }


    private void OnCollisionEnter(Collision collision)
    {
        GetComponent<Rigidbody>().AddForce(0, 100, 0);
    }
}
