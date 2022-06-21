using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoulElement : BaseElementClass
{
    // Amount of health to restore
    public float healthRestore;

    //Cached health from previous frame
    private float previousHealth = 0.0f;

    [SerializeField]
    private GameObject chargeVFX;
    // Update is called once per frame
    protected override void Update()
    {
        base.Update();

        //Checking if the player has taken damage, which cancels the spell
        if(previousHealth > playerClass.currentHealth && ((playerHand.GetCurrentAnimatorStateInfo(0).IsName("Hold") || playerHand.GetCurrentAnimatorStateInfo(0).IsName("Start Hold"))))
        {
            playerHand.SetTrigger("SoulStopCast");
            audioManager.Stop("Soul Element");
            Destroy(playerClass.gameObject.GetComponent<Shooting>().GetRightOrbPos().GetChild(1).gameObject);

        }
        else
        {
            previousHealth = playerClass.currentHealth;
        }

        //Checking if the mouse button has been released, which cancels the spell
        if(Input.GetKeyUp(KeyCode.Mouse1) && (playerHand.GetCurrentAnimatorStateInfo(0).IsName("Hold") || playerHand.GetCurrentAnimatorStateInfo(0).IsName("Start Hold")))
        {
            playerHand.SetTrigger("SoulStopCast");
            audioManager.Stop("Soul Element");
            Destroy(playerClass.gameObject.GetComponent<Shooting>().GetRightOrbPos().GetChild(1).gameObject);

        }
        previousHealth = playerClass.currentHealth;

    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        //Subtract the mana cost and restore health
        playerClass.ChangeMana(-manaCost);
        playerClass.ChangeHealth(healthRestore);
        playerHand.SetTrigger("SoulStopCast");
        audioManager.Stop("Soul Element");
        Destroy(playerClass.gameObject.GetComponent<Shooting>().GetRightOrbPos().GetChild(1).gameObject);
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
        audioManager.Play("Soul Element");
        Instantiate(chargeVFX, playerClass.gameObject.GetComponent<Shooting>().GetRightOrbPos());

    }

    protected override bool PayCosts(float modifier = 1)
    {
        //Override of paycosts so that mana is only subtracted at then end, in case the cast is cancelled
        if (playerClass.currentMana >= manaCost)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
