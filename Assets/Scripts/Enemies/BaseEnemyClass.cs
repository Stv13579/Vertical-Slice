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


    private void Start()
    {
        startY = transform.position.y;
        player = GameObject.Find("Player");
        playerClass = player.GetComponent<PlayerClass>();
        currentHealth = eData.maxHealth;
    }

    public void Update()
    {
        Movement(player.transform.position);
        Attacking();
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
    public void TakeDamage(float damageToTake)
    {
        currentHealth -= damageToTake * eData.damageResistance - eData.damageThreshold;
        Death();
    }

    //Death
    public void Death()
    {
        if(currentHealth <= 0)
        {
            isDead = true;
            //Normally do death animation/vfx, might even fade alpha w/e before deleting.


            //Destroy for now
            spawner.GetComponent<SAIM>().spawnedEnemies.Remove(this);

            //Spawn currency
            for(int i = 0; i < Random.Range(0, 3); i++)
            {
                Instantiate(currencyDrop, this.transform.position, Quaternion.identity);
            }

            Destroy(gameObject);
        }
    }


    
}
