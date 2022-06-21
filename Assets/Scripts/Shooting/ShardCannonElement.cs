using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShardCannonElement : BaseElementClass
{
    //A high speed attack with a big delay between shots and a high mana cost.
    //A single high damage accurate crystal projectile.
    //Can cause collateral damage to targets beyond the first (pierces through).

    //Click to fire (if we have the mana/not in delay)
    //Instantiate the projectile in the right direction etc.
    [SerializeField]
    GameObject shardProj;

    [SerializeField]
    float damage;
    public float damageMultiplier = 1;

    [SerializeField]
    float projectileSpeed;

    protected override void Update()
    {
        base.Update();


    }

    //Fires the shard, passing damage, speed etc
    public override void ElementEffect()
    {
        base.ElementEffect();
        //

        Quaternion rot = Camera.main.transform.rotation;
        rot = rot * Quaternion.Euler(90, 0, 0);

        //rot.SetEulerAngles(rot.eulerAngles.x + 90, rot.eulerAngles.y, rot.eulerAngles.z);
        GameObject newShard = Instantiate(shardProj, shootingTranform.position, rot);
        newShard.GetComponent<ShardProjectile>().SetVars(projectileSpeed, damage * damageMultiplier, attackTypes);
    }

    public override void ActivateVFX()
    {
        base.ActivateVFX();


    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);
        playerHandL.SetTrigger(animationName);

    }
}
