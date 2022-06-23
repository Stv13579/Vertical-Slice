using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseEnemyClass : MonoBehaviour
{
    public float maxHealth;
    public float damageAmount;
    public float moveSpeed;

    //The amount of flat damage any instance of incoming damage is reduced by
    public float damageThreshold;

    //The amount of percentage damage any instance of incoming damage is reduced by
    public float damageResistance = 1;

    //base class that all enemies derive from.

    protected float currentHealth;
    bool isDead = false;
    protected GameObject player;

    protected PlayerClass playerClass;

    [SerializeField]
    GameObject currencyDrop;

    float startY;

    [HideInInspector]
    public GameObject spawner;

    /// <summary>
    /// Element types for weaknesses and resists
    /// </summary>

    public enum Types
    {
        Fire,
        Crystal
    }

    [SerializeField]
    List<Types> weaknesses, resistances;

    public List<GameObject> bounceList;

    //Particle effect when the enemy is destroyed
    public GameObject deathSpawn;
    //Particle effect when the enemy is hit
    public GameObject hitSpawn;

    public delegate void DeathTrigger();

    [HideInInspector]
    public List<DeathTrigger> deathTriggers = new List<DeathTrigger>();

    public Vector3 moveDirection;
    protected AudioManager audioManager;
    protected Animator enemyAnims;

    [SerializeField]
    string attackAudio;
    [SerializeField]
    string deathAudio;
    [SerializeField]
    string takeDamageAudio;

    [SerializeField]
    GameObject targettingIndicator;

    public Vector3 oldPosition;

    public virtual void Start()
    {
        startY = transform.position.y;
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
        currentHealth = maxHealth;
        audioManager = FindObjectOfType<AudioManager>();
        oldPosition = new Vector3(-1000, -1000, -1000);
        enemyAnims = GetComponentInChildren<Animator>();

    }

    public virtual void Update()
    {
        if(transform.position.y < -30)
        {
            Death();
            currentHealth = 0;
        }

        if(transform.position.y > 100)
        {
            GetComponent<Rigidbody>().velocity = Vector3.zero;
        }
    }

    //Movement
    public virtual void Movement(Vector3 positionToMoveTo)
    {
        

        
    }

    public virtual void Movement(Vector3 positionToMoveTo, float speed)
    {



    }


    //Attacking
    public virtual void Attacking()
    {
        audioManager.Stop(attackAudio);
        audioManager.Play(attackAudio);
    }

    public virtual void TakeDamage(float damageToTake, List<Types> attackTypes, float extraSpawnScale = 1)
    {
        GameObject hitSpn = Instantiate(hitSpawn, transform.position, Quaternion.identity);
        Vector3 scale = hitSpn.transform.lossyScale * extraSpawnScale;
        hitSpn.transform.localScale = scale;
        float multiplier = 1;
        foreach (Types type in attackTypes)
        {
            foreach (Types weak in weaknesses)
            {
                if (weak == type)
                {
                    multiplier *= 2;
                }
            }
            foreach (Types resist in resistances)
            {
                if (resist == type)
                {
                    multiplier *= 0.5f;
                }
            }
        }

        enemyAnims.SetTrigger("TakeDamage");

        currentHealth -= (damageToTake * multiplier) * damageResistance - damageThreshold;
        audioManager.Stop(takeDamageAudio);
        audioManager.Play(takeDamageAudio, player.transform, this.transform);
        Death();
    }

    //Death
    public virtual void Death()
    {
        if(isDead)
        {
            return;
        }
        if(currentHealth <= 0)
        {
            isDead = true;
            //Normally do death animation/vfx, might even fade alpha w/e before deleting.



            //Destroy for now
            if(spawner)
            {
                spawner.GetComponent<SAIM>().spawnedEnemies.Remove(this);
            }


            //Spawn currency
            for(int i = 0; i < Random.Range(1, 4); i++)
            {
                Instantiate(currencyDrop, this.transform.position, Quaternion.identity);
            }

            //Death triggers
            foreach (DeathTrigger dTrigs in deathTriggers)
            {
                dTrigs();
            }

            Instantiate(deathSpawn, transform.position, Quaternion.identity);


            audioManager.Stop(deathAudio);
            audioManager.Play(deathAudio, player.transform, this.transform);

            Destroy(gameObject);
        }
    }

    public void Targetted(bool targetted, Color colour)
    {
        if(targettingIndicator.active == false && targetted == true)
        {
            targettingIndicator.SetActive(targetted);
        }
        
        if(targettingIndicator.active == true && targetted == false)
        {
            targettingIndicator.SetActive(targetted);
        }

        this.transform.GetChild(1).GetChild(1).gameObject.GetComponent<SkinnedMeshRenderer>().material.SetColor("_Outline_Colour", colour);
    }


}
