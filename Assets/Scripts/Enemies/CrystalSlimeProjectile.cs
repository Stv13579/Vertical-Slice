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
        rb.AddForce(this.transform.up * 2000 + this.transform.forward * 700);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.gameObject.GetComponent<PlayerClass>().currentHealth -= projectileDamage;
            Destroy(this.gameObject);
        }
        if (!other.GetComponent<CrystalSlimeProjectile>())
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
