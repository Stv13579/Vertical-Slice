using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CurseElement : BaseElementClass
{
    bool targeting = false;

    [SerializeField]
    LayerMask curseTargets;

    [SerializeField]
    float range;

    GameObject targetToCurse;

    [SerializeField]
    GameObject curseVFX;

    [SerializeField]
    float explosionRange;

    [SerializeField]
    float damage;

    [SerializeField]
    List<string> types;

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);

        targeting = true;

    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        targeting = false;
        //curse the target

        

        //Give it a death trigger
        if(targetToCurse && !targetToCurse.GetComponent<BaseEnemyClass>().deathTriggers.Contains(DeathEffect))
        {
            //Attach an effect to it
            Instantiate(curseVFX, targetToCurse.transform);
            targetToCurse.GetComponent<BaseEnemyClass>().deathTriggers.Add(DeathEffect);
        }


    }
    
    public void DeathEffect()
    {
        Collider[] hitColls = Physics.OverlapSphere(targetToCurse.transform.position, explosionRange);

        int i = 0;
        foreach (Collider hit in hitColls)
        {
            //if(hitColls[i] == )

            //i++;

            if (hit.tag == "Enemy")
            {
                hit.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage, types);
            }
        }
        Debug.Log("Explodded");
    }

    public override void LiftEffect()
    {
        base.LiftEffect();

        playerHand.SetTrigger("CurseRelease");
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
