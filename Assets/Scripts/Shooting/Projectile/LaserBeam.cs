using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeam : MonoBehaviour
{
    float damage;
    List<string> attackTypes;

    List<GameObject> containedEnemies = new List<GameObject>();

    [SerializeField]
    float hitDelay;
    float currentHitDelay;

    AudioManager audioManager;

    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }
    // Update is called once per frame
    void Update()
    {
        // might need later to add some juice
        currentHitDelay += Time.deltaTime;

        if(currentHitDelay > hitDelay)
        {
            currentHitDelay = 0;
            foreach (GameObject enemy in containedEnemies)
            {
                if(enemy)
                {
                    enemy.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);
                }
                else
                {
                    containedEnemies.Remove(enemy);
                }
            }
        }
    }
    // setter
    public void SetVars(float dmg, List<string> types)
    {
        damage = dmg;
        attackTypes = types;

    }

    private void OnTriggerStay(Collider other)
    {
        //if enemy, hit them for the damage

        if (other.tag == "Enemy" && !containedEnemies.Contains(other.gameObject))
        { 
            containedEnemies.Add(other.gameObject);
            audioManager.Stop("Slime Damage");
            audioManager.Play("Slime Damage");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (containedEnemies.Contains(other.gameObject))
        {
            containedEnemies.Remove(other.gameObject);
        }
    }
}
