using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSlimeProjectile : MonoBehaviour
{
    Rigidbody rb;
    float projectileDamage;
    GameObject player;
    [SerializeField]
    float followTimer;
    [SerializeField]
    float lifeTimer;
    AudioManager audioManager;

    [SerializeField]
    float upForce;
    [SerializeField]
    float forwardForce;

    // Start is called before the first frame update
    void Start()
    {
        // setting the timers at start
        rb = this.gameObject.GetComponent<Rigidbody>();
        // shoots the projectiles up and out 
        rb.AddForce(this.transform.up * upForce + this.transform.forward * forwardForce);
        player = GameObject.Find("Player");
        audioManager = FindObjectOfType<AudioManager>();
    }

    // Update is called once per frame
    void Update()
    {
        followTimer -= Time.deltaTime;
        lifeTimer -= Time.deltaTime;
        if(lifeTimer <= 4.5f)
        {
            this.transform.rotation = Quaternion.LookRotation(player.transform.position, player.transform.position);
        }
        // if follow timer is greater then 0 then follow the player
        if (followTimer >= 0)
        {
            this.transform.position = Vector3.MoveTowards(this.transform.position, player.transform.position, 10 * Time.deltaTime);
        }
        // if life timer is less then 0 then destroy enemy slime crystal projectile and reset timer
        if(lifeTimer <= 0)
        {
            Destroy(this.gameObject);
            lifeTimer = 5.0f;
        }
    }

    // damages the player if get in contact with the projectile
    // or destroy object if it touchs the ground
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.gameObject.GetComponentInParent<PlayerClass>().ChangeHealth(-projectileDamage);
            Destroy(this.gameObject);
            audioManager.Stop("Player Damage");
            audioManager.Play("Player Damage", player.transform, this.transform);
        }
        if (other.tag == "Environment")
        {
            Destroy(this.gameObject);
        }
    }
    // setter
    public void SetVars(float damage)
    {
        projectileDamage = damage;
    }
}
