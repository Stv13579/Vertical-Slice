using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class BaseElementClass : MonoBehaviour
{
    //base class that all other player elements derives from

    //VFX instantiation
    //VFX that plays when the element is used (eg a fireball from fire)
    [SerializeField]
    GameObject activatedVFX;
    //VFX that appears in the hand while this element is active (perhaps nothing for combos)
    [SerializeField]
    GameObject handVFX;

    [SerializeField]
    public float manaCost;

    //A string to pass to the animator to activate appropriate triggers when 
    [SerializeField]
    string animationToPlay;

    //Whether the button needs to be held down during the cast (such as the laser)
    protected bool heldCast;

    //Cooldown/Firerate 
    //The amount of time before the element can be used again (usually brief)
    [SerializeField]
    public float useDelay;

    //Animation trigger
    //The animator which the element calls animations on
    [SerializeField]
    protected Animator playerHand;

    float currentUseDelay = 0;

    //The name of the element, for UI purposes
    public string elementName;

    [SerializeField]
    protected List<string> attackTypes;
    GameObject player;
    [SerializeField]
    protected PlayerData pData;
    protected PlayerClass playerClass;

    private void Start()
    {
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
    }
    protected virtual void StartAnims(string animationName)
    {

    }

    //Called from the hand objects when the appropriate event triggers to turn on the vfx
    public virtual void ActivateVFX()
    {

    }

    //The actual mechanical effect (eg fire object etc)
    public virtual void ElementEffect()
    {

    }

    //deduct mana from the mana pool. If unable too, return false, otherwise true
    protected virtual bool PayCosts(float modifier = 1)
    {
        if (playerClass.currentMana >= manaCost)
        {
            playerClass.currentMana -= manaCost * modifier;
            return true;
        }
        else
        {
            return false;
        }
    }

    //Activates the element, essentially the very start of everything, only if the delay has expired
    public void ActivateElement()
    {
        if (currentUseDelay <= 0)
        {
            if(PayCosts())
            {
                StartAnims(animationToPlay);
                currentUseDelay = useDelay;
            }
        }
        
    }

    //For unique behaviour when the mb is lifted while using an element
    public virtual void LiftEffect()
    {

    }

    protected virtual void Update()
    {
        if(currentUseDelay > 0)
        {
            currentUseDelay -= Time.deltaTime;
        }
    }
}
