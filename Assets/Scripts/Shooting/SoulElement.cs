using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoulElement : BaseElementClass
{
    // Amount of health to restore
    public float healthRestore;

    //Cached health from previous frame
    private float previousHealth = 0.0f;


    // Update is called once per frame
    void Update()
    {
        base.Update();

        //Checking if the player has taken damage, which cancels the spell
        if(previousHealth > pData.health)
        {
            playerHand.SetTrigger("SoulStopCast");
        }
        else
        {
            previousHealth = pData.health;
        }
        //Checking if the mouse button has been released, which cancels the spell
        if(Input.GetKeyUp(KeyCode.Mouse0))
        {
            playerHand.SetTrigger("SoulStopCast");
        }

    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        //Subtract the mana cost, restore health, and cap it and the max health
        pData.mana -= manaCost;
        pData.health += healthRestore;
        pData.health = Mathf.Min(pData.health, pData.maxHealth);
    }

    public override void ActivateVFX()
    {
        base.ActivateVFX();
    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);
        playerHand.ResetTrigger("SoulStopCast");
    }

    protected override bool PayCosts(float modifier = 1)
    {
        //Override of paycosts so that mana is only subtracted at then end, in case the cast is cancelled
        if (pData.mana >= manaCost)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
