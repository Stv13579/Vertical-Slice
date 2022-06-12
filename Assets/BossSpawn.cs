using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossSpawn : MonoBehaviour
{

    public bool triggered = false;

    [SerializeField]
    Transform spawnPosition;

    [SerializeField]
    GameObject boss;

    public bool bossDead = false;

    [SerializeField]
    GameObject hubPortal;
    
    void Start()
    {
        
    }

    void Update()
    {
        if(!triggered)
        {
            return;
        }
        if(bossDead)
        {
            hubPortal.SetActive(true);
        }
    }

    public void StartFight()
    {
        if(triggered)
        {
            return;
        }
        triggered = true;

        Instantiate(boss, spawnPosition.position, Quaternion.identity);


    }

}
