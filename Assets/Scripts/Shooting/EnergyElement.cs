using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergyElement : BaseElementClass
{
    float fullRestoreAmount;
    float perTickRestore;

    private void Start()
    {
        heldCast = true;
    }

    void Update()
    {
        if(Input.GetKeyUp(KeyCode.Mouse1) & playerHand.GetCurrentAnimatorStateInfo(0).IsName(""))
        {

        }
    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        pData.mana += fullRestoreAmount;
        if(pData.mana > pData.maxMana)
        {
            pData.mana = pData.maxMana;
        }

    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);


    }
}
