using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalSlimeProjectile : MonoBehaviour
{
    Rigidbody rb;
    private float projectileDamage;
    GameObject player;
    [SerializeField]
    private float followTimer;
    [SerializeField]
    private float followTimerLength;
    [SerializeField]
    private float lifeTimer;
    [SerializeField]
    private float lifeTimerLength;
    private AudioManager audioManager;
    [SerializeField]
    private float upForce;
    [SerializeField]
    private float forwardForce;

    // Start is called before the first frame update
    void Start()
    {
        // setting the timers at start
        rb = this.gameObject.GetComponent<Rigidbody>();
        // shoots the projectiles up and out 
        rb.AddForce(this.transform.up * upForce + this.transform.forward * forwardForce);
        player = GameObject.Find("Player");
        audioManager = GameObject.Find("Audio Manager").GetComponent<AudioManager>();
    }

    // Update is called once per frame
    void Update()
    {
        followTimer -= Time.deltaTime;
        lifeTimer -= Time.deltaTime;
        // when the crystals shoot out rotate teh crystals so that it faces the player
        if(lifeTimer <= 4.5f)
        {
            this.transform.LookAt(player.transform.position);
            Quaternion rot = transform.rotation;
            rot.eulerAngles = new Vector3(rot.eulerAngles.x + 90, rot.eulerAngles.y, rot.eulerAngles.z);
            transform.rotation = rot;
        }
        // if follow timer is greater then 0 then follow the player
        if (followTimer >= followTimerLength)
        {
            this.transform.position = Vector3.MoveTowards(this.transform.position, player.transform.position, 10 * Time.deltaTime);
        }
        // if life timer is less then 0 then destroy enemy slime crystal projectile and reset timer
        if(lifeTimer <= lifeTimerLength)
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
