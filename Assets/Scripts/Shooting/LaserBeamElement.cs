using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeamElement : BaseElementClass
{
    [SerializeField]
    GameObject laserBeam;

    [SerializeField]
    float damage;
    public float damageMultiplier = 1;

    public bool usingLaserBeam;
    protected override void Start()
    {
        base.Start();
    }
    // Update is called once per frame
    protected override void Update()
    {
        base.Update();

        

        if (!Input.GetKey(KeyCode.Mouse0))
        {
            usingLaserBeam = false;
            laserBeam.SetActive(false);
            playerHand.SetTrigger("LaserStopCast");
            playerHandL.SetTrigger("LaserStopCast");
            audioManager.Stop("Laser Beam");
            laserBeam.GetComponentInChildren<LaserBeam>().isHittingObj = false;
        }
        if (playerHand.GetCurrentAnimatorStateInfo(0).IsName("HoldLaser"))
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
            laserBeam.SetActive(false);
            playerHand.SetTrigger("LaserStopCast");
            playerHandL.SetTrigger("LaserStopCast");
            audioManager.Stop("Laser Beam");
            laserBeam.GetComponentInChildren<LaserBeam>().isHittingObj = false;
        }
    }
    public override void ElementEffect()
    {
        base.ElementEffect();
        usingLaserBeam = true;
        laserBeam.SetActive(true);
        laserBeam.GetComponentInChildren<LaserBeam>().SetVars(damage * damageMultiplier, attackTypes);
    }
    public override void ActivateVFX()
    {
        base.ActivateVFX();
    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);
        playerHand.ResetTrigger("LaserStopCast");
        playerHandL.ResetTrigger("LaserStopCast");
        playerHand.SetTrigger(animationName);
        playerHandL.SetTrigger(animationName);
    }
}
