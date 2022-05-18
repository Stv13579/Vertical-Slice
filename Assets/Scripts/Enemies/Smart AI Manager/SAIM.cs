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

        Move();


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

            //spawnPosition.x += Random.Range(-1.0f, 2.0f);
            //spawnPosition.z += Random.Range(-1.0f, 2.0f);

            GameObject spawnedEnemy = Instantiate(data.enemyTypes[Random.Range(0, data.enemyTypes.Count)], spawnPosition, Quaternion.identity);
            spawnedEnemy.GetComponent<BaseEnemyClass>().spawner = this.gameObject;
            spawnedEnemies.Add(spawnedEnemy.GetComponent<BaseEnemyClass>());
            spawnAmount++;
        }
    }


    public void Move()
    {
        for (int i = 0; i < spawnedEnemies.Count; i++)
        {
            for (int j = 0; j < spawnedEnemies[i].GetComponent<BaseEnemyClass>().bounceList.Count; j++)
            {
                Vector3 newDir = spawnedEnemies[i].GetComponent<BaseEnemyClass>().bounceList[j].transform.position - spawnedEnemies[i].gameObject.transform.position;
                newDir.y = 0;
                if(newDir.magnitude == 0)
                {
                    newDir = new Vector3(Random.Range(-1, 2), 0, Random.Range(-1, 2));
                    newDir = newDir.normalized;

                }
                spawnedEnemies[i].gameObject.transform.position -= newDir * Time.deltaTime * 10;
                spawnedEnemies[i].GetComponent<BaseEnemyClass>().bounceList.RemoveAt(j);
                j--;

            }
        }
    }

    //Check every frame and adjust variables accordingly
    public void AdjustDifficulty()
    {

    }
}
