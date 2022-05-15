using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerClass : MonoBehaviour
{
    public PlayerData pData;
    public float currentHealth;
    public float currentMana;
    // Start is called before the first frame update
    void Start()
    {
        currentHealth = pData.maxHealth;
        currentMana = pData.maxMana;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
