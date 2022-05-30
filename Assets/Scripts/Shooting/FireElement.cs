﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireElement : BaseElementClass
{
    //A fire ball projectile attack with an arc.
    //Slightly AOE, slow fire rate, cheap cost.

    //Click to fire (if we have the mana/not in delay)
    //Instantiate the projectile in the right direction etc.
    [SerializeField]
    GameObject fireBall;

    public float damage;

    public float projectileSpeed;

    public float explosionArea;

    public float explosionDamage;

    public float gravity;

    [SerializeField]
    AnimationCurve gravCurve;

    [SerializeField]
    float gravityLifetime;

    protected override void Update()
    {
        base.Update();


    }

    //Fires the fireball, passing damage, speed, aoe etc
    public override void ElementEffect()
    {
        base.ElementEffect();
        //
        GameObject newFireball = Instantiate(fireBall, shootingTranform.position, Camera.main.transform.rotation);
        newFireball.GetComponent<Fireball>().SetVars(projectileSpeed, damage, gravity, gravCurve, gravityLifetime, explosionArea, explosionDamage, attackTypes);
    }

    public override void ActivateVFX()
    {
        base.ActivateVFX();


    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);

    }
}
