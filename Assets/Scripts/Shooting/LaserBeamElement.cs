using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeamElement : BaseElementClass
{
    [SerializeField]
    GameObject LaserBeam;

    [SerializeField]
    float damage;
    public float damageMultiplier = 1;

    public bool usingLaserBeam;
    // Update is called once per frame
    protected override void Update()
    {
        base.Update();

        if (playerHand.GetCurrentAnimatorStateInfo(0).IsName("LaserBeam"))
        {
            DeactivateLaser();
        }
        
    }

    public void DeactivateLaser()
    {
        //if left click is up or if player has no mana
        // stop the laser beam
        if (Input.GetKeyUp(KeyCode.Mouse0) || !PayCosts(Time.deltaTime))
        {
            usingLaserBeam = false;
           LaserBeam.SetActive(false);
           playerHand.SetTrigger("LaserStopCast");
        }
    }
    public override void ElementEffect()
    {
        base.ElementEffect();
        usingLaserBeam = true;
        LaserBeam.SetActive(true);
        LaserBeam.GetComponentInChildren<LaserBeam>().SetVars(damage * damageMultiplier, attackTypes);

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
