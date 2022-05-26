using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[System.Serializable]
public class SAIM : MonoBehaviour
{
    [HideInInspector]
    public List<BaseEnemyClass> spawnedEnemies;

    [SerializeField, HideInInspector]
    public List<Node> nodes;
    [SerializeField, HideInInspector]
    List<Node> deadNodes;

    public List<Node> aliveNodes;

    [SerializeField]
    List<GameObject> blockers = new List<GameObject>();

    public List<GameObject> testObjects;

    [SerializeField]
    GameObject node;
    [SerializeField]
    GameObject blockerMaster;

    //number in nodes of the sides of the grid.
    [SerializeField]
    int gridSize;

    [SerializeField]
    float nodeSpacing;

    [SerializeField]
    GameObject nodeMaster;

    //FOR TESTING
    [SerializeField]
    public Material killMat;
    public LayerMask nodeLayerMask;
    public LayerMask blankSpaceLayerMask;
    public LayerMask verticalSpaceLayerMask;
    bool doneonce = false;

    [HideInInspector]
    public bool triggered = false, playerLeaving = false, roomComplete = false;

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
        
        //CreateAndKillNodes();
        foreach (Transform child in blockerMaster.transform)
        {
            blockers.Add(child.gameObject);
        }

        //nodes.AddRange(nodeMaster.GetComponentsInChildren<Node>());

