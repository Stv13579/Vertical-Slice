using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSlimeProjectile : MonoBehaviour
{
    Rigidbody rb;
    float projectileDamage;
    // Start is called before the first frame update
    void Start()
    {
        rb = this.gameObject.GetComponent<Rigidbody>();
        // shoots the projectiles up and out 
        rb.AddForce(this.transform.up * 2000 + this.transform.forward * 700);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    // damages the player it the get in contact with the projectile
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.gameObject.GetComponent<PlayerClass>().ChangeHealth(-projectileDamage);
            Destroy(this.gameObject);
        }
        if (!other.GetComponent<CrystalSlimeProjectile>() && other.tag != "Enemy" && other.tag != "Bouncer")
        {
            Debug.Log(other.gameObject.name);
            Destroy(this.gameObject);
        }
    }

    public void SetVars(float damage)
    {
        projectileDamage = damage;
    }
}
