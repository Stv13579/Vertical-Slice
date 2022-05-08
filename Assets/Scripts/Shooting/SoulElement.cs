using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoulElement : BaseElementClass
{
    // Amount of health to restore
    public float healthRestore;

    //Cached health from previous frame
    private float previousHealth = 0.0f;

    //Whether the element is currently casting
    private bool casting = false;
    //Whether the element was casting las frame
    private bool wasCasting = false;
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
        if(Input.GetKeyUp(KeyCode.Mouse1))
        {
            playerHand.SetTrigger("SoulStopCast");
        }

    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        //
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
        casting = true;
    }

    protected override bool PayCosts()
    {
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