        //for (int i = 0; i < nodes.Count; i++)
        //{
        //    if (nodes[i].GetComponent<Node>().GetAlive())
        //    {
        //        aliveNodes.Add(nodes[i]);
        //    }
        //    else
        //    {
        //        deadNodes.Add(nodes[i]);
        //    }
        //}
    }



    void Update()
    {
        spawnTimer += Time.deltaTime;
        timeInSpawning += Time.deltaTime;

        if(CheckSpawnConditions())
        {
            Spawn(Random.Range(1, data.spawnMax));
           
        }

        CheckEndOfRoom();

        if(triggered && !roomComplete)
        {
            blockerMaster.SetActive(true);
        }
        else
        {
            blockerMaster.SetActive(false);
        }

        AdjustDifficulty();




        if(spawningFinished && spawnedEnemies.Count == 0)
        {
            //end the room
        }

       

    }

    private void FixedUpdate()
    {
        Move();

        
        
    }

    //Creates a grid of nodes with a given bounds, then kills the illegal ones (too high, inside collison, over dead space etc). 
    public void CreateAndKillNodes()
    {
        //deadNodes = new List<Node>();
        //aliveNodes = new List<Node>();

        nodeMaster = transform.GetChild(1).gameObject;

        //Create a field of nodes
        for (int i = 0; i < gridSize; i++)
        {
            for (int j = 0; j < gridSize; j++)
            {
                for (int k = 0; k < gridSize; k++)
                {
                    Vector3 nodeVec = new Vector3(i, j, k) * nodeSpacing;
                    GameObject newNode = Instantiate(node, nodeMaster.transform);

                    newNode.transform.localPosition = nodeVec;

                    nodes.Add(newNode.GetComponent<Node>());

                }
            }
        }

        Vector3 nodeMasterPosition = nodeMaster.transform.position;
        nodeMasterPosition.x -= (gridSize * nodeSpacing) / 2;
        nodeMasterPosition.y -= (gridSize * nodeSpacing) / 2;
        nodeMasterPosition.z -= (gridSize * nodeSpacing) / 2;

        nodeMaster.transform.position = nodeMasterPosition;

        //Kill the illegal ones

        //Check all nodes that are inside a collider, and kill them.

        //Raycast up, then down. if both hit enviro triggers, kill it. 
        for (int i = 0; i < nodes.Count; i++)
        {
            RaycastHit hit;

            
            if (Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.down), out hit, Mathf.Infinity, nodeLayerMask) &&
            Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.up), out hit, Mathf.Infinity, nodeLayerMask) )
            {

                KillNode(i);
                
            }

            //raycast down and if it hits catchall, kill it
            if (Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.down), out hit, Mathf.Infinity, blankSpaceLayerMask))
            {
                if (hit.collider.isTrigger)
                {
                    KillNode(i);
                }
            }

            

        }

        //Second check for after

        //Of the remaining nodes, raycast to see if they are just above a collider that isn't a node, and kill the rest. 


        for (int i = 0; i < nodes.Count; i++)
        {
            RaycastHit hit1;
            //Check its not superfluous (too high)
            nodes[i].GetComponent<Collider>().enabled = false;
            

            if (nodes[i].GetComponent<Node>().GetAlive() && Physics.Raycast(nodes[i].transform.position, nodes[i].transform.TransformDirection(Vector3.down), out hit1, Mathf.Infinity, verticalSpaceLayerMask))
            {

                KillNode(i);
            }
            nodes[i].GetComponent<Collider>().enabled = true;
        }


        for (int i = 0; i < nodes.Count; i++)
        {
            DestroyImmediate(nodes[i].GetComponent<BoxCollider>());
            if(nodes[i].GetComponent<Node>().GetAlive())
            {
                aliveNodes.Add(nodes[i]);
            }
            else
            {

                DestroyImmediate(nodes[i].gameObject);
                //deadNodes.Add(nodes[i]);
            }
        }

    } 

    void KillNode(int index)
    {
        nodes[index].GetComponent<MeshRenderer>().material = killMat;
        nodes[index].GetComponent<MeshRenderer>().enabled = false;
        nodes[index].GetComponent<Node>().SetAlive(false);

        nodes[index].gameObject.layer = LayerMask.NameToLayer("DeadNode");

        deadNodes.Add(nodes[index]);
    }

    public void DestroyAllNodes()
    {
        nodeMaster.transform.localPosition = Vector3.zero;
        int j = 0;
        foreach (Node node in nodes)
        {
            if(nodes[j] != null)
            {
                DestroyImmediate(nodes[j].gameObject);
            }
            
            j++;
        }

        nodes.Clear();
        aliveNodes.Clear();
        deadNodes.Clear();
    }

    void CheckEndOfRoom()
    {
        if(spawningFinished && spawnedEnemies.Count <= 0)
        {
            roomComplete = true;
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
            Vector3 spawnPosition = aliveNodes[Random.Range(0, aliveNodes.Count)].transform.position;

            spawnPosition.x += Random.Range(-1.0f, 2.0f);
            spawnPosition.z += Random.Range(-1.0f, 2.0f);
            spawnPosition.y += 2;

            GameObject spawnedEnemy = Instantiate(data.enemyTypes[Random.Range(0, data.enemyTypes.Count)], spawnPosition, Quaternion.identity);
            spawnedEnemy.GetComponent<BaseEnemyClass>().spawner = this.gameObject;
            spawnedEnemies.Add(spawnedEnemy.GetComponent<BaseEnemyClass>());
            spawnAmount++;
        }
    }


    public void SelectSpawnNode()
    {
        //Check the node is in front of the player, not overlapping an existing enemy or soon to be spawned enemy.
    }

    public void Move()
    {
        for (int i = 0; i < spawnedEnemies.Count; i++)
        {
            Bounce(i);
            
        }
    }

    public void Bounce(int elementIndex)
    {
        //Bouncing away from each other
        for (int j = 0; j < spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.Count; j++)
        {
            if (spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList[j] == null)
            {
                spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.RemoveAt(j);
            }
            else 
            {
                Vector3 newDir = spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList[j].transform.position - spawnedEnemies[elementIndex].gameObject.transform.position;
                newDir.y = 0;
                if (newDir.magnitude == 0)
                {
                    newDir = new Vector3(Random.Range(-1, 2), 0, Random.Range(-1, 2));
                    newDir = newDir.normalized;

                }
                spawnedEnemies[elementIndex].gameObject.transform.position -= newDir * Time.deltaTime;
                spawnedEnemies[elementIndex].GetComponent<BaseEnemyClass>().bounceList.RemoveAt(j);
            }

            
            j--;

        }
    }

    //Check every frame and adjust variables accordingly
    public void AdjustDifficulty()
    {

    }
}
