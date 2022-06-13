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

    [SerializeField]
    private GameObject laserBeamEndParticle;

    private GameObject laserBeamEffectParticle;

    bool isHittingObj;

    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
        laserBeamEndParticle = GameObject.Find("VFX_Laser_BeamHitImpact");
        laserBeamEffectParticle = GameObject.Find("VFX_Laser_BeamPos");
        isHittingObj = false;
    }
    // Update is called once per frame
    void Update()
    {
        if(isHittingObj == true)
        {
            laserBeamEndParticle.SetActive(true);
        }
        else
        {
            laserBeamEndParticle.SetActive(false);
        }
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
        if(other.tag == "Enemy" || other.tag == "Environment")
        {
            isHittingObj = true;
            laserBeamEndParticle.transform.position = other.gameObject.transform.position;

            Debug.Log("DesNUTS");
        }

        if (other.tag == "Enemy" && !containedEnemies.Contains(other.gameObject))
        { 
            containedEnemies.Add(other.gameObject);
            audioManager.Stop("Slime Damage");
            audioManager.Play("Slime Damage");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Enemy" || other.tag == "Environment")
        {
            isHittingObj = false;
        }
        if (containedEnemies.Contains(other.gameObject))
        {
            containedEnemies.Remove(other.gameObject);
        }
    }
}
