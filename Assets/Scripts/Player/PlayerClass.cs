using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerClass : MonoBehaviour
{
    public PlayerData pData;
    public float currentHealth;
    public float currentMana;
    public float money;
    // Start is called before the first frame update
    void Start()
    {
        currentHealth = pData.maxHealth;
        currentMana = pData.maxMana;
        money = 0.0f;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
