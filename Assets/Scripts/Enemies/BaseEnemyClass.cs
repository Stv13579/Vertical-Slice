using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseEnemyClass : MonoBehaviour
{
    //base class that all enemies derive from.

    [SerializeField]
    protected EnemyData eData;
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

    
    public delegate void DeathTrigger();

    [HideInInspector]
    public List<DeathTrigger> deathTriggers = new List<DeathTrigger>();

    public Vector3 moveDirection;

    private void Start()
    {
        startY = transform.position.y;
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
        currentHealth = eData.maxHealth;
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

    }


    //Taking damage
    public void TakeDamage(float damageToTake, List<string> attackTypes)
    {
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
        currentHealth -= (damageToTake * multiplier) * eData.damageResistance - eData.damageThreshold;
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

            Destroy(gameObject);
        }
    }


    
}
