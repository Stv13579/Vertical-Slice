using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AcidBurnScript : MonoBehaviour
{
    public float timer = 2.0f;
    // Start is called before the first frame update
    void Start()
    {
        if(this.gameObject.transform.parent.gameObject.GetComponent<BossSlimeEnemy>())
        {
            this.gameObject.transform.localScale = new Vector3(2, 2, 2);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (timer >= 0.0f)
        {
            timer -= Time.deltaTime;
            if (timer <= 0)
            {
                this.gameObject.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmitting);
            }
        }
        if(timer <= 0)
        {
            if(this.gameObject.GetComponent<ParticleSystem>().particleCount == 0)
            {
                Destroy(this.gameObject);
            }
        }

    }
}
