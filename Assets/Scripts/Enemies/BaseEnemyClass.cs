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

    float currentHealth;
    bool isDead = false;
    protected GameObject player;

    protected PlayerClass playerClass;

    [SerializeField]
    GameObject currencyDrop;

    float startY;

    [HideInInspector]
    public GameObject spawner;

    [SerializeField]
    List<string> weaknesses, resistances;

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

    [SerializeField]
    string attackAudio;
    [SerializeField]
    string deathAudio;
    [SerializeField]
    string takeDamageAudio;


    [SerializeField]
    string audioToPlay;

    public virtual void Start()
    {
        startY = transform.position.y;
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
        currentHealth = maxHealth;
        audioManager = FindObjectOfType<AudioManager>();
    }

    public virtual void Update()
    {
        if(transform.position.y < -30)
        {
            Death();
            currentHealth = 0;
        }
    }

    //Movement
    public virtual void Movement(Vector3 positionToMoveTo)
    {
        

        
    }


    //Attacking
    public virtual void Attacking()
    {
        audioManager.Stop(attackAudio);
        audioManager.Play(attackAudio);
    }


    //Taking damage
    public void TakeDamage(float damageToTake, List<string> attackTypes)
    {
        Instantiate(hitSpawn, transform.position, Quaternion.identity);
        float multiplier = 1;
        foreach(string type in attackTypes)
        {
            foreach (string weak in weaknesses)
            {
                if(weak == type)
                {
                    multiplier *= 2; 
                }
            }
            foreach (string resist in resistances)
            {
                if(resist == type)
                {
                    multiplier *= 0.5f;
                }
            }
        }
        currentHealth -= (damageToTake * multiplier) * damageResistance - damageThreshold;
        audioManager.Stop(takeDamageAudio);
        audioManager.Play(takeDamageAudio);
        Death();
    }

    //Death
    public void Death()
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
            for(int i = 0; i < Random.Range(0, 3); i++)
            {
                Instantiate(currencyDrop, this.transform.position, Quaternion.identity);
            }

            //Death triggers
            foreach (DeathTrigger dTrigs in deathTriggers)
            {
                dTrigs();
            }

            Instantiate(deathSpawn, transform.position, Quaternion.identity);
<<<<<<< Updated upstream
             
=======

            audioManager.Stop(deathAudio);
            audioManager.Play(deathAudio);
>>>>>>> Stashed changes
            Destroy(gameObject);
        }
    }


    
}
