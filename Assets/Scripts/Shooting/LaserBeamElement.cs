using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeamElement : BaseElementClass
{
    [SerializeField]
    GameObject LaserBeam;
    public float damage;
    public bool laserStillOn;
    public PlayerData pData;
    // Update is called once per frame
    void Update()
    {
        base.Update();

        if (playerHand.GetCurrentAnimatorStateInfo(0).IsName("LaserBeam"))
        {
            DeactivateLaser();
        }
        
    }

    public void DeactivateLaser()
    {
        if (Input.GetKeyUp(KeyCode.Mouse0) || !PayCosts(Time.deltaTime))
        {
           LaserBeam.SetActive(false);
           playerHand.SetTrigger("LaserStopCast");
        }
    }
    public override void ElementEffect()
    {
        base.ElementEffect();
        LaserBeam.SetActive(true);
        
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
