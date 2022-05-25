using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireSlimeEnemy : NormalSlimeEnemy
{
    public GameObject enemyTrail;
    [SerializeField]
    private LayerMask trailLayerMask;
    float trailCastDistance = 1.0f;
    float backCastDistance = 0.1f;
    float trailOffset = 0.01f;
    new private void Update()
    {
        Movement(player.transform.position);
    }

    public override void Attacking()
    {
    
        RaycastHit hit;
        Vector3 Back = new Vector3(0f, backCastDistance, 0f);
        // check of the ray cast line is hitting the ground
        if (Physics.Raycast(transform.position + Back, -transform.up, out hit, trailCastDistance + backCastDistance, trailLayerMask))
        {
            Debug.Log(hit.transform.gameObject.name);
            // rotate the go if it hits a flat surface or an angled surface
            Quaternion newrotation = Quaternion.FromToRotation(transform.up, hit.normal);
            // creates a plane which is the trail of the fire slime
            GameObject tempEnemyTrail = Instantiate(enemyTrail, hit.point + hit.normal * trailOffset, newrotation);
            // sets the damage
            tempEnemyTrail.GetComponent<FireSlimeTrail>().SetVars(eData.damageAmount);
        }
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(positionToMoveTo);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 100, 0);
        }
        Attacking();
    }

    private void OnCollisionStay(Collision collision)
    {
        if (GetComponent<Rigidbody>().velocity.y < 10)
        {
            GetComponent<Rigidbody>().AddForce(0, 100, 0);
        }
    }
}
