using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CurrencyDrop : MonoBehaviour
{
    Rigidbody rb;
    Transform player;
    bool moving = false;
    AudioManager audioManager;
    void Start()
    {
        rb = this.gameObject.GetComponent<Rigidbody>();
        player = GameObject.Find("Player").transform;

        //Add an inital force so the currency shoots out
        rb.AddForce((this.transform.up * 500 + new Vector3(Random.Range(-1.0f, 1.0f), 0.0f, Random.Range(-1.0f, 1.0f)) * 50));
        //Ignore collisions between currency objects
        Physics.IgnoreLayerCollision(4, 4);
        Physics.IgnoreLayerCollision(4, 8);
        audioManager = FindObjectOfType<AudioManager>();
    }

    // Update is called once per frame
    void Update()
    {
        //If the player moves in range, disable he rigidbody and switch the collider to a trigger
        if((player.position - transform.position).magnitude < 5 && !moving)
        {
            Destroy(this.gameObject.GetComponent<Rigidbody>());
            this.gameObject.GetComponent<Collider>().isTrigger = true;
            moving = true;
        }

        if(moving)
        {
            //Move towards the player
            transform.position = Vector3.MoveTowards(transform.position, player.position, 5 * Time.deltaTime);
        }

    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            player.gameObject.GetComponent<PlayerClass>().money += 1;
            Destroy(this.gameObject);
            audioManager.Stop("Currency Pickup");
            audioManager.Play("Currency Pickup");
        }
    }
}
