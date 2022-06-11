using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergyElement : BaseElementClass
{
    [SerializeField]
    float fullRestoreAmount;
    float perTickRestore;

    private void Start()
    {
        base.Start();
        heldCast = true;
    }

    protected override void Update()
    {
        if(Input.GetKeyUp(KeyCode.Mouse1) & playerHand.GetCurrentAnimatorStateInfo(0).IsName("EnergyCast"))
        {
            playerHand.SetTrigger("StopEnergy");
            audioManager.Stop("Energy Element");
        }
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

        audioManager.Play("Energy Element");


    }
}
