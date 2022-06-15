using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergyElement : BaseElementClass
{
    [SerializeField]
    float fullRestoreAmount;
    float perTickRestore;

    private float previousHealth = 0.0f;

    private void Start()
    {
        base.Start();
        heldCast = true;
    }

    protected override void Update()
    {

        if (previousHealth > playerClass.currentHealth)
        {
            playerHand.SetTrigger("StopEnergy");
            audioManager.Stop("Energy Element");
        }

        if (Input.GetKeyUp(KeyCode.Mouse1) & playerHand.GetCurrentAnimatorStateInfo(0).IsName("Hold"))
        {
            playerHand.SetTrigger("StopEnergy");
            audioManager.Stop("Energy Element");
        }

        previousHealth = playerClass.currentHealth;
    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        playerClass.ChangeMana(fullRestoreAmount);
        playerHand.SetTrigger("StopEnergy");
        audioManager.Stop("Energy Element");
    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);

        playerHand.SetTrigger(animationName);
        playerHand.ResetTrigger("StopEnergy");
        audioManager.Play("Energy Element");


    }
}
