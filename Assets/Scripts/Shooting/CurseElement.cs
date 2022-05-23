using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CurseElement : BaseElementClass
{
    bool targeting = false;

    LayerMask curseTargets;

    [SerializeField]
    float range;

    GameObject targetToCurse;

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        targeting = true;

    }

    public override void ElementEffect()
    {
        base.ElementEffect();

        //curse the target

        //Attach an effect to it

        //
    }

    protected override void Update()
    {
        base.Update();

        if(targeting)
        {
            

            RaycastHit rayHit;

            if(Physics.Raycast(Camera.main.transform.position, Camera.main.transform.forward, out rayHit, range, curseTargets))
            {
               targetToCurse = rayHit.collider.gameObject;
            }
        }
    }
}
