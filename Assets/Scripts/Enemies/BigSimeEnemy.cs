using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BigSimeEnemy : NormalSlimeEnemy
{
    public List<Transform> enemyPos;
    public List<Transform> BulletPos;
    public float LookAhead = 3.0f;
    public float StepInterval = 0.25f;
    public float DangerZone = 5.0f;
    //public Transform test;

    public override void Attacking()
    {
        base.Attacking();
    }

    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(positionToMoveTo);
    }

    // Update is called once per frame
    protected override void Update()
    {
        base.Update();
    }
        //Shield();
        // Initialize bullet positions
        //List<Vector3> posArray = new List<Vector3>(BulletPos.Count);
        //for (int i = 0; i < BulletPos.Count; i++)
        //{
        //    posArray.Add((BulletPos[i].position));
        //}

        //for (int i = 0; i < BulletPos.Count; i++)
        //{
        //    for (float s = 0; s < LookAhead; s += StepInterval)
        //    {
        //        // Move bullet ahead
        //        for (int ii = 0; ii < enemyPos.Count; ii++)
        //        {

        //            if (Vector3.Distance(posArray[i], enemyPos[ii].position) < DangerZone)
        //            {
        //                test.position = posArray[i];
        //                Debug.Log("MR PRESIDENT GET DOWN");
        //                return;
        //            }
        //        }
        //        posArray[i] += 12.0f * StepInterval * BulletPos[i].forward;
        //    }
        //}


    
    //public void Shield()
    //{
    //    float minDistance = 7;
    //    float distanceBetween2Enemies = Vector3.Distance(transform.position, GetClosestObject(enemyPos).position);
    //    if (distanceBetween2Enemies < minDistance && player.GetComponentInChildren<PlayerLineOfSight>().lookTimer < 0.0f)
    //    {
    //        Vector3.MoveTowards(transform.position, GetClosestObject(enemyPos).position, 10);
    //    }
    //    else
    //    {
    //        Movement(player.transform.position);
    //    }
    //}

    //public Transform GetClosestObject(List<Transform> objectList)
    //{
    //    Transform bestTarget = null;
    //    float closestDistanceSqr = Mathf.Infinity;
    //    foreach (Transform potentialTarget in objectList)
    //    {
    //        Vector3 directionToTarget = potentialTarget.position - transform.position;
    //        float DisSqrToTarget = directionToTarget.sqrMagnitude;
    //        if (DisSqrToTarget < closestDistanceSqr)
    //        {
    //            closestDistanceSqr = DisSqrToTarget;
    //            bestTarget = potentialTarget;
    //        }
    //    }

    //    return bestTarget;
    //}

    public override void OnCollisionEnter(Collision collision)
    {
        base.OnCollisionEnter(collision);
    }

    public override void OnCollisionStay(Collision collision)
    {
        base.OnCollisionStay(collision);
    }
}
