using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShardProjectile : MonoBehaviour
{
    float speed;

    float damage;

    int pierceAmount;

    List<BaseEnemyClass.Types> attackTypes;

    AudioManager audioManager;

    [SerializeField]
    GameObject impactSpawn;

    void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }

    void Update()
    {
        

        Vector3 movement = transform.up * speed * Time.deltaTime;

        transform.position += movement;



    }

    public void SetVars(float spd, float dmg, List<BaseEnemyClass.Types> types)
    {
        speed = spd;
        damage = dmg;
        attackTypes = types;

    }


    private void OnTriggerEnter(Collider other)
    {


        if (other.tag == "Enemy")
        {
            other.gameObject.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);
            audioManager.Stop("Slime Damage");
            audioManager.Play("Slime Damage");
        }

        if (other.gameObject.tag != "Player")
        {
            Instantiate(impactSpawn, transform.position, Quaternion.identity);
            if (pierceAmount > 0)
            {
                pierceAmount--;
            }
            else
            {
                
                Destroy(gameObject);
            }            
        }


    }
}
