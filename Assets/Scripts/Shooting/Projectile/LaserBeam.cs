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
    [SerializeField]
    private GameObject laserBeamEffectParticle;

    public bool isHittingObj;

    public LayerMask layerMask;
    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
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

        RaycastHit hit;
        // 20 because thats how long the capsule and laser beam are
        // physics raycast to check if the laser is hitting the ground or enemies
        if (Physics.Raycast(laserBeamEffectParticle.transform.position, laserBeamEffectParticle.transform.forward, out hit, 20.0f, layerMask))
        {
            laserBeamEndParticle.transform.position = hit.point;
            laserBeamEffectParticle.GetComponentInChildren<LineRenderer>().SetPosition(1, new Vector3(0, 0, hit.distance));
            this.gameObject.transform.localScale = new Vector3(0, hit.distance, 0);
        }
        else
        {
            laserBeamEffectParticle.GetComponentInChildren<LineRenderer>().SetPosition(1, new Vector3(0, 0, 20));
            this.gameObject.transform.localScale = new Vector3(0, 20, 0);
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
