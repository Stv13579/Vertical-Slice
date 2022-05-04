using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseElementClass : MonoBehaviour
{
    //base class that all other player elements derives from

    //Button input
    //The button to be pressed when activating the element.
    [SerializeField]
    string buttonCode;

    //Whether the button needs to be held down during the cast (such as the laser)
    bool heldCast;

    //VFX instantiation
    //VFX that plays when the element is used (eg a fireball from fire)
    [SerializeField]
    GameObject activatedVFX;
    //VFX that appears in the hand while this element is active (perhaps nothing for combos)
    [SerializeField]
    GameObject handVFX;

    //Animation trigger
    //The animtor which the element calls animations on
    Animator playerHand;

    //A string to pass to the animator to activate appropriate triggers when 
    string animationToPlay;

    //Mana cost/expenditure
    //The amount of mana per expenditure (single cost for single use, or per tick/second/rate for held elements)
    [SerializeField]
    float manaCost;

    //Cooldown/Firerate 
    //The amount of time before the element can be used again (usually brief)
    [SerializeField]
    float useDelay;
    float currentUseDelay;

    public void StartAnims()
    {

    }

    //Called from the hand objects when the appropriate even triggers to turn on the vfx
    public void ActivateVFX()
    {

    }

    //The actual mechanical effect (eg fire object etc)
    public void ElementEffect()
    {

    }

    //deduct mana from the mana pool. If unable too, return false, otherwise true
    public bool PayCosts()
    {


        return true;
    }

    //Activates the element, essentially the very start of everything, only if the delay has expired
    public void ActivateElement()
    {
        if (currentUseDelay < 0)
        {
            if(PayCosts())
            {
                StartAnims();
                currentUseDelay = useDelay;
            }
        }
        
    }

    protected void Update()
    {
        if(currentUseDelay > 0)
        {
            currentUseDelay -= Time.deltaTime;
        }
    }
}
