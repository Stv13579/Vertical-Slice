using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcidCloud : MonoBehaviour
{
    float damage;

    float cloudSize;

    float cloudDuration;

    [SerializeField] GameObject acidBurnVFX;

    [SerializeField] List<BaseEnemyClass.Types> attackTypes;

    AudioManager audioManager;

    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
        audioManager.Stop("Gas Cloud (Long)");
        audioManager.Play("Gas Cloud (Long)");
    }
    void Update()
    {
        if(transform.localScale.x < cloudSize)
        {
            //Makes the acid cloud grow over time, up to the preset maximum size
            transform.localScale += new Vector3(Time.deltaTime, Time.deltaTime, Time.deltaTime);
        }

        cloudDuration -= Time.deltaTime;
        if(cloudDuration <= 1)
        {
            this.transform.parent.GetChild(0).gameObject.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmitting);
            this.transform.parent.GetChild(0).GetChild(0).gameObject.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmitting);
            this.transform.parent.GetChild(0).GetChild(1).gameObject.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmitting);
        }
        if (this.transform.parent.GetChild(0).gameObject.GetComponent<ParticleSystem>().particleCount < 100 && cloudDuration < 1)
        {
            Destroy(this.gameObject.GetComponent<Collider>());
        }
        if (this.transform.parent.GetChild(0).gameObject.GetComponent<ParticleSystem>().particleCount < 1 && cloudDuration < 1)
        {
            Destroy(this.gameObject.transform.parent.gameObject);
        }
    }

    public void SetVars(float dmg, float size, float duration, List<BaseEnemyClass.Types> types)
    {
        //Set up the variables according to the element script
        damage = dmg;
        cloudSize = size;
        cloudDuration = duration;
        attackTypes = types;
    }

    private void OnTriggerStay(Collider other)
    {
        if(other.GetComponent<BaseEnemyClass>())
        {
            //If an enemy is inside the cloud, deal damage to it
            other.GetComponent<BaseEnemyClass>().TakeDamage(damage, attackTypes);
            audioManager.Stop("Slime Damage");
            audioManager.Play("Slime Damage");
            if(other.gameObject.GetComponentInChildren<AcidBurnScript>())
            {
                other.gameObject.GetComponentInChildren<AcidBurnScript>().timer = 2.0f;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.GetComponent<BaseEnemyClass>())
        {
            //When enemy enters cloud, add vfx
            Instantiate(acidBurnVFX, other.transform);
        }
    }
}
