using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcidCloudElement : BaseElementClass
{
    //Creates a cloud of acid, which deals damage over time to enemies within the cloud

    [SerializeField]
    GameObject cloudProj;

    public float damage;

    public float cloudSize;

    public float cloudDuration;

    void Update()
    {
        base.Update();
    }
    public override void ElementEffect()
    {
        base.ElementEffect();
        //
        Vector3 camLook = Camera.main.transform.forward;
        camLook = new Vector3(camLook.x, 0.0f, camLook.z).normalized;
        GameObject newShard = Instantiate(cloudProj, transform.position + (camLook * 3), Quaternion.identity);
        newShard.GetComponent<AcidCloud>().SetVars(damage, cloudSize, cloudDuration);
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
