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
    public GameObject handVFX;

    //VFX that appears around the wrist while this element is active (Mostly unused)
    [SerializeField]
    public GameObject wristVFX = null;

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
    [SerializeField]
    protected Animator playerHandL;

    float currentUseDelay = 0;

    //Variables for UI purposes
    public string elementName;
    public Sprite uiSprite;
    public Sprite crosshair;

    [SerializeField]
    protected List<BaseEnemyClass.Types> attackTypes;
    GameObject player;
    [SerializeField]

    protected PlayerClass playerClass;

    [SerializeField]
    protected Transform shootingTranform;
    [SerializeField]
    protected LayerMask shootingIgnore;

    protected AudioManager audioManager;

    [SerializeField]
    string shootingSoundFX;

    protected virtual void Start()
    {
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
        //shootingTranform = GameObject.Find("Elements").transform;
        audioManager = FindObjectOfType<AudioManager>();
    }
    protected virtual void StartAnims(string animationName)
    {
        playerHand.SetTrigger("CancelBack");
    }

    //Called from the hand objects when the appropriate event triggers to turn on the vfx
    public virtual void ActivateVFX()
    {

    }

    //The actual mechanical effect (eg fire object etc)
    public virtual void ElementEffect()
    {
        audioManager.Stop(shootingSoundFX);
        audioManager.Play(shootingSoundFX);
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
            //Set out of mana anim
            playerHand.SetTrigger("NoMana");
            playerHandL.SetTrigger("NoMana");
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
