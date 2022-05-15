using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SAIM : MonoBehaviour
{
    [HideInInspector]
    public List<BaseEnemyClass> spawnedEnemies;

    [SerializeField]
    List<GameObject> nodes;

    [HideInInspector]
    public bool triggered = false;

    bool spawningFinished = false;

    //Total number of collective spawns
    int spawnAmount;

    //The amount of elapsed time since spawning started.
    float timeInSpawning;

    //Time since last spawning event
    float spawnTimer;

    public SAIMData data;

    void Start()
    {
        data.adjustedDifficulty = data.difficulty;
        data.player = GameObject.Find("Player");
    }

    void Update()
    {
        spawnTimer += Time.deltaTime;
        timeInSpawning += Time.deltaTime;

        if(CheckSpawnConditions())
        {
            Spawn(Random.Range(1, data.spawnMax));
        }

        AdjustDifficulty();


        if(spawningFinished && spawnedEnemies.Count == 0)
        {
            //end the room
        }
    }

    bool CheckSpawnConditions()
    {
        if(spawningFinished)
        {
            return false;
        }

        if (!triggered)
        {
            return false;
        }

        if (spawnAmount >= data.totalSpawns)
        {
            spawningFinished = true;
            return false;
        }

        if (timeInSpawning >= data.spawnDuration)
        {
            spawningFinished = true;
            return false;
        }

        if (spawnTimer >= data.totalSpawnTimer)
        {
            return true;
        }

        if(spawnedEnemies.Count <= data.enemyMinimum)
        {
            return true;
        }

        return false;
    }

    //if there is a spawn event, use this to spawn the enemies.
    public void Spawn(int amountToSpawn)
    {
        for (int i = 0; i < amountToSpawn; i++)
        {
            Vector3 spawnPosition = nodes[0].transform.position;



            GameObject spawnedEnemy = Instantiate(data.enemyTypes[Random.Range(0, data.enemyTypes.Count)], nodes[0].transform.position, Quaternion.identity);
            spawnedEnemy.GetComponent<BaseEnemyClass>().spawner = this.gameObject;
            spawnedEnemies.Add(spawnedEnemy.GetComponent<BaseEnemyClass>());
            spawnAmount++;
        }
    }


    public void Move()
    {

    }

    //Check every frame and adjust variables accordingly
    public void AdjustDifficulty()
    {

    }
}
