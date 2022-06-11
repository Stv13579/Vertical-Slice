using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerLineOfSight : MonoBehaviour
{
    public float lookTimer;
    private void Start()
    {
        lookTimer = 1.5f;
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Enemy")
        {
            lookTimer -= Time.deltaTime;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag == "Enemy")
        {
            lookTimer -= Time.deltaTime;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Enemy")
        {
            lookTimer = 1.5f;
        }
    }
}
